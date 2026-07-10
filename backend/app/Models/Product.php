<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'umkm_id','name','slug','description','price','stock',
        'category','weight','is_active','sold_count','avg_rating',
        'flash_sale_price','flash_sale_discount','flash_sale_ends_at',
    ];

    protected $casts = [
        'price'              => 'integer',
        'stock'              => 'integer',
        'sold_count'         => 'integer',
        'avg_rating'         => 'float',
        'is_active'          => 'boolean',
        'flash_sale_price'   => 'integer',
        'flash_sale_discount'=> 'integer',
        'flash_sale_ends_at' => 'datetime',
    ];

    public function umkm()    { return $this->belongsTo(Umkm::class); }
    public function images()  { return $this->hasMany(ProductImage::class)->orderBy('is_primary','desc'); }
    public function variants(){ return $this->hasMany(ProductVariant::class); }
    public function reviews() { return $this->hasMany(Review::class); }
    public function cartItems(){ return $this->hasMany(Cart::class); }
    public function orderItems(){ return $this->hasMany(OrderItem::class); }

    public function getPrimaryImageAttribute()
    {
        return $this->images->where('is_primary', true)->first()?->url
            ?? $this->images->first()?->url
            ?? null;
    }
}
