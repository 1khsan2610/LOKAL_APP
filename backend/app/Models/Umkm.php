<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Umkm extends Model {
    use HasFactory;
    protected $fillable = ['user_id','name','slug','category','description','logo','banner','phone','address','city','province','latitude','longitude','avg_rating','total_sold','is_verified','is_active'];
    protected $casts = ['is_verified'=>'boolean','is_active'=>'boolean','avg_rating'=>'float','latitude'=>'float','longitude'=>'float'];
    public function user() { return $this->belongsTo(User::class); }
    public function products() { return $this->hasMany(Product::class); }
}