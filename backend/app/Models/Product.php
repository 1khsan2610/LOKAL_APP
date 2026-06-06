<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'umkm_id',
        'name',
        'description',
        'category',
        'price',
        'cost_price',
        'stock',
        'weight',
        'attributes',
        'rating',
        'total_reviews',
        'total_sold',
        'is_active',
        'last_restocked_at',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'cost_price' => 'decimal:2',
        'rating' => 'decimal:2',
        'attributes' => 'json',
        'is_active' => 'boolean',
        'last_restocked_at' => 'datetime',
    ];

    /**
     * Get the UMKM that owns this product
     */
    public function umkm(): BelongsTo
    {
        return $this->belongsTo(UmkmProfile::class);
    }

    /**
     * Get product images
     */
    public function images(): HasMany
    {
        return $this->hasMany(ProductImage::class)->orderBy('sort_order');
    }

    /**
     * Get order items for this product
     */
    public function orderItems(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    /**
     * Get reviews for this product
     */
    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    /**
     * Check if stock is low
     */
    public function isLowStock(): bool
    {
        return $this->stock < 10;
    }

    /**
     * Update product rating from reviews
     */
    public function updateRating(): void
    {
        $avgRating = $this->reviews()->avg('rating');
        $this->update([
            'rating' => $avgRating ?? 5.0,
            'total_reviews' => $this->reviews()->count(),
        ]);
    }

    /**
     * Get first product image
     */
    public function getFirstImageAttribute(): ?ProductImage
    {
        return $this->images()->first();
    }

    /**
     * Scope active products
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope by category
     */
    public function scopeByCategory($query, $category)
    {
        return $query->where('category', $category);
    }
}
