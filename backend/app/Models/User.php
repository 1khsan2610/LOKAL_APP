<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'phone_number',
        'password',
        'role',
        'address',
        'location',
        'city',
        'profile_image_url',
        'is_verified',
        'verified_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'verified_at' => 'datetime',
        'password' => 'hashed',
        'is_verified' => 'boolean',
    ];

    /**
     * Get UMKM profile if user is UMKM
     */
    public function umkmProfile(): HasOne
    {
        return $this->hasOne(UmkmProfile::class);
    }

    /**
     * Get consumer orders
     */
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class, 'consumer_id');
    }

    /**
     * Get user's notifications
     */
    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }

    /**
     * Get user's reviews
     */
    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class, 'consumer_id');
    }

    /**
     * Get user's Lokal Coin balance
     */
    public function lokalCoinBalance(): HasOne
    {
        return $this->hasOne(LokalCoinBalance::class);
    }

    /**
     * Get user's Lokal Coin transactions
     */
    public function lokalCoinTransactions(): HasMany
    {
        return $this->hasMany(LokalCoinTransaction::class);
    }

    /**
     * Check if user is UMKM
     */
    public function isUmkm(): bool
    {
        return $this->role === 'umkm';
    }

    /**
     * Check if user is consumer
     */
    public function isConsumer(): bool
    {
        return $this->role === 'consumer';
    }
}
