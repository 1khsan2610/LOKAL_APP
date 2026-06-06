<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class LokalCoinTransactionResource extends JsonResource
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
            'user_id' => $this->user_id,
            'type' => $this->type,
            'source' => $this->source,
            'amount' => (float) $this->amount,
            'order_id' => $this->order_id,
            'description' => $this->description,
            'expires_at' => $this->expires_at,
            'created_at' => $this->created_at,
        ];
    }
}
