<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Review extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'order_id',
        'product_id',
        'consumer_id',
        'umkm_id',
        'rating',
        'comment',
        'is_verified_purchase',
    ];

    protected $casts = [
        'is_verified_purchase' => 'boolean',
    ];

    /**
     * Get the order
     */
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    /**
     * Get the product
     */
    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    /**
     * Get the consumer
     */
    public function consumer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'consumer_id');
    }

    /**
     * Get the UMKM
     */
    public function umkm(): BelongsTo
    {
        return $this->belongsTo(UmkmProfile::class);
    }

    /**
     * Get star rating text
     */
    public function getStarTextAttribute(): string
    {
        return $this->rating . ' bintang';
    }

    /**
     * Scope by rating
     */
    public function scopeByRating($query, $rating)
    {
        return $query->where('rating', $rating);
    }

    /**
     * Scope positive reviews (4+ stars)
     */
    public function scopePositive($query)
    {
        return $query->where('rating', '>=', 4);
    }

    /**
     * Scope negative reviews (< 3 stars)
     */
    public function scopeNegative($query)
    {
        return $query->where('rating', '<', 3);
    }
}
