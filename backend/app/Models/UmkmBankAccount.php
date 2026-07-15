<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UmkmBankAccount extends Model
{
    protected $fillable = [
        'umkm_id',
        'bank_name',
        'account_number',
        'account_holder',
        'status',
        'rejection_reason',
        'verified_at',
        'verified_by',
    ];

    protected $casts = [
        'verified_at' => 'datetime',
    ];

    public function umkm()
    {
        return $this->belongsTo(Umkm::class);
    }

    public function verifier()
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeApproved($query)
    {
        return $query->where('status', 'approved');
    }
}