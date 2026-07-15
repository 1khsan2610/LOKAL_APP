<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminWebController;
use App\Http\Controllers\AdminUmkmController;
use App\Http\Controllers\AdminProductController;
use App\Http\Controllers\AdminOrderController;
use App\Http\Controllers\AdminCoinController;
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
    Route::get('/coins', [AdminCoinController::class, 'index'])->name('coins.index');
    // UMKM CRUD
    Route::get('/umkm', [AdminUmkmController::class, 'index'])->name('umkm.index');
    Route::get('/umkm/create', [AdminUmkmController::class, 'create'])->name('umkm.create');
    Route::post('/umkm', [AdminUmkmController::class, 'store'])->name('umkm.store');
    Route::get('/umkm/{id}/edit', [AdminUmkmController::class, 'edit'])->name('umkm.edit');
    Route::put('/umkm/{id}', [AdminUmkmController::class, 'update'])->name('umkm.update');
    Route::delete('/umkm/{id}', [AdminUmkmController::class, 'destroy'])->name('umkm.destroy');
    Route::post('/logout', [AdminWebController::class, 'logout'])->name('logout');

});

// Rute Pengalihan setelah pembayaran sukses dari Midtrans
Route::get('/payment/finish', [PaymentController::class, 'paymentFinish'])->name('payment.finish');