<?php

namespace App\Services;

use App\Models\LokalCoinBalance;
use App\Models\LokalCoinTransaction;
use App\Models\Order;
use App\Models\Review;
use App\Models\User;

class LokalCoinService
{
    /**
     * Award coins for completed transaction (2% reward)
     */
    public function awardTransactionReward(Order $order): LokalCoinTransaction
    {
        $rewardAmount = $order->subtotal * 0.02; // 2% reward

        $balance = LokalCoinBalance::firstOrCreate(
            ['user_id' => $order->consumer_id],
            ['balance' => 0, 'total_earned' => 0, 'total_spent' => 0]
        );

        return $balance->addCoins(
            $rewardAmount,
            LokalCoinTransaction::SOURCE_TRANSACTION_REWARD,
            "Reward dari transaksi #{$order->order_number}",
            $order->id
        );
    }

    /**
     * Award coins for review (5 coins per review)
     */
    public function awardReviewReward(Review $review): LokalCoinTransaction
    {
        $rewardAmount = 5;

        $balance = LokalCoinBalance::firstOrCreate(
            ['user_id' => $review->consumer_id],
            ['balance' => 0, 'total_earned' => 0, 'total_spent' => 0]
        );

        return $balance->addCoins(
            $rewardAmount,
            LokalCoinTransaction::SOURCE_REVIEW_REWARD,
            "Reward dari ulasan produk #{$review->product_id}",
            $review->order_id
        );
    }

    /**
     * Use coins for order discount (max 20% of order amount)
     */
    public function useCoinsForDiscount(Order $order, float $coinAmount): array
    {
        $balance = LokalCoinBalance::where('user_id', $order->consumer_id)->first();

        if (!$balance) {
            return [
                'success' => false,
                'message' => 'Dompet tidak ditemukan.',
            ];
        }

        if ($balance->balance < $coinAmount) {
            return [
                'success' => false,
                'message' => 'Saldo Lokal Coin tidak cukup.',
                'balance' => $balance->balance,
            ];
        }

        // Check max 20% rule
        $maxDiscount = $order->subtotal * 0.20;
        if ($coinAmount > $maxDiscount) {
            return [
                'success' => false,
                'message' => "Diskon maksimal 20% dari total belanja (Rp " . number_format($maxDiscount, 0, ',', '.') . ")",
                'max_discount' => $maxDiscount,
            ];
        }

        $balance->deductCoins(
            $coinAmount,
            LokalCoinTransaction::SOURCE_DISCOUNT,
            "Diskon untuk transaksi #{$order->order_number}",
            $order->id
        );

        return [
            'success' => true,
            'message' => 'Lokal Coin digunakan untuk diskon.',
            'remaining_balance' => $balance->balance - $coinAmount,
        ];
    }

    /**
     * Expire coins that are past their 6-month expiration date
     */
    public function expireCoins(User $user): int
    {
        $expiredTransactions = LokalCoinTransaction::where('user_id', $user->id)
            ->where('type', LokalCoinTransaction::TYPE_EARN)
            ->where('expires_at', '<', now())
            ->where('created_at', '<', now()->subMonths(6))
            ->get();

        $totalExpired = 0;
        foreach ($expiredTransactions as $transaction) {
            if ($transaction->isExpired()) {
                // Deduct from balance
                $balance = LokalCoinBalance::where('user_id', $user->id)->first();
                if ($balance && $balance->balance >= $transaction->amount) {
                    $balance->decrement('balance', $transaction->amount);

                    // Log expiration
                    LokalCoinTransaction::create([
                        'user_id' => $user->id,
                        'type' => LokalCoinTransaction::TYPE_EXPIRE,
                        'source' => LokalCoinTransaction::SOURCE_EXPIRED,
                        'amount' => $transaction->amount,
                        'description' => "Koin hangus (berlaku sampai {$transaction->expires_at})",
                    ]);

                    $totalExpired += $transaction->amount;
                }
            }
        }

        return (int) $totalExpired;
    }

    /**
     * Send notification 30 days before expiration
     */
    public function notifyExpiringCoins(User $user): int
    {
        $expiringDate = now()->addDays(30);

        $expiringTransactions = LokalCoinTransaction::where('user_id', $user->id)
            ->where('type', LokalCoinTransaction::TYPE_EARN)
            ->whereBetween('expires_at', [now()->addDays(29), $expiringDate])
            ->get();

        $totalExpiring = 0;
        foreach ($expiringTransactions as $transaction) {
            $totalExpiring += $transaction->amount;
        }

        if ($totalExpiring > 0) {
            // Create notification
            \App\Models\Notification::create([
                'user_id' => $user->id,
                'title' => 'Lokal Coin akan Hangus',
                'body' => "Rp " . number_format($totalExpiring, 0, ',', '.') . " Lokal Coin Anda akan hangus dalam 30 hari. Gunakan sekarang!",
                'type' => \App\Models\Notification::TYPE_PROMOTION,
            ]);
        }

        return (int) $totalExpiring;
    }

    /**
     * Get user's coin balance
     */
    public function getBalance(User $user): LokalCoinBalance
    {
        return LokalCoinBalance::firstOrCreate(
            ['user_id' => $user->id],
            ['balance' => 0, 'total_earned' => 0, 'total_spent' => 0]
        );
    }

    /**
     * Get coin transactions history
     */
    public function getTransactionHistory(User $user, int $limit = 50)
    {
        return LokalCoinTransaction::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get();
    }
}
