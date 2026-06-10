<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UmkmNearbyResource extends JsonResource
{
    /**
     * Transform the resource into an array for nearby UMKM map endpoint
     * Includes distance and product categories
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        // Get product categories for this UMKM
        $categories = $this->products()
            ->distinct()
            ->pluck('category')
            ->filter()
            ->take(3)
            ->toArray();

        // Get first product image as thumbnail
        $thumbnail = $this->products()
            ->with('images')
            ->whereHas('images')
            ->first()
            ?->images()
            ?->first()
            ?->image_url;

        // Extract coordinates from POINT
        $latitude = null;
        $longitude = null;

        if ($this->coordinates) {
            $coords = $this->coordinates;
            
            // Handle different POINT formats
            if (is_object($coords) && method_exists($coords, 'getLat')) {
                $latitude = $coords->getLat();
                $longitude = $coords->getLng();
            } elseif (is_string($coords)) {
                // Handle WKT format: POINT(lng lat) or POINT(lat lng)
                preg_match('/POINT\(([^ ]+) ([^ ]+)\)/', $coords, $matches);
                if (count($matches) === 3) {
                    $longitude = (float) $matches[1];
                    $latitude = (float) $matches[2];
                }
            }
        }

        return [
            'id' => $this->id,
            'business_name' => $this->business_name,
            'categories' => $categories,
            'rating' => (float) $this->rating,
            'total_reviews' => $this->total_reviews,
            'coordinates' => [
                'latitude' => $latitude,
                'longitude' => $longitude,
            ],
            'distance_km' => round((float) ($this->distance ?? 0), 2),
            'thumbnail' => $thumbnail,
            'is_verified' => $this->isVerified(),
        ];
    }
}

