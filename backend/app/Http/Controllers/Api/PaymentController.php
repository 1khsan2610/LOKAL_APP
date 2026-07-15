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
     * Saat Midtrans mengirim notifikasi sukses (settlement/capture):
     * 1. Update payment status menjadi 'paid'
     * 2. Update order status menjadi 'processing' (Sudah Dibayar)
     * 3. Distribusikan dana ke wallet UMKM, komisi admin, cashback koin
     * 4. Buat tracking record
     * 5. Kirim notifikasi
     */
    public function notification(Request $request)
    {
        $serverKey = config('services.midtrans.server_key');

        // Verify signature
        $signatureKey = hash('sha512',
            $request->order_id .
            $request->status_code .
            $request->gross_amount .
            $serverKey
        );

        if ($signatureKey !== $request->signature_key) {
            return response()->json(['message' => 'Invalid signature'], 403);
        }

        $order = Order::with(['items.product.umkm.user', 'user.wallet'])
            ->where('order_number', $request->order_id)
            ->first();

        if (!$order) return response()->json(['message' => 'Order not found'], 404);

        // Cegah duplikasi: jika sudah processing/delivered, skip
        if (in_array($order->status, ['processing', 'delivered', 'cancelled'])) {
            Log::info('Midtrans webhook skipped — order already processed', [
                'order_id' => $order->id,
                'status'   => $order->status,
            ]);
            return response()->json(['success' => true, 'message' => 'Already processed']);
        }

        $transactionStatus = $request->transaction_status;
        $fraudStatus       = $request->fraud_status;

        // Tentukan apakah pembayaran sukses
        $isSuccess = ($transactionStatus === 'settlement')
            || ($transactionStatus === 'capture' && $fraudStatus !== 'challenge');

        if ($isSuccess) {
            // ✅ Pembayaran sukses → update payment & distribusikan dana
            Payment::where('order_id', $order->id)->update([
                'status'         => 'paid',
                'payment_method' => $request->payment_type,
                'transaction_id' => $request->transaction_id,
                'paid_at'        => now(),
                'raw_response'   => json_encode($request->all()),
            ]);

            // Panggil distribusi dana (update status → 'processing' + bagi dana)
            $this->orderController->distributePaymentFunds($order);

            // Buat tracking record
            OrderTrack::create([
                'order_id'   => $order->id,
                'status'     => 'Pembayaran Berhasil',
                'description' => 'Pembayaran telah dikonfirmasi. Pesanan sudah dibayar dan sedang diproses oleh penjual.',
            ]);

            Log::info('Midtrans webhook — payment success, funds distributed', [
                'order_id'    => $order->id,
                'order_number' => $order->order_number,
            ]);

        } elseif (in_array($transactionStatus, ['cancel', 'deny', 'expire'])) {
            // ❌ Pembayaran gagal/dibatalkan
            Payment::where('order_id', $order->id)->update([
                'status'         => $transactionStatus,
                'payment_method' => $request->payment_type,
                'transaction_id' => $request->transaction_id,
                'raw_response'   => json_encode($request->all()),
            ]);

            $order->update(['status' => 'cancelled']);

            $this->notifService->sendToUser($order->user_id, [
                'title' => 'Pembayaran Gagal ❌',
                'body'  => "Pembayaran pesanan #{$order->order_number} gagal: {$transactionStatus}.",
                'type'  => 'payment',
                'data'  => ['order_id' => $order->id],
            ]);

            Log::info('Midtrans webhook — payment failed', [
                'order_id' => $order->id,
                'status'   => $transactionStatus,
            ]);

        } elseif ($transactionStatus === 'capture' && $fraudStatus === 'challenge') {
            // ⚠️ Transaksi challenge (menunggu verifikasi)
            Payment::where('order_id', $order->id)->update([
                'status'         => 'challenge',
                'payment_method' => $request->payment_type,
                'transaction_id' => $request->transaction_id,
                'raw_response'   => json_encode($request->all()),
            ]);

            $this->notifService->sendToUser($order->user_id, [
                'title' => 'Pembayaran dalam Verifikasi ⏳',
                'body'  => "Pembayaran pesanan #{$order->order_number} sedang diverifikasi.",
                'type'  => 'payment',
                'data'  => ['order_id' => $order->id],
            ]);
        }

        return response()->json(['success' => true]);
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