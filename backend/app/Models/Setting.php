<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Cache;

class Setting extends Model
{
    protected $fillable = [
        'key',
        'value',
        'group',
        'label',
    ];

    /**
     * Get a setting value by key with caching.
     */
    public static function getValue(string $key, mixed $default = null): mixed
    {
        $settings = Cache::remember('settings.all', 3600, function () {
            return self::pluck('value', 'key')->toArray();
        });

        return $settings[$key] ?? $default;
    }

    /**
     * Clear settings cache.
     */
    public static function clearCache(): void
    {
        Cache::forget('settings.all');
    }

    /**
     * Get commission percentage (default 5).
     */
    public static function commissionPercent(): int
    {
        return (int) self::getValue('commission_percent', 5);
    }

    /**
     * Get cashback percentage (default 2).
     */
    public static function cashbackPercent(): int
    {
        return (int) self::getValue('cashback_percent', 2);
    }

    /**
     * Get max coin discount percentage (default 20).
     */
    public static function maxCoinDiscountPercent(): int
    {
        return (int) self::getValue('max_coin_discount_percent', 20);
    }
}