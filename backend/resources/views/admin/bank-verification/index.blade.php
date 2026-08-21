@extends('layouts.admin')

@section('title', 'Verifikasi Bank — LOKAL Admin')

@section('content')
<div class="mb-8">
    <h1 class="text-2xl lg:text-3xl font-extrabold text-gray-900">🏦 Verifikasi Rekening Bank UMKM</h1>
    <p class="text-gray-500 mt-1">Setujui atau tolak rekening bank yang diajukan oleh UMKM untuk penarikan dana.</p>
</div>

@if (session('success'))
<div class="mb-6 p-4 bg-emerald-50 border border-emerald-200 rounded-xl">
    <p class="text-sm font-medium text-emerald-700">{{ session('success') }}</p>
</div>
@endif

@if ($errors->any())
<div class="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl">
    <ul class="list-disc list-inside text-sm text-red-700">
        @foreach ($errors->all() as $error)
            <li>{{ $error }}</li>
        @endforeach
    </ul>
</div>
@endif

{{-- Pending Accounts --}}
<div class="mb-10">
    <h2 class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
        <span class="w-2.5 h-2.5 rounded-full bg-amber-400 inline-block"></span>
        Menunggu Verifikasi
        <span class="text-sm font-normal text-gray-400">({{ $pendingAccounts->total() }})</span>
    </h2>

    @if ($pendingAccounts->count() === 0)
        <div class="bg-white rounded-2xl p-8 border border-gray-100 shadow-sm text-center">
            <p class="text-gray-400">Tidak ada rekening bank yang menunggu verifikasi.</p>
        </div>
    @else
        <div class="space-y-4">
            @foreach ($pendingAccounts as $account)
            <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                <div class="flex items-start justify-between gap-4">
                    <div class="flex-1">
                        <div class="flex items-center gap-2 mb-2">
                            <span class="px-2.5 py-0.5 bg-amber-100 text-amber-700 text-xs font-semibold rounded-full">Pending</span>
                            <span class="text-sm text-gray-400">{{ $account->created_at->format('d M Y H:i') }}</span>
                        </div>
                        <h3 class="text-base font-semibold text-gray-900">{{ $account->bank_name }}</h3>
                        <p class="text-sm text-gray-600 mt-1">
                            <span class="font-medium">No. Rekening:</span> {{ $account->account_number }}
                        </p>
                        <p class="text-sm text-gray-600">
                            <span class="font-medium">A/N:</span> {{ $account->account_holder }}
                        </p>
                        @if ($account->umkm)
                        <p class="text-sm text-gray-500 mt-1">
                            <span class="font-medium">UMKM:</span> {{ $account->umkm->name }}
                            @if ($account->umkm->is_verified)
                                <span class="ml-1 text-xs text-emerald-600 bg-emerald-50 px-1.5 py-0.5 rounded">Verified</span>
                            @else
                                <span class="ml-1 text-xs text-amber-600 bg-amber-50 px-1.5 py-0.5 rounded">Unverified</span>
                            @endif
                        </p>
                        @endif
                    </div>
                    <div class="flex items-center gap-2 flex-shrink-0">
                        <form method="POST" action="{{ route('admin.bank-verification.approve', $account->id) }}">
                            @csrf
                            <button type="submit" class="px-4 py-2 bg-emerald-500 hover:bg-emerald-600 text-white text-sm font-semibold rounded-xl transition">
                                Setujui
                            </button>
                        </form>
                        <button type="button" onclick="openRejectModal({{ $account->id }}, '{{ $account->bank_name }}', '{{ $account->account_holder }}')"
                            class="px-4 py-2 bg-red-100 hover:bg-red-200 text-red-700 text-sm font-medium rounded-xl transition">
                            Tolak
                        </button>
                    </div>
                </div>
            </div>
            @endforeach
        </div>

        <div class="mt-4">
            {{ $pendingAccounts->links() }}
        </div>
    @endif
</div>

{{-- Approved Accounts --}}
<div>
    <h2 class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
        <span class="w-2.5 h-2.5 rounded-full bg-emerald-400 inline-block"></span>
        Riwayat Verifikasi
        <span class="text-sm font-normal text-gray-400">({{ $approvedAccounts->total() }})</span>
    </h2>

    @if ($approvedAccounts->count() === 0)
        <div class="bg-white rounded-2xl p-8 border border-gray-100 shadow-sm text-center">
            <p class="text-gray-400">Belum ada riwayat verifikasi.</p>
        </div>
    @else
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-100">
                            <th class="text-left px-4 py-3 font-semibold text-gray-600">Bank</th>
                            <th class="text-left px-4 py-3 font-semibold text-gray-600">No. Rekening</th>
                            <th class="text-left px-4 py-3 font-semibold text-gray-600">A/N</th>
                            <th class="text-left px-4 py-3 font-semibold text-gray-600">UMKM</th>
                            <th class="text-left px-4 py-3 font-semibold text-gray-600">Status</th>
                            <th class="text-left px-4 py-3 font-semibold text-gray-600">Diverifikasi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-50">
                        @foreach ($approvedAccounts as $account)
                        <tr class="hover:bg-gray-50/50">
                            <td class="px-4 py-3 font-medium text-gray-900">{{ $account->bank_name }}</td>
                            <td class="px-4 py-3 text-gray-700">{{ $account->account_number }}</td>
                            <td class="px-4 py-3 text-gray-700">{{ $account->account_holder }}</td>
                            <td class="px-4 py-3 text-gray-700">{{ $account->umkm?->name ?? '-' }}</td>
                            <td class="px-4 py-3">
                                @if ($account->status === 'approved')
                                    <span class="px-2 py-0.5 bg-emerald-100 text-emerald-700 text-xs font-semibold rounded-full">Disetujui</span>
                                @elseif ($account->status === 'rejected')
                                    <span class="px-2 py-0.5 bg-red-100 text-red-700 text-xs font-semibold rounded-full" title="{{ $account->rejection_reason }}">Ditolak</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 text-gray-500 text-xs">
                                {{ $account->verified_at ? $account->verified_at->format('d M Y H:i') : '-' }}
                                @if ($account->verifier)
                                    <br>oleh {{ $account->verifier->name }}
                                @endif
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>

        <div class="mt-4">
            {{ $approvedAccounts->links() }}
        </div>
    @endif
</div>

<p class="mt-8 text-center text-xs text-gray-400">
    &copy; {{ date('Y') }} LOKAL App — Panel Admin v2.0
</p>

{{-- Reject Modal --}}
<div id="rejectModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 hidden">
    <div class="bg-white rounded-2xl p-6 w-full max-w-md mx-4 shadow-2xl">
        <h3 class="text-lg font-bold text-gray-900 mb-2">Tolak Rekening Bank</h3>
        <p class="text-sm text-gray-500 mb-4" id="rejectModalInfo">Masukkan alasan penolakan.</p>

        <form method="POST" action="" id="rejectForm">
            @csrf
            <div class="mb-4">
                <label for="rejection_reason" class="block text-sm font-semibold text-gray-700 mb-2">Alasan Penolakan</label>
                <textarea name="rejection_reason" id="rejection_reason" rows="3" required
                    class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 text-sm"
                    placeholder="Contoh: Nomor rekening tidak valid..."></textarea>
            </div>
            <div class="flex items-center gap-3 justify-end">
                <button type="button" onclick="closeRejectModal()"
                    class="px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium rounded-xl transition text-sm">
                    Batal
                </button>
                <button type="submit"
                    class="px-4 py-2 bg-red-500 hover:bg-red-600 text-white font-semibold rounded-xl transition text-sm">
                    Tolak Rekening
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    function openRejectModal(id, bankName, accountHolder) {
        document.getElementById('rejectModalInfo').textContent = 'Menolak ' + bankName + ' a/n ' + accountHolder;
        document.getElementById('rejectForm').action = '/admin/verifikasi-bank/' + id + '/reject';
        document.getElementById('rejectModal').classList.remove('hidden');
    }

    function closeRejectModal() {
        document.getElementById('rejectModal').classList.add('hidden');
    }

    // Close modal on backdrop click
    document.getElementById('rejectModal').addEventListener('click', function(e) {
        if (e.target === this) closeRejectModal();
    });
</script>
@endsection