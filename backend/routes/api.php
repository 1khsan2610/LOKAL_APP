<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\UmkmController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\OrderTrackingController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AiChatController;
use App\Http\Controllers\Api\AnalyticsController;
use App\Http\Controllers\Api\ChatController;

// Image proxy (adds CORS headers for Flutter web)
Route::get('/image/{path}', function (string $path) {
    $fullPath = storage_path("app/public/{$path}");
    if (!file_exists($fullPath)) {
        return response()->json(['error' => 'File not found'], 404);
    }
    $mime = mime_content_type($fullPath) ?: 'application/octet-stream';
    return response()->file($fullPath, ['Content-Type' => $mime]);
})->where('path', '.*');

// Health check
Route::get('/health', fn() => response()->json(['status' => 'ok', 'timestamp' => now()]));

// ─── AUTH (Public) ────────────────────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('/register-account', [AuthController::class, 'register']);
    Route::post('/login',            [AuthController::class, 'login']);
    Route::post('/forgot-password',  [AuthController::class, 'forgotPassword']);
    Route::post('/reset-password',   [AuthController::class, 'resetPassword']);
    Route::post('/verify-email',     [AuthController::class, 'verifyEmail']);
});

// ─── PUBLIC ENDPOINTS ─────────────────────────────────────────────
Route::get('/products',              [ProductController::class, 'index']);
Route::get('/products/search',       [ProductController::class, 'search']);
Route::get('/products/flash-sale',   [ProductController::class, 'flashSale']);
Route::get('/products/{id}',         [ProductController::class, 'show'])->whereNumber('id');
Route::get('/products/{id}/reviews', [ReviewController::class, 'index'])->whereNumber('id');
Route::get('/umkm',                  [UmkmController::class, 'index']);
Route::get('/umkm/nearby',           [UmkmController::class, 'nearby']);
Route::get('/umkm/{id}',             [UmkmController::class, 'show'])->whereNumber('id');
Route::get('/umkm/{id}/products',    [UmkmController::class, 'products'])->whereNumber('id');
Route::post('/payment/notification', [PaymentController::class, 'notification']); // Midtrans webhook
Route::post('/orders/process-payment-webhook', [OrderController::class, 'processPaymentWebhook']); // Simulasi webhook sukses

// ─── AUTHENTICATED ────────────────────────────────────────────────
Route::middleware('auth:api')->group(function () {

    // Auth management (refresh must be protected to prevent token blacklist abuse)
    Route::post('/auth/logout',      [AuthController::class, 'logout']);
    Route::get('/auth/me',           [AuthController::class, 'me']);
    Route::post('/auth/refresh',     [AuthController::class, 'refresh']);

    // Profile
    Route::prefix('profile')->group(function () {
        $router = Route::get('/',              [UserController::class, 'profile']);
        Route::put('/',              [UserController::class, 'update']);
        Route::post('/avatar',       [UserController::class, 'uploadAvatar']);
        Route::put('/change-password', [UserController::class, 'changePassword']);
    });

    // Addresses
    Route::apiResource('addresses', AddressController::class);
    Route::patch('/addresses/{id}/set-default', [AddressController::class, 'setDefault']);

    // Cart
    Route::prefix('cart')->group(function () {
        Route::get('/',              [CartController::class, 'index']);
        Route::post('/',             [CartController::class, 'addItem']);
        Route::put('/{itemId}',      [CartController::class, 'updateItem']);
        Route::delete('/{itemId}',   [CartController::class, 'removeItem']);
        Route::delete('/',           [CartController::class, 'clear']);
    });

    // Orders
    Route::prefix('orders')->group(function () {
        Route::get('/',              [OrderController::class, 'index']);
        Route::post('/',             [OrderController::class, 'store']);
        Route::get('/{id}',          [OrderController::class, 'show']);
        Route::patch('/{id}/cancel', [OrderController::class, 'cancel']);
        Route::patch('/{id}/confirm-received', [OrderController::class, 'confirmReceived']);
        Route::get('/{id}/tracking', [OrderTrackingController::class, 'tracking']);
        Route::get('/{id}/check-payment', [PaymentController::class, 'checkPayment']);
    });

    // Payment
    Route::prefix('payment')->group(function () {
        Route::post('/create',       [PaymentController::class, 'create']);
        Route::get('/status/{orderId}', [PaymentController::class, 'status']);
    });

    // Wallet & Coin
    Route::prefix('wallet')->group(function () {
        Route::get('/',              [WalletController::class, 'index']);
        Route::get('/transactions',  [WalletController::class, 'transactions']);
        Route::get('/history',       [WalletController::class, 'history']);
        Route::post('/redeem',       [WalletController::class, 'redeem']);
        Route::post('/withdraw',     [WalletController::class, 'withdraw']);
    });

    // Reviews
    Route::get('/reviews/me',        [ReviewController::class, 'myReviews']);
    Route::post('/reviews',          [ReviewController::class, 'store']);
    Route::put('/reviews/{id}',      [ReviewController::class, 'update']);
    Route::delete('/reviews/{id}',   [ReviewController::class, 'destroy']);

    // Notifications
    Route::prefix('notifications')->group(function () {
        Route::get('/',              [NotificationController::class, 'index']);
        Route::patch('/{id}/read',   [NotificationController::class, 'markRead']);
        Route::patch('/read-all',    [NotificationController::class, 'markAllRead']);
        Route::post('/register-device', [NotificationController::class, 'registerDevice']);
    });

    // AI Chat
    Route::post('/ai/chat',          [AiChatController::class, 'chat']);

    // ── UMKM Role ──────────────────────────────────────────────────
    Route::middleware('role:umkm,admin')->prefix('umkm')->group(function () {
        Route::get('/my-store',      [UmkmController::class, 'myStore']);
        Route::put('/my-store',      [UmkmController::class, 'updateStore']);
        Route::get('/products',      [ProductController::class, 'myProducts']);
        Route::get('/products/{id}', [ProductController::class, 'myProductDetail'])->whereNumber('id');
        Route::post('/products',     [ProductController::class, 'store']);
        Route::put('/products/{id}', [ProductController::class, 'update']);
        Route::delete('/products/{id}', [ProductController::class, 'destroy']);
        Route::post('/products/{id}/images', [ProductController::class, 'uploadImages']);
        Route::delete('/products/{productId}/images/{imageId}', [ProductController::class, 'deleteImage']);
        Route::get('/orders',        [OrderController::class, 'sellerOrders']);
        Route::patch('/orders/{id}/status', [OrderController::class, 'updateStatus']);
        Route::get('/analytics/summary', [AnalyticsController::class, 'umkmSummary']);
        Route::get('/analytics/weekly',  [AnalyticsController::class, 'weekly']);
        Route::get('/analytics/sales',   [AnalyticsController::class, 'salesChart']);
        // Bank account for UMKM withdrawal
        Route::get('/bank-account',      [UmkmController::class, 'getBankAccount']);
        Route::post('/bank-account',     [UmkmController::class, 'storeBankAccount']);
        Route::put('/bank-account',      [UmkmController::class, 'updateBankAccount']);
    });

    // ── Chat ────────────────────────────────────────────────────────
    Route::prefix('chat')->middleware('chat.access')->group(function () {
        Route::get('/',                  [ChatController::class, 'index']);
        Route::get('/unread-count',      [ChatController::class, 'unreadCount']);
        Route::get('/{chat}',            [ChatController::class, 'show']);
        Route::post('/send',             [ChatController::class, 'send']);
        Route::post('/start-from-product', [ChatController::class, 'startFromProduct']);
        Route::patch('/{chat}/mark-read', [ChatController::class, 'markAsRead']);
    });

    // ── Admin Role ─────────────────────────────────────────────────
    Route::middleware('role:admin')->prefix('admin')->group(function () {
        // Dashboard & Overview
        Route::get('/dashboard',        [AdminController::class, 'dashboard']);
        Route::get('/finance',          [AdminController::class, 'finance']);

        // Manajemen Pengguna
        Route::get('/users',            [AdminController::class, 'users']);
        Route::patch('/users/{id}/status', [AdminController::class, 'toggleUserStatus']);

        // Manajemen UMKM (Verifikasi Toko & Bank)
        Route::get('/umkm',             [AdminController::class, 'umkmList']);
        Route::patch('/umkm/{id}/verify', [AdminController::class, 'verifyUmkm']);
        Route::get('/bank-accounts',    [AdminController::class, 'bankAccounts']);
        Route::patch('/bank-accounts/{id}/approve', [AdminController::class, 'approveBankAccount']);
        Route::patch('/bank-accounts/{id}/reject',  [AdminController::class, 'rejectBankAccount']);

        // Produk Moderasi
        Route::get('/products',         [AdminController::class, 'productList']);
        Route::post('/products/{id}/approve', [AdminController::class, 'approveProduct']);
        Route::delete('/products/{id}', [AdminController::class, 'deleteProduct']);

        // Transaksi Order (Monitoring Seluruh Transaksi)
        Route::get('/orders',           [AdminController::class, 'orders']);
        Route::get('/transactions',     [AdminController::class, 'transactions']);

        // Keuangan & Wallet
        Route::get('/wallet-mutations', [AdminController::class, 'walletMutations']);
        Route::get('/withdrawals',      [AdminController::class, 'withdrawals']);

        // Analytics & Pengaturan
        Route::get('/analytics',        [AnalyticsController::class, 'adminSummary']);
        Route::post('/notifications/broadcast', [NotificationController::class, 'broadcast']);
    });
});