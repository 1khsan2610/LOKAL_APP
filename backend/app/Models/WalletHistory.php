<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WalletHistory extends Model
{
    use HasFactory;

    protected $fillable = [
        'wallet_id',
        'type',
        'balance_type',
        'amount',
        'balance_before',
        'balance_after',
        'description',
        'reference_type',
        'reference_id',
    ];

    protected $casts = [
        'amount'        => 'integer',
        'balance_before' => 'integer',
        'balance_after'  => 'integer',
    ];

    public function wallet()
    {
        return $this->belongsTo(Wallet::class);
    }
}