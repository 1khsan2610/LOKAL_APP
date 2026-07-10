<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TrackingLog extends Model
{
    use HasFactory;

    protected $table = 'order_tracks';

    protected $fillable = [
        'order_id',
        'status',
        'description',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}
