<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payment extends Model {
    use HasFactory;
    protected $fillable = ['order_id','snap_token','snap_url','transaction_id','payment_method','status','amount','paid_at','expired_at','raw_response'];
    protected $casts = ['paid_at'=>'datetime','expired_at'=>'datetime','raw_response'=>'array'];
    public function order() { return $this->belongsTo(Order::class); }
}