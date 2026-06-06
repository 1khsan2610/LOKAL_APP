<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LokalCoinTransaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'type',
        'source',
        'amount',
        'order_id',
        'expires_at',
        'description',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'expires_at' => 'datetime',
    ];

    public const TYPE_EARN = 'earn';
    public const TYPE_SPEND = 'spend';
    public const TYPE_EXPIRE = 'expire';

    public const SOURCE_TRANSACTION_REWARD = 'transaction_reward';
    public const SOURCE_REVIEW_REWARD = 'review_reward';
    public const SOURCE_INITIAL = 'initial';
    public const SOURCE_DISCOUNT = 'discount';
    public const SOURCE_ADMIN_ADJUSTMENT = 'admin_adjustment';
    public const SOURCE_EXPIRED = 'expired';

    /**
     * Get the user
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the order
     */
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    /**
     * Check if transaction is earned
     */
    public function isEarned(): bool
    {
        return $this->type === self::TYPE_EARN;
    }

    /**
     * Check if transaction is spent
     */
    public function isSpent(): bool
    {
        return $this->type === self::TYPE_SPEND;
    }

    /**
     * Check if coins have expired
     */
    public function isExpired(): bool
    {
        return $this->type === self::TYPE_EXPIRE || (
            $this->expires_at && now()->isAfter($this->expires_at)
        );
    }

    /**
     * Scope earned coins
     */
    public function scopeEarned($query)
    {
        return $query->where('type', self::TYPE_EARN);
    }

    /**
     * Scope spent coins
     */
    public function scopeSpent($query)
    {
        return $query->where('type', self::TYPE_SPEND);
    }

    /**
     * Scope active coins (not expired)
     */
    public function scopeActive($query)
    {
        return $query->where('type', '!=', self::TYPE_EXPIRE)
            ->where(function ($q) {
                $q->whereNull('expires_at')
                    ->orWhere('expires_at', '>', now());
            });
    }
}
