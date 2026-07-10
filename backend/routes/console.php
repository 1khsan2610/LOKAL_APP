<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;
use App\Services\CoinService;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote')->hourly();

// Schedule: Remove expired coins daily at midnight
Schedule::call(function () {
    app(CoinService::class)->removeExpired();
})->daily()->name('remove-expired-coins');

// Schedule: Send low stock alerts to UMKM
Schedule::command('notify:low-stock')->daily()->at('08:00');
