<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model {
    use HasFactory;
    protected $fillable = ['order_number','user_id','address_id','status','subtotal','shipping_fee','shipping_method','tracking_number','coin_discount','total','notes','seller_notes','delivered_at'];
    protected $casts = ['delivered_at'=>'datetime'];
    public function user() { return $this->belongsTo(User::class); }
    public function address() { return $this->belongsTo(Address::class); }
    public function items() { return $this->hasMany(OrderItem::class); }
    public function payment() { return $this->hasOne(Payment::class); }
}