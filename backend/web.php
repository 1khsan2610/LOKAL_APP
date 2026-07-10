<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\PaymentController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

Route::get('/', function () {
    return view('welcome');
});

// Rute Pengalihan setelah pembayaran sukses dari Midtrans
Route::get('/payment/finish', [PaymentController::class, 'paymentFinish'])->name('payment.finish');