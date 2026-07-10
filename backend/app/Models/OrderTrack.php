<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderTrack extends Model
{
    use HasFactory;

    // Menentukan kolom apa saja yang boleh diisi melalui API / Controller
    protected $fillable = [
        'order_id',
        'status',
        'description',
    ];

    // Hubungan relasi balik ke data Order utama
    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}