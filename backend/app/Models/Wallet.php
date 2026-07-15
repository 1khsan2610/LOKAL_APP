<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class Wallet extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'coin_balance',
        'cash_balance',
        'commission_balance',
    ];

    protected $casts = [
        'coin_balance'      => 'integer',
        'cash_balance'      => 'integer',
        'commission_balance' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function transactions()
    {
        return $this->hasMany(CoinTransaction::class, 'user_id', 'user_id');
    }

    public function histories()
    {
        return $this->hasMany(WalletHistory::class);
    }

    /**
     * Add a transparent movement record to wallet_histories.
     *
     * @param string  $type         'credit' or 'debit'
     * @param string  $balanceType  'coin', 'cash', or 'commission'
     * @param int     $amount       Amount in rupiah (or coin units)
     * @param string  $description  Human-readable description
     * @param string|null $refType  Reference type (e.g. 'order', 'withdrawal')
     * @param int|null    $refId    Reference ID
     */
    public function recordHistory(
        string $type,
        string $balanceType,
        int $amount,
        string $description,
        ?string $refType = null,
        ?int $refId = null
    ): WalletHistory {
        $column = match ($balanceType) {
            'coin'       => 'coin_balance',
            'cash'       => 'cash_balance',
            'commission' => 'commission_balance',
            default      => throw new \InvalidArgumentException("Invalid balance_type: {$balanceType}"),
        };

        $balanceBefore = $this->{$column};

        return $this->histories()->create([
            'type'           => $type,
            'balance_type'   => $balanceType,
            'amount'         => $amount,
            'balance_before' => $balanceBefore,
            'balance_after'  => $type === 'credit' ? $balanceBefore + $amount : $balanceBefore - $amount,
            'description'    => $description,
            'reference_type' => $refType,
            'reference_id'   => $refId,
        ]);
    }
}
