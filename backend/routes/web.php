<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

// Backwards-compatible health endpoint used by Docker healthcheck
Route::get('/api/health', function () {
    return response()->json(['status' => 'OK', 'message' => 'Backend is running']);
});
