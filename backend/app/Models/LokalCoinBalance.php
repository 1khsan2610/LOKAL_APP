<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LokalCoinBalance extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'balance',
        'total_earned',
        'total_spent',
    ];

    protected $casts = [
        'balance' => 'decimal:2',
        'total_earned' => 'decimal:2',
        'total_spent' => 'decimal:2',
    ];

    /**
     * Get the user
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Add coins to balance
     */
    public function addCoins(float $amount, string $source, ?string $description = null, ?int $orderId = null): LokalCoinTransaction
    {
        $this->increment('balance', $amount);
        $this->increment('total_earned', $amount);

        return LokalCoinTransaction::create([
            'user_id' => $this->user_id,
            'type' => 'earn',
            'source' => $source,
            'amount' => $amount,
            'order_id' => $orderId,
            'description' => $description,
            'expires_at' => now()->addMonths(6), // Coins expire after 6 months
        ]);
    }

    /**
     * Deduct coins from balance
     */
    public function deductCoins(float $amount, string $source, ?string $description = null, ?int $orderId = null): LokalCoinTransaction
    {
        if ($this->balance < $amount) {
            throw new \Exception('Insufficient Lokal Coin balance');
        }

        $this->decrement('balance', $amount);
        $this->increment('total_spent', $amount);

        return LokalCoinTransaction::create([
            'user_id' => $this->user_id,
            'type' => 'spend',
            'source' => $source,
            'amount' => $amount,
            'order_id' => $orderId,
            'description' => $description,
        ]);
    }

    /**
     * Check if user has enough coins
     */
    public function hasEnoughCoins(float $amount): bool
    {
        return $this->balance >= $amount;
    }
}
