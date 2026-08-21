@extends('layouts.admin')

@section('title', 'Edit Order — LOKAL Admin')

@section('content')
<div class="max-w-3xl mx-auto">
    <div class="space-y-6">
        {{-- Header --}}
        <div class="flex items-center gap-4">
            <a href="{{ route('admin.orders.index') }}" class="text-gray-400 hover:text-gray-600 transition">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            </a>
            <div>
                <h2 class="text-2xl font-bold text-gray-900">Edit Pesanan</h2>
                <p class="text-sm text-gray-500 font-mono">{{ $order->order_number }}</p>
            </div>
        </div>

        {{-- Success Message --}}
        @if(session('success'))
        <div class="p-4 bg-emerald-50 border border-emerald-200 rounded-xl">
            <p class="text-sm font-medium text-emerald-700">{{ session('success') }}</p>
        </div>
        @endif

        {{-- Error Message --}}
        @if($errors->any())
        <div class="p-4 bg-red-50 border border-red-200 rounded-xl">
            <ul class="text-sm text-red-600">
                @foreach($errors->all() as $error)
                <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
        @endif

        {{-- Form --}}
        <div class="bg-white rounded-xl border shadow-sm p-6">
            <form method="POST" action="{{ route('admin.orders.update', $order->id) }}">
                @csrf
                @method('PUT')

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                    {{-- Status --}}
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Status Pesanan</label>
                        <select name="status" class="w-full px-3 py-2 border rounded-lg text-sm">
                            @foreach($statuses as $s)
                            <option value="{{ $s }}" {{ $order->status === $s ? 'selected' : '' }}>
                                @php
                                    $labels = [
                                        'pending' => 'Pending',
                                        'awaiting_payment' => 'Menunggu Pembayaran',
                                        'processing' => 'Sudah Dibayar ✅',
                                        'shipped' => 'Dikirim 📦',
                                        'delivered' => 'Selesai 🎉',
                                        'cancelled' => 'Dibatalkan ❌',
                                    ];
                                @endphp
                                {{ $labels[$s] ?? ucfirst(str_replace('_', ' ', $s)) }}
                            </option>
                            @endforeach
                        </select>
                    </div>

                    {{-- Total --}}
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Total (Rp)</label>
                        <input type="number" name="total" value="{{ old('total', $order->total) }}"
                               class="w-full px-3 py-2 border rounded-lg text-sm">
                    </div>

                    {{-- Tracking Number --}}
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">No. Resi / Tracking</label>
                        <input type="text" name="tracking_number" value="{{ old('tracking_number', $order->tracking_number) }}"
                               class="w-full px-3 py-2 border rounded-lg text-sm" placeholder="Opsional">
                    </div>
                </div>

                {{-- Notes --}}
                <div class="mb-6">
                    <label class="block text-sm font-medium text-gray-700 mb-1">Catatan Pembeli</label>
                    <textarea name="notes" rows="3" class="w-full px-3 py-2 border rounded-lg text-sm" placeholder="Catatan dari pembeli...">{{ old('notes', $order->notes) }}</textarea>
                </div>

                <div class="mb-6">
                    <label class="block text-sm font-medium text-gray-700 mb-1">Catatan Penjual</label>
                    <textarea name="seller_notes" rows="3" class="w-full px-3 py-2 border rounded-lg text-sm" placeholder="Catatan internal...">{{ old('seller_notes', $order->seller_notes) }}</textarea>
                </div>

                {{-- Info Ringkas --}}
                <div class="bg-gray-50 rounded-lg p-4 mb-6">
                    <h4 class="text-sm font-semibold text-gray-700 mb-2">📋 Informasi Ringkas</h4>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-3 text-sm">
                        <div>
                            <span class="text-gray-500">Pembeli</span>
                            <p class="font-medium">{{ $order->user->name ?? '—' }}</p>
                        </div>
                        <div>
                            <span class="text-gray-500">Subtotal</span>
                            <p class="font-mono">Rp {{ number_format($order->subtotal, 0, ',', '.') }}</p>
                        </div>
                        <div>
                            <span class="text-gray-500">Ongkir</span>
                            <p class="font-mono">Rp {{ number_format($order->shipping_fee, 0, ',', '.') }}</p>
                        </div>
                        <div>
                            <span class="text-gray-500">Diskon Koin</span>
                            <p class="font-mono {{ $order->coin_discount > 0 ? 'text-amber-600' : '' }}">
                                {{ $order->coin_discount > 0 ? '-Rp '.number_format($order->coin_discount, 0, ',', '.') : '—' }}
                            </p>
                        </div>
                    </div>
                </div>

                {{-- Tombol --}}
                <div class="flex items-center gap-4">
                    <button type="submit" class="px-6 py-2.5 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition">
                        Simpan Perubahan
                    </button>
                    <a href="{{ route('admin.orders.show', $order->id) }}" class="px-6 py-2.5 bg-gray-100 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-200 transition">
                        Batal
                    </a>
                </div>
            </form>
        </div>

        {{-- Tombol Hapus --}}
        <div class="bg-white rounded-xl border border-red-200 shadow-sm p-6">
            <h3 class="font-bold text-red-600 mb-2">⚠️ Zona Berbahaya</h3>
            <p class="text-sm text-gray-500 mb-4">Menghapus pesanan akan menghapus semua data terkait (item, pembayaran, mutasi dana). Tindakan ini tidak bisa dibatalkan.</p>
            <form method="POST" action="{{ route('admin.orders.destroy', $order->id) }}"
                  onsubmit="return confirm('YAKIN ingin menghapus pesanan {{ $order->order_number }}? Semua data terkait akan hilang!');">
                @csrf
                @method('DELETE')
                <button type="submit" class="px-6 py-2.5 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700 transition">
                    Hapus Pesanan Permanen
                </button>
            </form>
        </div>
    </div>
</div>
@endsection