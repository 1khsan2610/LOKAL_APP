<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CoinTransaction extends Model {
    use HasFactory;
    protected $fillable = ['user_id','type','amount','description','balance_after','expires_at','is_expired'];
    protected $casts = ['expires_at'=>'datetime','is_expired'=>'boolean'];
    public function user() { return $this->belongsTo(User::class); }
}