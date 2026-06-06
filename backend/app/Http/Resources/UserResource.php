<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
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
            'name' => $this->name,
            'email' => $this->email,
            'phone_number' => $this->phone_number,
            'role' => $this->role,
            'address' => $this->address,
            'city' => $this->city,
            'profile_image_url' => $this->profile_image_url,
            'is_verified' => $this->is_verified,
            'verified_at' => $this->verified_at,
            'umkm_profile' => $this->when($this->umkmProfile, fn () => new UmkmProfileResource($this->umkmProfile)),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
