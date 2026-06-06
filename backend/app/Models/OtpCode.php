<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OtpCode extends Model
{
    use HasFactory;

    protected $fillable = [
        'phone_number',
        'code',
        'attempts',
        'is_verified',
        'expires_at',
        'blocked_until',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'blocked_until' => 'datetime',
        'is_verified' => 'boolean',
    ];

    public const MAX_ATTEMPTS = 5;
    public const BLOCK_DURATION_MINUTES = 15;
    public const EXPIRATION_MINUTES = 5;

    /**
     * Check if OTP is expired
     */
    public function isExpired(): bool
    {
        return now()->isAfter($this->expires_at);
    }

    /**
     * Check if OTP code is locked
     */
    public function isLocked(): bool
    {
        return $this->blocked_until && now()->isBefore($this->blocked_until);
    }

    /**
     * Check if OTP has exceeded max attempts
     */
    public function isMaxAttemptsExceeded(): bool
    {
        return $this->attempts >= self::MAX_ATTEMPTS;
    }
}
