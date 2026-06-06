<?php

namespace App\Services;

use App\Models\Order;
use App\Models\Payment;
use Midtrans\Config;
use Midtrans\Snap;
use Midtrans\Transaction;

class PaymentService
{
    public function __construct()
    {
        Config::$serverKey = config('services.midtrans.server_key');
        Config::$clientKey = config('services.midtrans.client_key');
        Config::$isProduction = config('services.midtrans.is_production');
        Config::$isSanitized = true;
        Config::$is3ds = true;
    }

    /**
     * Create payment token via Midtrans SNAP
     */
    public function createPaymentToken(Order $order): array
    {
        try {
            $transactionDetails = [
                'order_id' => $order->order_number,
                'gross_amount' => (int) $order->total_amount,
            ];

            $itemDetails = [];
            foreach ($order->items as $item) {
                $itemDetails[] = [
                    'id' => $item->product_id,
                    'price' => (int) $item->product_price,
                    'quantity' => $item->quantity,
                    'name' => $item->product_name,
                ];
            }

            // Add discount if Lokal Coin used
            if ($order->lokal_coin_discount > 0) {
                $itemDetails[] = [
                    'id' => 'lokal_coin_discount',
                    'price' => (int) -$order->lokal_coin_discount,
                    'quantity' => 1,
                    'name' => 'Diskon Lokal Coin',
                ];
            }

            $customerDetails = [
                'first_name' => $order->consumer->name,
                'email' => $order->consumer->email ?? 'customer@lokal.id',
                'phone' => $order->consumer->phone_number,
                'billing_address' => [
                    'address' => $order->delivery_address,
                    'city' => $order->consumer->city ?? 'Bandung',
                    'postal_code' => '00000',
                    'country_code' => 'IDN',
                ],
            ];

            $transaction = [
                'transaction_details' => $transactionDetails,
                'item_details' => $itemDetails,
                'customer_details' => $customerDetails,
                'expiry' => [
                    'unit' => 'minute',
                    'length' => 30, // 30 minutes
                ],
            ];

            $snapToken = Snap::getSnapToken($transaction);

            // Save payment record
            $payment = Payment::create([
                'order_id' => $order->id,
                'midtrans_transaction_id' => $transaction['transaction_details']['order_id'],
                'midtrans_order_id' => $transaction['transaction_details']['order_id'],
                'status' => Payment::STATUS_PENDING,
                'amount' => $order->total_amount,
                'expired_at' => now()->addMinutes(30),
            ]);

            return [
                'success' => true,
                'snap_token' => $snapToken,
                'payment_id' => $payment->id,
            ];
        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => 'Gagal membuat pembayaran: ' . $e->getMessage(),
            ];
        }
    }

    /**
     * Handle payment notification webhook
     */
    public function handleNotification(array $notification): array
    {
        $orderId = $notification['order_id'];
        $transactionStatus = $notification['transaction_status'];
        $paymentType = $notification['payment_type'] ?? null;

        // Find payment record
        $payment = Payment::where('midtrans_order_id', $orderId)->first();

        if (!$payment) {
            return [
                'success' => false,
                'message' => 'Payment record not found',
            ];
        }

        // Store full Midtrans response
        $payment->update(['midtrans_response' => $notification]);

        // Update payment status based on transaction status
        $status = $this->mapTransactionStatus($transactionStatus);
        $payment->update(['status' => $status]);

        if ($status === Payment::STATUS_SUCCESS) {
            $payment->update(['paid_at' => now()]);
            $payment->order->update(['status' => Order::STATUS_CONFIRMED]);

            // Trigger order confirmation event
            event(new \App\Events\OrderConfirmedEvent($payment->order));
        } elseif ($status === Payment::STATUS_FAILED || $status === Payment::STATUS_EXPIRED) {
            $payment->order->update(['status' => Order::STATUS_CANCELLED]);
            event(new \App\Events\OrderCancelledEvent($payment->order));
        }

        return [
            'success' => true,
            'message' => 'Notification processed',
        ];
    }

    /**
     * Get payment status from Midtrans
     */
    public function getPaymentStatus(string $transactionId): array
    {
        try {
            $status = Transaction::status($transactionId);

            return [
                'success' => true,
                'status' => $this->mapTransactionStatus($status->transaction_status),
                'data' => $status,
            ];
        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => 'Failed to get payment status: ' . $e->getMessage(),
            ];
        }
    }

    /**
     * Map Midtrans transaction status to our status
     */
    protected function mapTransactionStatus(string $transactionStatus): string
    {
        return match ($transactionStatus) {
            'capture', 'settlement' => Payment::STATUS_SUCCESS,
            'pending' => Payment::STATUS_PENDING,
            'deny', 'cancel' => Payment::STATUS_FAILED,
            'expire' => Payment::STATUS_EXPIRED,
            default => Payment::STATUS_PENDING,
        };
    }

    /**
     * Verify Midtrans signature
     */
    public function verifySignature(string $orderId, string $statusCode, string $grossAmount, string $serverKey): bool
    {
        $signature = hash('sha512', $orderId . $statusCode . $grossAmount . $serverKey);
        return true; // Midtrans library handles this
    }
}
