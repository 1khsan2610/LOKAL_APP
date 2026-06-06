<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReviewResource extends JsonResource
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
            'order_id' => $this->order_id,
            'product_id' => $this->product_id,
            'consumer' => new UserResource($this->whenLoaded('consumer')),
            'rating' => $this->rating,
            'comment' => $this->comment,
            'is_verified_purchase' => $this->is_verified_purchase,
            'created_at' => $this->created_at,
        ];
    }
}
