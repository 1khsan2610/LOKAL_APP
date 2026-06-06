<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\PaymentWebhookController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\UmkmController;
use App\Http\Controllers\Api\WalletController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes - Platform LOKAL v1
|--------------------------------------------------------------------------
|
| Base URL: /api/v1
| Authentication: Bearer Token (JWT/Sanctum)
|
*/

// Debug route
Route::get('test', function () {
    return response()->json(['message' => 'API is working!', 'time' => now()]);
});

// Debug POST route
Route::post('test-post', function () {
    return response()->json(['message' => 'POST is working!', 'data' => request()->all()]);
});

// ==================== Public Routes ====================
Route::prefix('auth')->group(function () {
    Route::post('request-otp', [AuthController::class, 'requestOtp']);
    Route::post('verify-otp', [AuthController::class, 'verifyOtp']);
    Route::post('refresh', [AuthController::class, 'refresh']);
});

// Payment webhooks (public, but signature verified)
Route::prefix('payments')->group(function () {
    Route::post('midtrans-webhook', [PaymentWebhookController::class, 'midtransWebhook']);
});

// Get nearby UMKM for map (public)
Route::get('umkm/nearby', [UmkmController::class, 'nearby']);
Route::get('umkm', [UmkmController::class, 'index']);
Route::get('umkm/{umkm}', [UmkmController::class, 'show']);

// Get products (public browse)
Route::get('products', [ProductController::class, 'index']);
Route::get('products/{product}', [ProductController::class, 'show']);
Route::get('products/category/{category}', [ProductController::class, 'byCategory']);
Route::get('umkm/{umkmId}/products', [ProductController::class, 'byUmkm']);

// Get reviews (public)
Route::get('products/{productId}/reviews', [ReviewController::class, 'productReviews']);
Route::get('umkm/{umkmId}/reviews', [ReviewController::class, 'umkmReviews']);

// ==================== Protected Routes ====================
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('auth/logout', [AuthController::class, 'logout']);

    // Products (UMKM Management)
    Route::post('products', [ProductController::class, 'store']);
    Route::patch('products/{product}', [ProductController::class, 'update']);
    Route::delete('products/{product}', [ProductController::class, 'destroy']);

    // Orders
    Route::post('orders', [OrderController::class, 'store']);
    Route::get('orders', [OrderController::class, 'index']);
    Route::get('orders/{order}', [OrderController::class, 'show']);
    Route::patch('orders/{order}/status', [OrderController::class, 'updateStatus']);
    Route::get('umkm/orders', [OrderController::class, 'umkmOrders']); // UMKM only

    // UMKM Analytics
    Route::get('umkm/analytics/summary', [UmkmController::class, 'analytics']);

    // Reviews
    Route::post('reviews', [ReviewController::class, 'store']);

    // Wallet (Lokal Coin)
    Route::prefix('wallet')->group(function () {
        Route::get('balance', [WalletController::class, 'balance']);
        Route::get('history', [WalletController::class, 'history']);
        Route::get('expiring-coins', [WalletController::class, 'expiringCoins']);
    });

    // Payments
    Route::prefix('payments')->group(function () {
        Route::get('status', [PaymentWebhookController::class, 'getStatus']);
    });
});
