<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PaymentResource extends JsonResource
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
            'midtrans_transaction_id' => $this->midtrans_transaction_id,
            'payment_method' => $this->payment_method,
            'va_number' => $this->va_number,
            'qr_string' => $this->qr_string,
            'payment_url' => $this->payment_url,
            'status' => $this->status,
            'amount' => (float) $this->amount,
            'paid_at' => $this->paid_at,
            'expired_at' => $this->expired_at,
            'created_at' => $this->created_at,
        ];
    }
}
