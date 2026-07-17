<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Payment;
use App\Models\Wallet;
use App\Services\CoinService;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Models\OrderTrack;

class PaymentController extends Controller
{
    public function __construct(
        private NotificationService $notifService,
        private OrderController $orderController
    ) {}

    /**
     * POST /api/payment/create
     * Buat transaksi Midtrans Snap
     */
    public function create(Request $request)
    {
        $rawContent = $request->getContent();
        if (empty($request->all()) && !empty($rawContent)) {
            $decoded = json_decode($rawContent, true);
            if (is_array($decoded)) {
                $request->merge($decoded);
            }
        }

        Log::info('Payment create incoming request', [
            'body' => $request->all(),
            'raw' => $rawContent,
            'query' => $request->query(),
        ]);

        $paymentMethod = $request->input('payment_method');
        if (empty($paymentMethod)) {
            $paymentMethod = $request->input('payment_type')
                ?: $request->input('paymentMethod')
                ?: $request->query('payment_method')
                ?: $request->query('payment_type')
                ?: $request->query('paymentMethod');
        }

        if ($paymentMethod !== null) {
            $request->merge(['payment_method' => $paymentMethod]);
        }

        $orderId = $request->input('order_id') ?: $request->query('order_id');
        if ($orderId !== null) {
            $request->merge(['order_id' => $orderId]);
        }

        $request->validate([
            'order_id' => 'required|exists:orders,id',
            'payment_method' => 'required|string|in:bca,mandiri,gopay,ovo,dana,qris',
        ]);

        $order = Order::with(['user', 'items.product', 'address'])
            ->where('user_id', auth()->id())
            ->where('status', 'pending')
            ->findOrFail($request->order_id);

        // Build Midtrans payload
        $methodMapping = [
            'bca'     => 'bca_va',
            'mandiri' => 'mandiri_bill',
            'gopay'   => 'gopay',
            'ovo'     => 'ovo',
            'dana'    => 'dana',
            'qris'    => 'qris',
        ];

        $payload = [
            'transaction_details' => [
                'order_id'     => $order->order_number,
                'gross_amount' => (int)$order->total,
            ],
            'customer_details' => [
                'first_name' => $order->user->name,
                'email'      => $order->user->email,
                'phone'      => $order->user->phone,
            ],
            'item_details' => $order->items->map(fn($item) => [
                'id'       => (string)$item->product_id,
                'price'    => (int)$item->price,
                'quantity' => $item->quantity,
                'name'     => substr($item->product->name, 0, 50),
            ])->toArray(),
            'shipping_address' => [
                'address'   => $order->address->detail,
                'city'      => $order->address->city,
                'postal_code' => $order->address->zip,
            ],
            'callbacks' => [
                'finish' => config('app.url') . '/payment/finish',
            ],
            'expiry' => [
                'start_time' => now()->format('Y-m-d H:i:s O'),
                'unit'       => 'hours',
                'duration'   => 24,
            ],
        ];

        // Add shipping fee as item
        if ($order->shipping_fee > 0) {
            $payload['item_details'][] = [
                'id'       => 'shipping',
                'price'    => (int)$order->shipping_fee,
                'quantity' => 1,
                'name'     => 'Ongkos Kirim',
            ];
        }

        // Subtract coin discount
        if ($order->coin_discount > 0) {
            $payload['item_details'][] = [
                'id'       => 'coin_discount',
                'price'    => -(int)$order->coin_discount,
                'quantity' => 1,
                'name'     => 'Diskon Lokal Coin',
            ];
        }

        $selectedPayment = $request->payment_method;
        if (in_array($selectedPayment, ['bca', 'mandiri'])) {
            $payload['enabled_payments'] = ['bank_transfer'];
        } elseif (in_array($selectedPayment, ['gopay', 'qris'])) {
            $payload['enabled_payments'] = ['gopay', 'qris'];
        } else {
            $payload['enabled_payments'] = ['bank_transfer', 'gopay', 'qris'];
        }

        // Call Midtrans Snap API
        $serverKey = config('services.midtrans.server_key');
        $isProduction = config('services.midtrans.is_production', false);
        $baseUrl = $isProduction ? 'https://app.midtrans.com' : 'https://app.sandbox.midtrans.com';

        if (empty($serverKey)) {
            Log::error('Midtrans server key missing', ['order_id' => $order->id]);
            return response()->json([
                'success' => false,
                'message' => 'Midtrans server key belum dikonfigurasi. Silakan isi MIDTRANS_SERVER_KEY di .env.',
            ], 500);
        }

        $response = Http::withBasicAuth($serverKey, '')
            ->post("{$baseUrl}/snap/v1/transactions", $payload);

        if (!$response->successful()) {
            $errorMessage = 'Gagal membuat transaksi pembayaran.';
            $body = $response->json();
            if (is_array($body) && isset($body['error_messages'])) {
                $errorMessage = implode(' ', (array)$body['error_messages']);
            } elseif (is_array($body) && isset($body['message'])) {
                $errorMessage = $body['message'];
            }

            Log::error('Midtrans error', ['response' => $response->body(), 'order_id' => $order->id]);
            return response()->json(['success' => false, 'message' => $errorMessage], $response->status());
        }

        $snapData = $response->json();

        // Save payment record
        Payment::updateOrCreate(
            ['order_id' => $order->id],
            [
                'snap_token'   => $snapData['token'],
                'snap_url'     => $snapData['redirect_url'],
                'payment_method' => $selectedPayment,
                'status'       => 'pending',
                'expired_at'   => now()->addHours(24),
            ]
        );

        $order->update(['status' => 'awaiting_payment']);

        return response()->json([
            'success' => true,
            'data'    => [
                'snap_token'   => $snapData['token'],
                'snap_url'     => $snapData['redirect_url'],
                'order_number' => $order->order_number,
                'total'        => $order->total,
            ],
        ]);
    }

    /**
     * GET /api/payment/status/{orderId}
     */
    public function status($orderId)
    {
        $order   = Order::where('user_id', auth()->id())->findOrFail($orderId);
        $payment = Payment::where('order_id', $order->id)->firstOrFail();

        return response()->json(['success' => true, 'data' => [
            'order_status'   => $order->status,
            'payment_status' => $payment->status,
            'payment_method' => $payment->payment_method,
            'paid_at'        => $payment->paid_at,
        ]]);
    }

    /**
     * POST /api/payment/notification  (Midtrans webhook — public)
     *
     * Midtrans akan mengirim notifikasi HTTP POST ke endpoint ini untuk setiap
     * perubahan status transaksi. Endpoint ini wajib diakses publik (tanpa API token).
     *
     * Keamanan:
     * 1. Validasi Signature Key dari header x-midtrans-signature atau body signature_key
     * 2. Gunakan DB::transaction untuk atomic update
     * 3. Cek status payment di DB untuk cegah race condition
     * 4. Simpan data audit (transaction_id, payment_type, gross_amount)
     * 5. Log semua notifikasi dengan payload mentah
     * 6. Tidak bocorkan detail teknis ke response publik
     */
    public function notification(Request $request)
    {
        $serverKey   = config('services.midtrans.server_key');
        $rawPayload  = $request->getContent();
        $allBody     = $request->all();

        // ── 1. Validasi Signature Key (header ATAU body) ───────────────
        // Midtrans Sandbox mengirim signature_key di body,
        // Production mengirim x-midtrans-signature di header.
        // Kita dukung keduanya.
        $signatureFromHeader = $request->header('x-midtrans-signature');
        $signatureFromBody   = $request->input('signature_key');
        $incomingSignature   = $signatureFromHeader ?: $signatureFromBody;

        $calculatedSignature = hash('sha512',
            $request->order_id .
            $request->status_code .
            $request->gross_amount .
            $serverKey
        );

        // Log mentah untuk audit
        Log::channel('midtrans')->info('[INCOMING] Midtrans notification', [
            'headers'              => $request->headers->all(),
            'raw_payload'          => $rawPayload,
            'parsed_body'          => $allBody,
            'signature_from_header' => $signatureFromHeader,
            'signature_from_body'  => $signatureFromBody,
            'signature_calculated' => $calculatedSignature,
            'ip'                   => $request->ip(),
            'user_agent'           => $request->userAgent(),
        ]);

        if (empty($serverKey)) {
            Log::channel('midtrans')->critical('[REJECTED] Server key kosong');
            return response('', 403);
        }

        if (empty($incomingSignature) || !hash_equals($calculatedSignature, $incomingSignature)) {
            Log::channel('midtrans')->warning('[REJECTED] Invalid signature', [
                'order_id'                  => $request->order_id,
                'status_code'               => $request->status_code,
                'gross_amount'              => $request->gross_amount,
                'incoming_signature'        => $incomingSignature,
                'calculated_signature'      => $calculatedSignature,
            ]);

            // Tolak tanpa detail teknis
            return response('', 403);
        }

        Log::channel('midtrans')->info('[VERIFIED] Signature valid', [
            'order_id'     => $request->order_id,
            'order_number' => $request->order_id,
        ]);

        // ── 2. Proses dalam Database Transaction ───────────────────────
        // Catatan: distributePaymentFunds() sudah punya DB::transaction sendiri.
        // Daripada nested transaction, kita panggil dulu distributePaymentFunds
        // lalu lanjut update payment. Jika gagal, tidak ada update sama sekali.
        $order = Order::with(['items.product.umkm.user', 'user.wallet'])
            ->where('order_number', $request->order_id)
            ->first();

        if (!$order) {
            Log::channel('midtrans')->warning('[SKIPPED] Order not found', [
                'order_number' => $request->order_id,
            ]);
            // Tetap 200 agar Midtrans tidak retry terus
            return response('', 200);
        }

        $transactionStatus = $request->transaction_status;
        $fraudStatus       = $request->fraud_status;

        // Data audit yang akan disimpan ke payment record
        $auditData = [
            'transaction_id' => $request->transaction_id,
            'payment_method' => $request->payment_type,
            'amount'         => (int) $request->gross_amount,
            'raw_response'   => $rawPayload,
        ];

        // ── 3. Mapping status ──────────────────────────────────────────
        $isSuccess = ($transactionStatus === 'settlement')
            || ($transactionStatus === 'capture' && $fraudStatus !== 'challenge');

        $isFailed = in_array($transactionStatus, ['cancel', 'deny', 'expire']);

        // ── 4. Eksekusi sesuai status ──────────────────────────────────
        if ($isSuccess) {
            // ------------------------------------------------------------
            // SETTLEMENT / CAPTURE (sukses)
            // ------------------------------------------------------------
            try {
                DB::beginTransaction();

                // Lock order & payment untuk cegah race condition
                // WAJIB load relasi karena distributePaymentFunds membutuhkan items, user, wallet, dll
                $lockedOrder = Order::with(['items.product.umkm.user', 'user.wallet'])
                    ->where('id', $order->id)
                    ->lockForUpdate()
                    ->first();

                // Cek payment status di DB
                $existingPayment = Payment::where('order_id', $order->id)
                    ->lockForUpdate()
                    ->first();

                // Sudah pernah diproses? skip
                if ($existingPayment && in_array($existingPayment->status, ['paid', 'challenge']) && $existingPayment->status !== 'pending') {
                    DB::commit();
                    Log::channel('midtrans')->info('[SKIPPED] Payment already processed (paid)', [
                        'order_id'          => $order->id,
                        'payment_status_db' => $existingPayment->status,
                    ]);
                    return response('', 200);
                }

                // Update payment record
                $paymentData = array_merge($auditData, [
                    'status'  => 'paid',
                    'paid_at' => now(),
                ]);

                if ($existingPayment) {
                    $existingPayment->update($paymentData);
                } else {
                    // Jika belum ada payment record, buat baru
                    Payment::create(array_merge($paymentData, [
                        'order_id' => $order->id,
                    ]));
                }

                // Panggil distribusi dana — method ini punya DB::transaction sendiri
                // Tapi karena kita sudah di dalam transaction, savepoint akan dibuat.
                // Jika throw, rollback ke savepoint, lalu kita rollback outer transaction.
                $this->orderController->distributePaymentFunds($lockedOrder);

                // Buat tracking record
                OrderTrack::create([
                    'order_id'    => $order->id,
                    'status'      => 'Pembayaran Berhasil',
                    'description' => 'Pembayaran telah dikonfirmasi. Pesanan sudah dibayar dan sedang diproses oleh penjual.',
                ]);

                DB::commit();

                Log::channel('midtrans')->info('[SUCCESS] Payment settled & funds distributed', [
                    'order_id'      => $order->id,
                    'order_number'  => $order->order_number,
                    'transaction_id'=> $request->transaction_id,
                    'payment_type'  => $request->payment_type,
                    'gross_amount'  => $request->gross_amount,
                ]);

            } catch (\Throwable $e) {
                DB::rollBack();
                Log::channel('midtrans')->error('[ERROR] Settlement failed, rolled back', [
                    'order_id'    => $order->id,
                    'error'       => $e->getMessage(),
                    'trace'       => $e->getTraceAsString(),
                ]);
                // Return 200 agar Midtrans tidak resend terus
                return response('', 200);
            }

        } elseif ($isFailed) {
            // ------------------------------------------------------------
            // CANCEL / DENY / EXPIRE (gagal)
            // ------------------------------------------------------------
            try {
                DB::beginTransaction();

                $existingPayment = Payment::where('order_id', $order->id)
                    ->lockForUpdate()
                    ->first();

                if ($existingPayment && in_array($existingPayment->status, ['paid', 'challenge'])) {
                    // Jika sudah paid, jangan ubah status jadi cancel/expire
                    DB::commit();
                    Log::channel('midtrans')->info('[SKIPPED] Payment already paid, ignoring cancel/expire', [
                        'order_id' => $order->id,
                    ]);
                    return response('', 200);
                }

                if ($existingPayment) {
                    $existingPayment->update(array_merge($auditData, [
                        'status' => $transactionStatus, // 'cancel' | 'deny' | 'expire'
                    ]));
                } else {
                    Payment::create(array_merge($auditData, [
                        'order_id' => $order->id,
                        'status'   => $transactionStatus,
                    ]));
                }

                $lockedOrder = Order::where('id', $order->id)->lockForUpdate()->first();
                $lockedOrder->update(['status' => 'cancelled']);

                DB::commit();

                // Kirim notifikasi ke user (di luar transaction)
                $this->notifService->sendToUser($order->user_id, [
                    'title' => 'Pembayaran Gagal ❌',
                    'body'  => "Pembayaran pesanan #{$order->order_number} gagal: {$transactionStatus}.",
                    'type'  => 'payment',
                    'data'  => ['order_id' => $order->id],
                ]);

                Log::channel('midtrans')->info('[FAILED] Payment failed', [
                    'order_id'      => $order->id,
                    'order_number'  => $order->order_number,
                    'transaction_status' => $transactionStatus,
                    'transaction_id'=> $request->transaction_id,
                ]);

            } catch (\Throwable $e) {
                DB::rollBack();
                Log::channel('midtrans')->error('[ERROR] Failed payment handling failed, rolled back', [
                    'order_id' => $order->id,
                    'error'    => $e->getMessage(),
                ]);
                return response('', 200);
            }

        } elseif ($transactionStatus === 'capture' && $fraudStatus === 'challenge') {
            // ------------------------------------------------------------
            // CHALLENGE (perlu verifikasi manual)
            // ------------------------------------------------------------
            try {
                DB::beginTransaction();

                $existingPayment = Payment::where('order_id', $order->id)
                    ->lockForUpdate()
                    ->first();

                if ($existingPayment) {
                    $existingPayment->update(array_merge($auditData, ['status' => 'challenge']));
                } else {
                    Payment::create(array_merge($auditData, [
                        'order_id' => $order->id,
                        'status'   => 'challenge',
                    ]));
                }

                DB::commit();

                $this->notifService->sendToUser($order->user_id, [
                    'title' => 'Pembayaran dalam Verifikasi ⏳',
                    'body'  => "Pembayaran pesanan #{$order->order_number} sedang diverifikasi.",
                    'type'  => 'payment',
                    'data'  => ['order_id' => $order->id],
                ]);

                Log::channel('midtrans')->info('[CHALLENGE] Payment under review', [
                    'order_id'      => $order->id,
                    'order_number'  => $order->order_number,
                    'transaction_id'=> $request->transaction_id,
                ]);

            } catch (\Throwable $e) {
                DB::rollBack();
                Log::channel('midtrans')->error('[ERROR] Challenge handling failed', [
                    'order_id' => $order->id,
                    'error'    => $e->getMessage(),
                ]);
                return response('', 200);
            }

        } else {
            // ------------------------------------------------------------
            // PENDING / status lainnya — update audit saja
            // ------------------------------------------------------------
            try {
                $existingPayment = Payment::where('order_id', $order->id)->first();
                if ($existingPayment) {
                    $existingPayment->update($auditData);
                }
            } catch (\Throwable $e) {
                Log::channel('midtrans')->error('[ERROR] Pending update failed', [
                    'order_id' => $order->id,
                    'error'    => $e->getMessage(),
                ]);
            }

            Log::channel('midtrans')->info('[PENDING] Payment status update (audit only)', [
                'order_id'      => $order->id,
                'order_number'  => $order->order_number,
                'transaction_status' => $transactionStatus,
                'fraud_status'  => $fraudStatus,
            ]);
        }

        // ── 5. Response minimal, tanpa detail teknis ──────────────────
        return response('', 200);
    }

    /**
     * DETAIL LANGKAH 3: Endpoint mengambil riwayat tracking untuk sisi Flutter
     */
    public function getTracking($id)
    {
        $tracks = OrderTrack::where('order_id', $id)
                    ->orderBy('created_at', 'desc')
                    ->get();

        return response()->json([
            'success' => true,
            'data' => $tracks
        ], 200);
    }

    /**
     * GET /payment/finish
     * Handle redirect callback from Midtrans sandbox after successful payment.
     */
    public function paymentFinish(Request $request)
    {
        Log::info('User returned from Midtrans', $request->all());

        $orderId = $request->query('order_id', 'N/A');
        $statusCode = $request->query('status_code', 'N/A');
        $transactionStatus = $request->query('transaction_status', 'N/A');

        $html = <<<HTML
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title>Pembayaran Selesai</title>
  <style>
    body {font-family: Arial, sans-serif; background: #f4f6f8; color: #333; margin: 0; padding: 0;}
    .container {max-width: 640px; margin: 48px auto; padding: 24px; background: #fff; border-radius: 12px; box-shadow: 0 12px 28px rgba(0,0,0,0.08);}
    h1 {margin-top: 0; color: #0b5ed7;}
    p {line-height: 1.7;}
    .badge {display: inline-block; padding: 8px 14px; border-radius: 999px; background: #e7f1ff; color: #0b5ed7; font-weight: 600; margin-top: 8px;}
    .info {margin: 20px 0; padding: 16px; background: #f8f9fa; border-radius: 10px;}
    .info strong {display: block; margin-bottom: 6px;}
    .button {display: inline-block; margin-top: 20px; padding: 12px 20px; background: #0b5ed7; color: #fff; text-decoration: none; border-radius: 8px;}
    .footer {margin-top: 28px; font-size: 0.95rem; color: #666;}
  </style>
</head>
<body>
  <div class="container">
    <h1>Terima Kasih!</h1>
    <p>Pembayaran Anda berhasil diproses oleh Midtrans. Silakan lanjutkan kembali ke aplikasi mobile untuk melihat detail pesanan.</p>
    <div class="info">
      <strong>Nomor Pesanan:</strong>
      <span class="badge">{$orderId}</span>
      <strong>Status Transaksi:</strong>
      <span>{$transactionStatus}</span>
      <strong>Kode Status:</strong>
      <span>{$statusCode}</span>
    </div>
    <p>Jika aplikasi mobile tidak otomatis menutup, kembali ke halaman utama aplikasi secara manual dan periksa status pesanan di menu Pesanan Saya.</p>
    <a class="button" href="/">Kembali ke Beranda</a>
    <div class="footer">
      <p>Apabila Anda menggunakan aplikasi mobile, cukup tutup halaman ini dan lanjutkan kembali ke aplikasi.</p>
    </div>
  </div>
</body>
</html>
HTML;

        return response($html, 200)
            ->header('Content-Type', 'text/html; charset=utf-8');
    }
}