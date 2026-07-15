<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminWebController;
use App\Http\Controllers\AdminUmkmController;
use App\Http\Controllers\AdminProductController;
use App\Http\Controllers\AdminOrderController;
use App\Http\Controllers\AdminCoinController;
use App\Http\Controllers\AdminWalletController;
use App\Http\Controllers\AdminSettingController;
use App\Http\Controllers\AdminBankVerificationController;
use App\Http\Controllers\Api\PaymentController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// ── Public Routes ────────────────────────────────────────────────────
Route::get('/', [AdminWebController::class, 'index'])->name('landing');

Route::get('/login', [AdminWebController::class, 'showLogin'])->name('login');
Route::post('/login', [AdminWebController::class, 'login']);

// ── Admin Protected Routes (session-based) ───────────────────────────
Route::middleware(['auth'])->prefix('admin')->name('admin.')->group(function () {

    Route::get('/dashboard', [AdminWebController::class, 'dashboard'])->name('dashboard');
    Route::post('/umkm/{id}/verify', [AdminWebController::class, 'verifyUmkm'])->name('umkm.verify');
    // Admin management pages
    Route::get('/products', [AdminProductController::class, 'index'])->name('products.index');
    Route::get('/products/create', [AdminProductController::class, 'create'])->name('products.create');
    Route::post('/products', [AdminProductController::class, 'store'])->name('products.store');
    Route::get('/products/{id}/edit', [AdminProductController::class, 'edit'])->name('products.edit');
    Route::put('/products/{id}', [AdminProductController::class, 'update'])->name('products.update');
    Route::delete('/products/{id}', [AdminProductController::class, 'destroy'])->name('products.destroy');
    Route::get('/orders', [AdminOrderController::class, 'index'])->name('orders.index');
    Route::get('/orders/{id}', [AdminOrderController::class, 'show'])->name('orders.show');
    Route::get('/orders/{id}/edit', [AdminOrderController::class, 'edit'])->name('orders.edit');
    Route::put('/orders/{id}', [AdminOrderController::class, 'update'])->name('orders.update');
    Route::delete('/orders/{id}', [AdminOrderController::class, 'destroy'])->name('orders.destroy');
    Route::get('/coins', [AdminCoinController::class, 'index'])->name('coins.index');
    // Wallet & Mutasi Dana
    Route::get('/wallets', [AdminWalletController::class, 'index'])->name('wallets.index');
    Route::get('/wallet-histories', [AdminWalletController::class, 'histories'])->name('wallet-histories.index');
    // UMKM CRUD
    Route::get('/umkm', [AdminUmkmController::class, 'index'])->name('umkm.index');
    Route::get('/umkm/create', [AdminUmkmController::class, 'create'])->name('umkm.create');
    Route::post('/umkm', [AdminUmkmController::class, 'store'])->name('umkm.store');
    Route::get('/umkm/{id}/edit', [AdminUmkmController::class, 'edit'])->name('umkm.edit');
    Route::put('/umkm/{id}', [AdminUmkmController::class, 'update'])->name('umkm.update');
    Route::delete('/umkm/{id}', [AdminUmkmController::class, 'destroy'])->name('umkm.destroy');

    // Verifikasi Rekening Bank UMKM
    Route::get('/verifikasi-bank', [AdminBankVerificationController::class, 'index'])->name('bank-verification.index');
    Route::post('/verifikasi-bank/{id}/approve', [AdminBankVerificationController::class, 'approve'])->name('bank-verification.approve');
    Route::post('/verifikasi-bank/{id}/reject', [AdminBankVerificationController::class, 'reject'])->name('bank-verification.reject');

    // Pengaturan Global (Full CRUD)
    Route::get('/settings', [AdminSettingController::class, 'index'])->name('settings.index');
    Route::get('/settings/create', [AdminSettingController::class, 'create'])->name('settings.create');
    Route::post('/settings', [AdminSettingController::class, 'store'])->name('settings.store');
    Route::get('/settings/{id}/edit', [AdminSettingController::class, 'edit'])->name('settings.edit');
    Route::put('/settings/{id}', [AdminSettingController::class, 'update'])->name('settings.update');
    Route::delete('/settings/{id}', [AdminSettingController::class, 'destroy'])->name('settings.destroy');

    Route::post('/logout', [AdminWebController::class, 'logout'])->name('logout');

});

// Rute Pengalihan setelah pembayaran sukses dari Midtrans
Route::get('/payment/finish', [PaymentController::class, 'paymentFinish'])->name('payment.finish');