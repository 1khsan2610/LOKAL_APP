@extends('layouts.admin')

@section('title', 'Riwayat Koin — LOKAL Admin')

@section('content')
<div class="space-y-6">
    <div class="flex items-center justify-between">
        <div>
            <h2 class="text-2xl font-bold text-gray-900">Riwayat & Statistik Lokal Coin</h2>
            <p class="text-sm text-gray-500">Pantau sirkulasi Lokal Coin di platform.</p>
        </div>
        <a href="{{ route('admin.dashboard') }}" class="text-sm text-blue-600 hover:underline">← Dashboard</a>
    </div>

    {{-- Stat Cards --}}
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div class="bg-white rounded-xl p-5 border shadow-sm">
            <p class="text-sm text-gray-500">Total Koin Beredar</p>
            <p class="text-2xl font-extrabold text-amber-600">{{ number_format($totalCoinInCirculation, 0, ',', '.') }} 🪙</p>
            <p class="text-xs text-gray-400">~ Rp {{ number_format($totalCoinInCirculation * 10, 0, ',', '.') }}</p>
        </div>
        <div class="bg-white rounded-xl p-5 border shadow-sm">
            <p class="text-sm text-gray-500">Total Kredit (Masuk)</p>
            <p class="text-2xl font-extrabold text-emerald-600">{{ number_format($totalCoinCredit, 0, ',', '.') }} 🪙</p>
            <p class="text-xs text-gray-400">Cashback, reward, dll</p>
        </div>
        <div class="bg-white rounded-xl p-5 border shadow-sm">
            <p class="text-sm text-gray-500">Total Debit (Keluar)</p>
            <p class="text-2xl font-extrabold text-red-600">{{ number_format($totalCoinDebit, 0, ',', '.') }} 🪙</p>
            <p class="text-xs text-gray-400">Digunakan untuk belanja</p>
        </div>
        <div class="bg-white rounded-xl p-5 border shadow-sm">
            <p class="text-sm text-gray-500">Total Transaksi</p>
            <p class="text-2xl font-extrabold text-blue-600">{{ number_format($coinTransactions->total(), 0, ',', '.') }}</p>
            <p class="text-xs text-gray-400">Semua riwayat</p>
        </div>
    </div>

    {{-- Chart --}}
    <div class="bg-white rounded-xl p-6 border shadow-sm">
        <h3 class="text-lg font-bold text-gray-900 mb-4">📊 Grafik Koin (7 Hari Terakhir)</h3>
        <div class="flex items-end gap-2 h-40">
            @foreach($coinChart as $day)
            @php
                $maxVal = max($coinChart->max('credit'), $coinChart->max('debit'), 1);
                $creditH = ($day['credit'] / $maxVal) * 100;
                $debitH  = ($day['debit'] / $maxVal) * 100;
                $dayName = \Carbon\Carbon::parse($day['date'])->isoFormat('dd');
            @endphp
            <div class="flex-1 flex flex-col items-center gap-1">
                <span class="text-xs text-gray-400">{{ number_format($day['credit'], 0, ',', '.') }}</span>
                <div class="w-full flex flex-col-reverse gap-0.5 relative" style="height:120px;">
                    <div class="w-full bg-emerald-200 rounded-t transition-all" style="height: {{ $creditH }}%;" title="Kredit: {{ $day['credit'] }}"></div>
                    <div class="w-full bg-red-200 rounded-t transition-all" style="height: {{ $debitH }}%;" title="Debit: {{ $day['debit'] }}"></div>
                </div>
                <span class="text-xs text-gray-500">{{ $dayName }}</span>
                <div class="flex gap-1">
                    <span class="w-2 h-2 rounded-full bg-emerald-400"></span>
                    <span class="w-2 h-2 rounded-full bg-red-400"></span>
                </div>
            </div>
            @endforeach
        </div>
        <div class="flex gap-4 mt-2 text-xs text-gray-500">
            <span class="flex items-center gap-1"><span class="w-3 h-3 rounded bg-emerald-400"></span> Kredit</span>
            <span class="flex items-center gap-1"><span class="w-3 h-3 rounded bg-red-400"></span> Debit</span>
        </div>
    </div>

    {{-- Tabel Riwayat --}}
    <div class="bg-white rounded-xl border shadow-sm overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900">Transaksi Terbaru</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="bg-gray-50 text-gray-500 text-left">
                        <th class="px-6 py-3 font-medium">User</th>
                        <th class="px-6 py-3 font-medium">Tipe</th>
                        <th class="px-6 py-3 font-medium">Jumlah</th>
                        <th class="px-6 py-3 font-medium">Saldo Akhir</th>
                        <th class="px-6 py-3 font-medium">Deskripsi</th>
                        <th class="px-6 py-3 font-medium">Tanggal</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    @forelse($coinTransactions as $tx)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4 font-medium text-gray-900">{{ $tx->user->name ?? '—' }}</td>
                        <td class="px-6 py-4">
                            @if($tx->type === 'credit')
                            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-700">Kredit</span>
                            @else
                            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-700">Debit</span>
                            @endif
                        </td>
                        <td class="px-6 py-4 font-mono font-medium">{{ number_format($tx->amount, 0, ',', '.') }}</td>
                        <td class="px-6 py-4 font-mono">{{ number_format($tx->balance_after, 0, ',', '.') }}</td>
                        <td class="px-6 py-4 text-gray-600 max-w-xs truncate">{{ $tx->description }}</td>
                        <td class="px-6 py-4 text-gray-500">{{ $tx->created_at->format('d M H:i') }}</td>
                    </tr>
                    @empty
                    <tr><td colspan="6" class="px-6 py-8 text-center text-gray-400">Belum ada transaksi koin.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($coinTransactions->hasPages())
        <div class="px-6 py-4 border-t">
            {{ $coinTransactions->links() }}
        </div>
        @endif
    </div>
</div>
@endsection