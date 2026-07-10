<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notification extends Model {
    use HasFactory;
    protected $fillable = ['user_id','title','body','type','data','is_read'];
    protected $casts = ['is_read'=>'boolean','data'=>'array'];
    public function user() { return $this->belongsTo(User::class); }
}