<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'order_number' => $this->order_number,
            'consumer' => new UserResource($this->whenLoaded('consumer')),
            'umkm' => new UmkmProfileResource($this->whenLoaded('umkm')),
            'status' => $this->status,
            'items' => OrderItemResource::collection($this->whenLoaded('items')),
            'subtotal' => (float) $this->subtotal,
            'lokal_coin_amount' => (float) $this->lokal_coin_amount,
            'lokal_coin_discount' => (float) $this->lokal_coin_discount,
            'total_amount' => (float) $this->total_amount,
            'delivery_address' => $this->delivery_address,
            'notes' => $this->notes,
            'payment' => new PaymentResource($this->whenLoaded('payment')),
            'reviews' => ReviewResource::collection($this->whenLoaded('reviews')),
            'confirmed_at' => $this->confirmed_at,
            'completed_at' => $this->completed_at,
            'cancelled_at' => $this->cancelled_at,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
