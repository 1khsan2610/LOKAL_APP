<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class UmkmProfile extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'umkm_profiles';

    protected $fillable = [
        'user_id',
        'business_name',
        'business_description',
        'nib',
        'siup',
        'nib_document_url',
        'siup_document_url',
        'owner_name',
        'owner_phone_number',
        'bank_name',
        'bank_account_number',
        'bank_account_holder_name',
        'rating',
        'total_reviews',
        'total_products',
        'total_orders',
        'verified_at',
    ];

    protected $casts = [
        'verified_at' => 'datetime',
    ];

    /**
     * Get the user that owns the UMKM profile
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get all products from this UMKM
     */
    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }

    /**
     * Get all orders to this UMKM
     */
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    /**
     * Get all reviews for this UMKM
     */
    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    /**
     * Check if UMKM is verified
     */
    public function isVerified(): bool
    {
        return $this->verified_at !== null;
    }

    /**
     * Update UMKM rating from reviews
     */
    public function updateRating(): void
    {
        $avgRating = $this->reviews()->avg('rating');
        $this->update([
            'rating' => $avgRating ?? 5.0,
            'total_reviews' => $this->reviews()->count(),
        ]);
    }
}
