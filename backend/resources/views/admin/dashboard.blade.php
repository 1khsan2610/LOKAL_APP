@extends('layouts.admin')

@section('title', 'Dashboard — LOKAL Admin')

@section('content')
{{-- Page Header --}}
<div class="mb-8">
    <h1 class="text-2xl lg:text-3xl font-extrabold text-gray-900">Dashboard</h1>
    <p class="text-gray-500 mt-1">Ringkasan data platform LOKAL dan sirkulasi dana.</p>
</div>

{{-- Success Message --}}
@if (session('success'))
<div class="mb-6 p-4 bg-emerald-50 border border-emerald-200 rounded-xl">
    <p class="text-sm font-medium text-emerald-700">{{ session('success') }}</p>
</div>
@endif

{{-- Stat Cards (Row 1) --}}
<div class="grid grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-8">
    {{-- UMKM Total --}}
    <div class="stat-card bg-white rounded-2xl p-5 lg:p-6 border border-gray-100 shadow-sm">
        <div class="flex items-center justify-between mb-4">
            <div class="w-10 h-10 rounded-xl bg-blue-100 flex items-center justify-center">
                <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>
            </div>
            <span class="text-xs font-medium text-gray-400 bg-gray-50 px-2 py-1 rounded-full">Total</span>
        </div>
        <p class="text-2xl lg:text-3xl font-extrabold text-gray-900">{{ $stats['total_umkm'] }}</p>
        <p class="text-sm text-gray-500 mt-1">UMKM Terdaftar</p>
    </div>

    {{-- UMKM Pending --}}
    <div class="stat-card bg-white rounded-2xl p-5 lg:p-6 border border-gray-100 shadow-sm">
        <div class="flex items-center justify-between mb-4">
            <div class="w-10 h-10 rounded-xl bg-amber-100 flex items-center justify-center">
                <svg class="w-5 h-5 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <span class="text-xs font-medium text-amber-600 bg-amber-50 px-2 py-1 rounded-full">Pending</span>
        </div>
        <p class="text-2xl lg:text-3xl font-extrabold text-amber-600">{{ $stats['umkm_pending'] }}</p>
        <p class="text-sm text-gray-500 mt-1">Menunggu Verifikasi</p>
    </div>

    {{-- UMKM Verified --}}
    <div class="stat-card bg-white rounded-2xl p-5 lg:p-6 border border-gray-100 shadow-sm">
        <div class="flex items-center justify-between mb-4">
            <div class="w-10 h-10 rounded-xl bg-emerald-100 flex items-center justify-center">
                <svg class="w-5 h-5 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <span class="text-xs font-medium text-emerald-600 bg-emerald-50 px-2 py-1 rounded-full">Verified</span>
        </div>
        <p class="text-2xl lg:text-3xl font-extrabold text-emerald-600">{{ $stats['umkm_verified'] }}</p>
        <p class="text-sm text-gray-500 mt-1">UMKM Terverifikasi</p>
    </div>

    {{-- Products --}}
    <div class="stat-card bg-white rounded-2xl p-5 lg:p-6 border border-gray-100 shadow-sm">
        <div class="flex items-center justify-between mb-4">
            <div class="w-10 h-10 rounded-xl bg-purple-100 flex items-center justify-center">
                <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/></svg>
            </div>
            <span class="text-xs font-medium text-purple-600 bg-purple-50 px-2 py-1 rounded-full">Aktif</span>
        </div>
        <p class="text-2xl lg:text-3xl font-extrabold text-purple-600">{{ $stats['total_products'] }}</p>
        <p class="text-sm text-gray-500 mt-1">Produk Aktif</p>
    </div>
</div>

{{-- Secondary Stats Row --}}
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-8">
    {{-- Orders --}}
    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
        <div class="flex items-center gap-3 mb-3">
            <div class="w-8 h-8 rounded-lg bg-orange-100 flex items-center justify-center">
                <svg class="w-4 h-4 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>
            </div>
            <span class="text-sm font-semibold text-gray-700">Total Orders</span>
        </div>
        <p class="text-xl font-extrabold text-gray-900">{{ $stats['total_orders'] }}</p>
    </div>

    {{-- Revenue --}}
    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
        <div class="flex items-center gap-3 mb-3">
            <div class="w-8 h-8 rounded-lg bg-green-100 flex items-center justify-center">
                <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <span class="text-sm font-semibold text-gray-700">Revenue</span>
        </div>
        <p class="text-xl font-extrabold text-gray-900">Rp {{ number_format($stats['total_revenue'], 0, ',', '.') }}</p>
    </div>

    {{-- Coin Transactions --}}
    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
        <div class="flex items-center gap-3 mb-3">
            <div class="w-8 h-8 rounded-lg bg-cyan-100 flex items-center justify-center">
                <svg class="w-4 h-4 text-cyan-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <span class="text-sm font-semibold text-gray-700">Transaksi Koin</span>
        </div>
        <p class="text-xl font-extrabold text-gray-900">{{ $stats['total_coin_transactions'] }}</p>
    </div>

    {{-- Users --}}
    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
        <div class="flex items-center gap-3 mb-3">
            <div class="w-8 h-8 rounded-lg bg-indigo-100 flex items-center justify-center">
                <svg class="w-4 h-4 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>
            </div>
            <span class="text-sm font-semibold text-gray-700">Total Users</span>
        </div>
        <p class="text-xl font-extrabold text-gray-900">{{ $stats['total_users'] }}</p>
    </div>
</div>

{{-- Wallet & Sirkulasi Dana Cards --}}
<div class="mb-6">
    <h2 class="text-xl font-bold text-gray-900 mb-4">💰 Sirkulasi Dana Platform</h2>
</div>
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-8">
    {{-- Commission Balance Admin --}}
    <div class="stat-card bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
        <div class="flex items-center gap-3 mb-3">
            <div class="w-8 h-8 rounded-lg bg-blue-100 flex items-center justify-center">
                <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <span class="text-sm font-semibold text-gray-700">Saldo Komisi Admin</span>
        </div>
        <p class="text-xl font-extrabold text-blue-600">Rp {{ number_format($stats['commission_balance'], 0, ',', '.') }}</p>
        <p class="text-xs text-gray-400 mt-1">Dari potongan 5% transaksi</p>
    </div>

    {{-- Total UMKM Cash --}}
    <div class="stat-card bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
        <div class="flex items-center gap-3 mb-3">
            <div class="w-8 h-8 rounded-lg bg-emerald-100 flex items-center justify-center">
                <svg class="w-4 h-4 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
            </div>
            <span class="text-sm font-semibold text-gray-700">Total Saldo UMKM</span>
        </div>
        <p class="text-xl font-extrabold text-emerald-600">Rp {{ number_format($stats['total_umkm_cash'], 0, ',', '.') }}</p>
        <p class="text-xs text-gray-400 mt-1">Bisa ditarik oleh UMKM</p>
    </div>

    {{-- Total Consumer Coin --}}
    <div class="stat-card bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
        <div class="flex items-center gap-3 mb-3">
            <div class="w-8 h-8 rounded-lg bg-amber-100 flex items-center justify-center">
                <svg class="w-4 h-4 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <span class="text-sm font-semibold text-gray-700">Total Koin Konsumen</span>
        </div>
        <p class="text-xl font-extrabold text-amber-600">{{ number_format($stats['total_consumer_coin'], 0, ',', '.') }} 🪙</p>
        <p class="text-xs text-gray-400 mt-1">~ Rp {{ number_format($stats['total_consumer_coin'] * 10, 0, ',', '.') }}</p>
    </div>

    {{-- Today Mutations --}}
    <div class="stat-card bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
        <div class="flex items-center gap-3 mb-3">
            <div class="w-8 h-8 rounded-lg bg-purple-100 flex items-center justify-center">
                <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/></svg>
            </div>
            <span class="text-sm font-semibold text-gray-700">Mutasi Hari Ini</span>
        </div>
        <p class="text-xl font-extrabold text-purple-600">{{ $stats['today_mutations'] }}</p>
        <p class="text-xs text-gray-400 mt-1">Transaksi tercatat</p>
    </div>
</div>

{{-- Commission Chart --}}
<div class="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm mb-8">
    <h3 class="text-lg font-bold text-gray-900 mb-4">📈 Komisi Masuk (7 Hari Terakhir)</h3>
    <div class="flex items-end gap-2 h-32">
        @foreach($stats['commission_chart'] as $day)
        @php
            $maxTotal = $stats['commission_chart']->max('total');
            $height = $maxTotal > 0 ? ($day['total'] / $maxTotal) * 100 : 0;
            $dayName = \Carbon\Carbon::parse($day['date'])->isoFormat('dd');
        @endphp
        <div class="flex-1 flex flex-col items-center gap-1">
            <span class="text-xs text-gray-400 font-medium">Rp{{ number_format($day['total'], 0, ',', '.') }}</span>
            <div class="w-full bg-blue-50 rounded-t-lg relative" style="height: 100px;">
                <div class="absolute bottom-0 w-full bg-blue-500 rounded-t-lg transition-all duration-300" style="height: {{ $height }}%;"></div>
            </div>
            <span class="text-xs text-gray-500">{{ $dayName }}</span>
        </div>
        @endforeach
    </div>
</div>

{{-- Footer hint --}}
<p class="mt-8 text-center text-xs text-gray-400">
    &copy; {{ date('Y') }} LOKAL App — Panel Admin v2.0
</p>
@endsection