<?php

namespace App\Listeners;

use App\Events\OrderCompletedEvent;
use App\Models\Notification;
use App\Services\LokalCoinService;

class AwardTransactionReward
{
    public function __construct(protected LokalCoinService $lokalCoinService)
    {
    }

    public function handle(OrderCompletedEvent $event): void
    {
        $order = $event->order;

        // Award 2% coins to consumer
        $this->lokalCoinService->awardTransactionReward($order);

        // Create notification
        $reward = $order->subtotal * 0.02;

        Notification::create([
            'user_id' => $order->consumer_id,
            'title' => 'Bonus Lokal Coin Diterima',
            'body' => 'Anda mendapat ' . number_format($reward, 0, ',', '.') . ' Lokal Coin dari transaksi ini!',
            'type' => Notification::TYPE_PROMOTION,
            'order_id' => $order->id,
        ]);

        // Notify UMKM that order is completed
        Notification::create([
            'user_id' => $order->umkm->user_id,
            'title' => 'Pesanan Selesai',
            'body' => "Pesanan #{$order->order_number} dari {$order->consumer->name} telah selesai.",
            'type' => Notification::TYPE_ORDER,
            'order_id' => $order->id,
        ]);
    }
}
