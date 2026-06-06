<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UmkmProfileResource extends JsonResource
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
            'business_name' => $this->business_name,
            'business_description' => $this->business_description,
            'nib' => $this->nib,
            'siup' => $this->siup,
            'nib_document_url' => $this->nib_document_url,
            'siup_document_url' => $this->siup_document_url,
            'owner_name' => $this->owner_name,
            'owner_phone_number' => $this->owner_phone_number,
            'bank_name' => $this->bank_name,
            'bank_account_number' => $this->bank_account_number,
            'bank_account_holder_name' => $this->bank_account_holder_name,
            'rating' => $this->rating,
            'total_reviews' => $this->total_reviews,
            'total_products' => $this->total_products,
            'total_orders' => $this->total_orders,
            'is_verified' => $this->isVerified(),
            'verified_at' => $this->verified_at,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
