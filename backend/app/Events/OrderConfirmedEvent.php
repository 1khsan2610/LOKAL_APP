<?php

namespace App\Events;

use App\Models\Order;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithBroadcasting;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class OrderConfirmedEvent
{
    use Dispatchable, InteractsWithBroadcasting, SerializesModels;

    public function __construct(public Order $order)
    {
    }

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('user.' . $this->order->consumer_id),
            new PrivateChannel('umkm.' . $this->order->umkm_id),
        ];
    }
}
