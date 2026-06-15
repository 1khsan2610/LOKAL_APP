<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\PaymentWebhookController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\UmkmController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\OpenApiDocumentationController;
use App\Http\Controllers\Api\PriceRecommendationController;
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

// Simple health check used by Docker and monitoring
Route::get('health', function () {
    return response()->json(['status' => 'OK', 'message' => 'Backend is running']);
});

// ==================== Documentation Routes ====================
// OpenAPI 3.0 Specification (SRS Bab 5.4)
Route::get('docs/openapi.json', [OpenApiDocumentationController::class, 'specification']);
Route::get('docs', [OpenApiDocumentationController::class, 'documentation'])->name('api.docs');

// ==================== Public Routes ====================
Route::prefix('auth')->group(function () {
    Route::post('register-account', [AuthController::class, 'registerAccount']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('verify-email', [AuthController::class, 'verifyEmail']);
    Route::post('request-otp', [AuthController::class, 'requestOtp']);
    Route::post('verify-otp', [AuthController::class, 'verifyOtp']);
    Route::post('forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('reset-password', [AuthController::class, 'resetPassword']);
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
Route::middleware('auth.jwt')->group(function () {
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

    // Price Recommendations (ML Service)
    Route::prefix('recommendations')->group(function () {
        Route::get('products/{product}', [PriceRecommendationController::class, 'getRecommendation']);
        Route::get('products/{product}/latest', [PriceRecommendationController::class, 'getLatestRecommendation']);
        Route::get('products/{product}/history', [PriceRecommendationController::class, 'getRecommendationHistory']);
        Route::get('status/{requestId}', [PriceRecommendationController::class, 'getRecommendationStatus']);
        Route::post('apply/{recommendation}', [PriceRecommendationController::class, 'applyRecommendation']);
        Route::get('umkm', [PriceRecommendationController::class, 'getUmkmRecommendations']);
    });
});

// ==================== Admin Routes ====================
Route::middleware('auth.jwt')->prefix('admin')->group(function () {
    // Dashboard
    Route::get('dashboard', [AdminController::class, 'dashboardStats']);

    // Users management
    Route::get('users', [AdminController::class, 'users']);
    Route::delete('users/{userId}', [AdminController::class, 'deactivateUser']);

    // UMKM verification
    Route::get('umkm/pending', [AdminController::class, 'pendingUmkm']);
    Route::patch('umkm/{umkmId}/approve', [AdminController::class, 'approveUmkm']);
    Route::patch('umkm/{umkmId}/reject', [AdminController::class, 'rejectUmkm']);
});
