<?php

namespace App\Listeners;

use App\Events\OrderConfirmedEvent;
use App\Models\Notification;

class SendOrderConfirmationNotification
{
    public function handle(OrderConfirmedEvent $event): void
    {
        $order = $event->order;

        // Notify consumer that payment is received
        Notification::create([
            'user_id' => $order->consumer_id,
            'title' => 'Pembayaran Diterima',
            'body' => "Pesanan #{$order->order_number} Anda telah dikonfirmasi. Total: Rp " . number_format($order->total_amount, 0, ',', '.'),
            'type' => Notification::TYPE_PAYMENT,
            'order_id' => $order->id,
        ]);

        // Notify UMKM that they received an order
        Notification::create([
            'user_id' => $order->umkm->user_id,
            'title' => 'Pesanan Baru Diterima',
            'body' => "Pesanan baru dari {$order->consumer->name} - Rp " . number_format($order->total_amount, 0, ',', '.'),
            'type' => Notification::TYPE_ORDER,
            'order_id' => $order->id,
        ]);

        // TODO: Trigger n8n workflow for SMS notification
    }
}
