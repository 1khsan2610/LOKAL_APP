<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Order extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'order_number',
        'consumer_id',
        'umkm_id',
        'subtotal',
        'lokal_coin_discount',
        'lokal_coin_amount',
        'total_amount',
        'status',
        'delivery_address',
        'delivery_location',
        'notes',
        'confirmed_at',
        'completed_at',
        'cancelled_at',
    ];

    protected $casts = [
        'subtotal' => 'decimal:2',
        'lokal_coin_discount' => 'decimal:2',
        'lokal_coin_amount' => 'decimal:2',
        'total_amount' => 'decimal:2',
        'confirmed_at' => 'datetime',
        'completed_at' => 'datetime',
        'cancelled_at' => 'datetime',
    ];

    public const STATUS_PENDING = 'pending';
    public const STATUS_CONFIRMED = 'confirmed';
    public const STATUS_PROCESSING = 'processing';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_CANCELLED = 'cancelled';
    public const STATUS_REFUNDED = 'refunded';

    /**
     * Get the consumer that made the order
     */
    public function consumer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'consumer_id');
    }

    /**
     * Get the UMKM that received the order
     */
    public function umkm(): BelongsTo
    {
        return $this->belongsTo(UmkmProfile::class);
    }

    /**
     * Get order items
     */
    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    /**
     * Get payment details
     */
    public function payment(): HasOne
    {
        return $this->hasOne(Payment::class);
    }

    /**
     * Get reviews for items in this order
     */
    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    /**
     * Generate unique order number
     */
    public static function generateOrderNumber(): string
    {
        return 'ORD-' . date('YmdHis') . '-' . random_int(1000, 9999);
    }

    /**
     * Check if order is pending
     */
    public function isPending(): bool
    {
        return $this->status === self::STATUS_PENDING;
    }

    /**
     * Check if order is completed
     */
    public function isCompleted(): bool
    {
        return $this->status === self::STATUS_COMPLETED;
    }

    /**
     * Check if order can be reviewed
     */
    public function canBeReviewed(): bool
    {
        return $this->isCompleted() && $this->reviews()->count() === 0;
    }

    /**
     * Get order total including lokal coin discount
     */
    public function getTotalAttribute(): float
    {
        return (float) $this->total_amount;
    }

    /**
     * Scope pending orders
     */
    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    /**
     * Scope completed orders
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', self::STATUS_COMPLETED);
    }
}
