@extends('layouts.app')

@section('content')
<div class="space-y-6">
    <div class="flex items-center justify-between">
        <div>
            <h2 class="text-2xl font-bold text-gray-900">Manajemen Wallet</h2>
            <p class="text-sm text-gray-500">Pantau semua dompet digital pengguna (saldo tunai, komisi, koin).</p>
        </div>
        <a href="{{ route('admin.dashboard') }}" class="text-sm text-blue-600 hover:underline">← Dashboard</a>
    </div>

    {{-- Ringkasan --}}
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-xl p-5 border border-blue-200 shadow-sm">
            <p class="text-sm text-blue-700 font-medium">💰 Saldo Komisi Admin</p>
            <p class="text-2xl font-extrabold text-blue-600">Rp {{ number_format($summary['total_commission_admin'], 0, ',', '.') }}</p>
            <p class="text-xs text-blue-500">Dari potongan 5% transaksi</p>
        </div>
        <div class="bg-gradient-to-br from-emerald-50 to-emerald-100 rounded-xl p-5 border border-emerald-200 shadow-sm">
            <p class="text-sm text-emerald-700 font-medium">🏦 Total Saldo Tunai UMKM</p>
            <p class="text-2xl font-extrabold text-emerald-600">Rp {{ number_format($summary['total_cash_umkm'], 0, ',', '.') }}</p>
            <p class="text-xs text-emerald-500">Bisa ditarik oleh UMKM</p>
        </div>
        <div class="bg-gradient-to-br from-amber-50 to-amber-100 rounded-xl p-5 border border-amber-200 shadow-sm">
            <p class="text-sm text-amber-700 font-medium">🪙 Total Koin Beredar</p>
            <p class="text-2xl font-extrabold text-amber-600">{{ number_format($summary['total_coin'], 0, ',', '.') }} 🪙</p>
            <p class="text-xs text-amber-500">~ Rp {{ number_format($summary['total_coin'] * 10, 0, ',', '.') }}</p>
        </div>
    </div>

    {{-- Tabel --}}
    <div class="bg-white rounded-xl border shadow-sm overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
            <h3 class="font-semibold text-gray-900">Semua Wallet ({{ $wallets->total() }})</h3>
            <span class="text-xs text-gray-400">Total cash: Rp {{ number_format($summary['total_cash'], 0, ',', '.') }}</span>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="bg-gray-50 text-gray-500 text-left">
                        <th class="px-6 py-3 font-medium">User</th>
                        <th class="px-6 py-3 font-medium">Role</th>
                        <th class="px-6 py-3 font-medium">💰 Cash (Tunai)</th>
                        <th class="px-6 py-3 font-medium">📊 Komisi</th>
                        <th class="px-6 py-3 font-medium">🪙 Koin</th>
                        <th class="px-6 py-3 font-medium">Total Value</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    @forelse($wallets as $wallet)
                    @php
                        $totalValue = $wallet->cash_balance + $wallet->commission_balance + ($wallet->coin_balance * 10);
                    @endphp
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4">
                            <div class="font-medium text-gray-900">{{ $wallet->user->name ?? '—' }}</div>
                            <div class="text-xs text-gray-400">{{ $wallet->user->email ?? '' }}</div>
                        </td>
                        <td class="px-6 py-4">
                            @php
                                $roleColors = ['admin' => 'bg-purple-100 text-purple-700', 'umkm' => 'bg-emerald-100 text-emerald-700', 'konsumen' => 'bg-blue-100 text-blue-700'];
                                $roleLabels = ['admin' => 'Admin', 'umkm' => 'UMKM', 'konsumen' => 'Konsumen'];
                            @endphp
                            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium {{ $roleColors[$wallet->user->role] ?? 'bg-gray-100' }}">
                                {{ $roleLabels[$wallet->user->role] ?? $wallet->user->role }}
                            </span>
                        </td>
                        <td class="px-6 py-4 font-mono font-medium">Rp {{ number_format($wallet->cash_balance, 0, ',', '.') }}</td>
                        <td class="px-6 py-4 font-mono">Rp {{ number_format($wallet->commission_balance, 0, ',', '.') }}</td>
                        <td class="px-6 py-4 font-mono">{{ number_format($wallet->coin_balance, 0, ',', '.') }} 🪙</td>
                        <td class="px-6 py-4 font-mono font-bold text-gray-900">Rp {{ number_format($totalValue, 0, ',', '.') }}</td>
                    </tr>
                    @empty
                    <tr><td colspan="6" class="px-6 py-8 text-center text-gray-400">Belum ada wallet.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($wallets->hasPages())
        <div class="px-6 py-4 border-t">
            {{ $wallets->links() }}
        </div>
        @endif
    </div>
</div>
@endsection