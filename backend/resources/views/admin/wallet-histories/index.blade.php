@extends('layouts.admin')

@section('title', 'Riwayat Mutasi — LOKAL Admin')

@section('content')
<div class="space-y-6">
    <div class="flex items-center justify-between">
        <div>
            <h2 class="text-2xl font-bold text-gray-900">Riwayat Mutasi Dana</h2>
            <p class="text-sm text-gray-500">Seluruh pergerakan dana di platform tercatat secara transparan.</p>
        </div>
        <a href="{{ route('admin.dashboard') }}" class="text-sm text-blue-600 hover:underline">← Dashboard</a>
    </div>

    {{-- Ringkasan per balance_type --}}
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        @foreach($summaryByType as $s)
        @php
            $icons = ['coin' => '🪙', 'cash' => '💰', 'commission' => '📊'];
            $labels = ['coin' => 'Koin', 'cash' => 'Tunai', 'commission' => 'Komisi'];
            $colors = ['coin' => 'bg-amber-50 border-amber-200', 'cash' => 'bg-emerald-50 border-emerald-200', 'commission' => 'bg-blue-50 border-blue-200'];
        @endphp
        <div class="{{ $colors[$s->balance_type] ?? 'bg-gray-50' }} rounded-xl p-5 border shadow-sm">
            <p class="text-sm font-medium">{{ $icons[$s->balance_type] ?? '' }} {{ $labels[$s->balance_type] ?? $s->balance_type }}</p>
            <div class="mt-2 space-y-1 text-sm">
                <div class="flex justify-between">
                    <span class="text-gray-500">Kredit:</span>
                    <span class="font-semibold text-emerald-600">Rp {{ number_format($s->total_credit, 0, ',', '.') }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">Debit:</span>
                    <span class="font-semibold text-red-600">Rp {{ number_format($s->total_debit, 0, ',', '.') }}</span>
                </div>
                <div class="flex justify-between border-t pt-1 mt-1">
                    <span class="text-gray-500">Total Transaksi:</span>
                    <span class="font-semibold">{{ $s->count }}x</span>
                </div>
            </div>
        </div>
        @endforeach
    </div>

    {{-- Tabel --}}
    <div class="bg-white rounded-xl border shadow-sm overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900">Riwayat Lengkap</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="bg-gray-50 text-gray-500 text-left">
                        <th class="px-6 py-3 font-medium">User</th>
                        <th class="px-6 py-3 font-medium">Role</th>
                        <th class="px-6 py-3 font-medium">Jenis</th>
                        <th class="px-6 py-3 font-medium">Tipe</th>
                        <th class="px-6 py-3 font-medium">Jumlah</th>
                        <th class="px-6 py-3 font-medium">Saldo Awal</th>
                        <th class="px-6 py-3 font-medium">Saldo Akhir</th>
                        <th class="px-6 py-3 font-medium">Deskripsi</th>
                        <th class="px-6 py-3 font-medium">Tanggal</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    @forelse($histories as $h)
                    @php
                        $balanceTypeIcons = ['coin' => '🪙', 'cash' => '💰', 'commission' => '📊'];
                        $balanceTypeLabels = ['coin' => 'Koin', 'cash' => 'Tunai', 'commission' => 'Komisi'];
                    @endphp
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4">
                            <div class="font-medium text-gray-900">{{ $h->wallet->user->name ?? '—' }}</div>
                            <div class="text-xs text-gray-400">{{ $h->wallet->user->email ?? '' }}</div>
                        </td>
                        <td class="px-6 py-4">
                            @php
                                $roleColors = ['admin' => 'bg-purple-100 text-purple-700', 'umkm' => 'bg-emerald-100 text-emerald-700', 'konsumen' => 'bg-blue-100 text-blue-700'];
                            @endphp
                            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium {{ $roleColors[$h->wallet->user->role] ?? 'bg-gray-100' }}">
                                {{ ucfirst($h->wallet->user->role ?? '') }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            {{ $balanceTypeIcons[$h->balance_type] ?? '' }}
                            {{ $balanceTypeLabels[$h->balance_type] ?? $h->balance_type }}
                        </td>
                        <td class="px-6 py-4">
                            @if($h->type === 'credit')
                            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-700">Kredit +</span>
                            @else
                            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-700">Debit -</span>
                            @endif
                        </td>
                        <td class="px-6 py-4 font-mono font-medium">Rp {{ number_format($h->amount, 0, ',', '.') }}</td>
                        <td class="px-6 py-4 font-mono text-gray-500">Rp {{ number_format($h->balance_before, 0, ',', '.') }}</td>
                        <td class="px-6 py-4 font-mono font-medium">Rp {{ number_format($h->balance_after, 0, ',', '.') }}</td>
                        <td class="px-6 py-4 text-gray-600 max-w-xs truncate" title="{{ $h->description }}">{{ $h->description }}</td>
                        <td class="px-6 py-4 text-gray-500 whitespace-nowrap">{{ $h->created_at->format('d M Y H:i') }}</td>
                    </tr>
                    @empty
                    <tr><td colspan="9" class="px-6 py-8 text-center text-gray-400">Belum ada mutasi dana.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($histories->hasPages())
        <div class="px-6 py-4 border-t">
            {{ $histories->links() }}
        </div>
        @endif
    </div>
</div>
@endsection