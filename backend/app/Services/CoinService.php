<?php

namespace App\Services;

use App\Models\Wallet;
use App\Models\CoinTransaction;
use App\Models\Setting;
use Illuminate\Support\Facades\DB;

class CoinService
{
    const COIN_TO_RUPIAH = 10; // 1 Coin = Rp 10

    /**
     * Get max discount percent from settings (fallback 20).
     */
    public static function maxDiscountPercent(): int
    {
        return Setting::maxCoinDiscountPercent();
    }

    /**
     * Add coin to user wallet
     */
    public function add(int $userId, int $amount, string $description, ?int $expiresInDays = 90): void
    {
        if ($amount <= 0) return;

        DB::transaction(function () use ($userId, $amount, $description, $expiresInDays) {
            $wallet = Wallet::lockForUpdate()->where('user_id', $userId)->firstOrFail();
            $wallet->increment('coin_balance', $amount);

            CoinTransaction::create([
                'user_id'      => $userId,
                'type'         => 'credit',
                'amount'       => $amount,
                'description'  => $description,
                'balance_after' => $wallet->fresh()->coin_balance,
                'expires_at'   => $expiresInDays ? now()->addDays($expiresInDays) : null,
            ]);
        });
    }

    /**
     * Deduct coin from user wallet
     */
    public function deduct(int $userId, int $rupiahAmount, string $description): void
    {
        $coinAmount = (int)($rupiahAmount / self::COIN_TO_RUPIAH);
        if ($coinAmount <= 0) return;

        DB::transaction(function () use ($userId, $coinAmount, $description) {
            $wallet = Wallet::lockForUpdate()->where('user_id', $userId)->firstOrFail();

            if ($wallet->coin_balance < $coinAmount) {
                throw new \Exception('Saldo Lokal Coin tidak mencukupi.');
            }

            $wallet->decrement('coin_balance', $coinAmount);

            CoinTransaction::create([
                'user_id'       => $userId,
                'type'          => 'debit',
                'amount'        => $coinAmount,
                'description'   => $description,
                'balance_after' => $wallet->fresh()->coin_balance,
            ]);
        });
    }

    /**
     * Calculate max discount from coin balance for a given subtotal
     */
    public function calculateDiscount(int $coinBalance, int $subtotal): int
    {
        $maxDiscountFromSubtotal = (int)($subtotal * self::maxDiscountPercent() / 100);
        $maxDiscountFromCoin     = $coinBalance * self::COIN_TO_RUPIAH;
        return min($maxDiscountFromSubtotal, $maxDiscountFromCoin);
    }

    /**
     * Remove expired coins
     */
    public function removeExpired(): void
    {
        $expired = CoinTransaction::where('type', 'credit')
            ->where('expires_at', '<', now())
            ->where('is_expired', false)
            ->get();

        foreach ($expired as $txn) {
            // Check remaining valid balance
            $wallet = Wallet::where('user_id', $txn->user_id)->first();
            if ($wallet && $wallet->coin_balance >= $txn->amount) {
                $this->deduct($txn->user_id, $txn->amount * self::COIN_TO_RUPIAH, "Kadaluwarsa: {$txn->description}");
            }
            $txn->update(['is_expired' => true]);
        }
    }
}
