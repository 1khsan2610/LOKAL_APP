<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class PriceRecommendation extends Model
{
    use HasFactory, SoftDeletes;

    // Status constants
    public const STATUS_PENDING = 'pending';
    public const STATUS_PROCESSING = 'processing';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_FAILED = 'failed';

    protected $table = 'price_recommendations';

    protected $fillable = [
        'product_id',
        'umkm_id',
        'ml_request_data',
        'ml_response_data',
        'current_price',
        'recommended_price',
        'confidence_score',
        'recommendation_reason',
        'market_analysis',
        'competitive_products',
        'status',
        'external_request_id',
        'error_message',
        'processed_at',
    ];

    protected $casts = [
        'current_price' => 'decimal:2',
        'recommended_price' => 'decimal:2',
        'confidence_score' => 'decimal:4',
        'ml_request_data' => 'json',
        'ml_response_data' => 'json',
        'market_analysis' => 'json',
        'competitive_products' => 'json',
        'processed_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    /**
     * Get the product associated with this recommendation
     */
    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    /**
     * Get the UMKM associated with this recommendation
     */
    public function umkm(): BelongsTo
    {
        return $this->belongsTo(UmkmProfile::class, 'umkm_id');
    }

    /**
     * Scope to completed recommendations
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', self::STATUS_COMPLETED);
    }

    /**
     * Scope to pending recommendations
     */
    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    /**
     * Scope to recent recommendations (within 24 hours)
     */
    public function scopeRecent($query)
    {
        return $query->where('created_at', '>', now()->subHours(24));
    }

    /**
     * Get price increase percentage
     */
    public function getPriceIncreasePercentage(): float
    {
        if ($this->current_price == 0) {
            return 0;
        }

        return (($this->recommended_price - $this->current_price) / $this->current_price) * 100;
    }

    /**
     * Check if recommendation suggests price increase
     */
    public function suggestsPriceIncrease(): bool
    {
        return $this->recommended_price > $this->current_price;
    }

    /**
     * Check if recommendation suggests price decrease
     */
    public function suggestsPriceDecrease(): bool
    {
        return $this->recommended_price < $this->current_price;
    }

    /**
     * Get high confidence recommendations
     */
    public function isHighConfidence(): bool
    {
        return $this->confidence_score >= 0.75;
    }

    /**
     * Get market analysis as readable text
     */
    public function getMarketAnalysisText(): string
    {
        $analysis = $this->market_analysis;
        if (!$analysis) {
            return 'Tidak ada analisis pasar tersedia';
        }

        $text = [];
        if (isset($analysis['avg_market_price'])) {
            $text[] = "Harga pasar rata-rata: Rp " . number_format($analysis['avg_market_price'], 0, ',', '.');
        }
        if (isset($analysis['min_price'])) {
            $text[] = "Harga terendah: Rp " . number_format($analysis['min_price'], 0, ',', '.');
        }
        if (isset($analysis['max_price'])) {
            $text[] = "Harga tertinggi: Rp " . number_format($analysis['max_price'], 0, ',', '.');
        }
        if (isset($analysis['demand_level'])) {
            $text[] = "Tingkat permintaan: " . ucfirst($analysis['demand_level']);
        }

        return implode('; ', $text);
    }
}
