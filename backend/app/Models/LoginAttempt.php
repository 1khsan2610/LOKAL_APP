<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class LoginAttempt extends Model
{
    use HasFactory;

    protected $fillable = [
        'email',
        'ip_address',
        'attempts',
        'blocked_until',
    ];

    protected $casts = [
        'blocked_until' => 'datetime',
    ];

    const MAX_ATTEMPTS = 5;
    const BLOCK_DURATION_MINUTES = 15;

    /**
     * Check if login is blocked
     */
    public function isBlocked(): bool
    {
        return $this->blocked_until && now() < $this->blocked_until;
    }

    /**
     * Check if max attempts exceeded
     */
    public function isMaxAttemptsExceeded(): bool
    {
        return $this->attempts >= self::MAX_ATTEMPTS;
    }

    /**
     * Get or create login attempt record
     */
    public static function getOrCreate(string $email, ?string $ipAddress = null): self
    {
        return self::firstOrCreate(
            ['email' => $email],
            ['ip_address' => $ipAddress]
        );
    }

    /**
     * Reset attempts
     */
    public function resetAttempts(): void
    {
        $this->update([
            'attempts' => 0,
            'blocked_until' => null,
        ]);
    }

    /**
     * Increment attempts and block if necessary
     */
    public function incrementAttempts(): void
    {
        $this->increment('attempts');
        
        if ($this->isMaxAttemptsExceeded()) {
            $this->update([
                'blocked_until' => now()->addMinutes(self::BLOCK_DURATION_MINUTES),
            ]);
        }
    }
}
