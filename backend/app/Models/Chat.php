<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Chat extends Model
{
    use HasFactory;

    protected $fillable = [
        'sender_id',
        'receiver_id',
        'product_id',
        'last_message',
        'last_message_at',
        'unread_count',
    ];

    protected $casts = [
        'last_message_at' => 'datetime',
    ];

    // ── Relasi ──────────────────────────────────────────────────────
    public function sender()
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function receiver()
    {
        return $this->belongsTo(User::class, 'receiver_id');
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function messages()
    {
        return $this->hasMany(Message::class);
    }

    // ── Helper: ambil user lain dalam chat ──────────────────────────
    public function otherUser(int $currentUserId): User
    {
        return $this->sender_id === $currentUserId
            ? $this->receiver
            : $this->sender;
    }

    // ── Scope: chat yang melibatkan user tertentu ───────────────────
    public function scopeInvolvingUser($query, int $userId)
    {
        return $query->where('sender_id', $userId)
            ->orWhere('receiver_id', $userId);
    }
}