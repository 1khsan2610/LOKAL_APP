<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EmailVerification extends Model
{
    use HasFactory;

    protected $fillable = [
        'email',
        'token',
        'expires_at',
        'verified_at',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'verified_at' => 'datetime',
    ];

    public const EXPIRATION_HOURS = 24;

    /**
     * Check if verification token is expired
     */
    public function isExpired(): bool
    {
        return now()->isAfter($this->expires_at);
    }

    /**
     * Check if email has been verified
     */
    public function isVerified(): bool
    {
        return !is_null($this->verified_at);
    }

    /**
     * Mark email as verified
     */
    public function verify(): void
    {
        $this->update(['verified_at' => now()]);
    }
}
