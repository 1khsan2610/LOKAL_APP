<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
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
            'umkm_id' => $this->umkm_id,
            'umkm' => new UmkmProfileResource($this->whenLoaded('umkm')),
            'name' => $this->name,
            'description' => $this->description,
            'category' => $this->category,
            'price' => (float) $this->price,
            'cost_price' => (float) $this->cost_price,
            'stock' => $this->stock,
            'weight' => $this->weight,
            'attributes' => $this->attributes,
            'rating' => (float) $this->rating,
            'total_reviews' => $this->total_reviews,
            'total_sold' => $this->total_sold,
            'is_active' => $this->is_active,
            'images' => ProductImageResource::collection($this->whenLoaded('images')),
            'is_low_stock' => $this->isLowStock(),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
