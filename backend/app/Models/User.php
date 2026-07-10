<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'name', 'email', 'password', 'phone',
        'role', 'avatar', 'is_active', 'email_verified_at',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password'          => 'hashed',
        'is_active'         => 'boolean',
    ];

    // JWT interface
    public function getJWTIdentifier() { return $this->getKey(); }
    public function getJWTCustomClaims() { return ['role' => $this->role]; }

    // Relations
    public function umkm()       { return $this->hasOne(Umkm::class); }
    public function wallet()     { return $this->hasOne(Wallet::class); }
    public function addresses()  { return $this->hasMany(Address::class); }
    public function orders()     { return $this->hasMany(Order::class); }
    public function cart()       { return $this->hasMany(Cart::class); }
    public function reviews()    { return $this->hasMany(Review::class); }
    public function notifications() { return $this->hasMany(Notification::class); }

    public function isAdmin()    { return $this->role === 'admin'; }
    public function isUmkm()     { return $this->role === 'umkm'; }
    public function isKonsumen() { return $this->role === 'konsumen'; }
}
