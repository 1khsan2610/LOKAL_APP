<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminWebController;
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
    Route::post('/logout', [AdminWebController::class, 'logout'])->name('logout');

});

// Rute Pengalihan setelah pembayaran sukses dari Midtrans
Route::get('/payment/finish', [PaymentController::class, 'paymentFinish'])->name('payment.finish');