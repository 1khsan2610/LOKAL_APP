<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'midtrans_transaction_id',
        'midtrans_order_id',
        'payment_method',
        'va_number',
        'qr_string',
        'payment_url',
        'status',
        'amount',
        'midtrans_response',
        'paid_at',
        'expired_at',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'midtrans_response' => 'json',
        'paid_at' => 'datetime',
        'expired_at' => 'datetime',
    ];

    public const STATUS_PENDING = 'pending';
    public const STATUS_SUCCESS = 'success';
    public const STATUS_FAILED = 'failed';
    public const STATUS_EXPIRED = 'expired';
    public const STATUS_CANCELLED = 'cancelled';

    public const PAYMENT_METHOD_GOPAY = 'gopay';
    public const PAYMENT_METHOD_OVO = 'ovo';
    public const PAYMENT_METHOD_DANA = 'dana';
    public const PAYMENT_METHOD_VA_BANK = 'va_bank';
    public const PAYMENT_METHOD_QRIS = 'qris';
    public const PAYMENT_METHOD_LOKAL_COIN = 'lokal_coin';

    /**
     * Get the order
     */
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    /**
     * Check if payment is pending
     */
    public function isPending(): bool
    {
        return $this->status === self::STATUS_PENDING;
    }

    /**
     * Check if payment is successful
     */
    public function isSuccess(): bool
    {
        return $this->status === self::STATUS_SUCCESS;
    }

    /**
     * Check if payment is expired
     */
    public function isExpired(): bool
    {
        return $this->status === self::STATUS_EXPIRED || (
            $this->expired_at && now()->isAfter($this->expired_at)
        );
    }

    /**
     * Scope pending payments
     */
    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    /**
     * Scope successful payments
     */
    public function scopeSuccessful($query)
    {
        return $query->where('status', self::STATUS_SUCCESS);
    }
}
