<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verifikasi Bank — LOKAL Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .sidebar-item { transition: all 0.2s ease; }
        .sidebar-item:hover { background: rgba(255,255,255,0.08); }
        .sidebar-item.active { background: rgba(255,255,255,0.12); border-left: 3px solid #3b82f6; }
        .sidebar-gradient { background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%); }
    </style>
</head>
<body class="bg-gray-50 antialiased">

    <div class="flex h-screen overflow-hidden">

        {{-- ===== SIDEBAR ===== --}}
        <aside class="hidden lg:flex lg:flex-col w-64 sidebar-gradient text-white flex-shrink-0">
            <div class="px-6 py-6 border-b border-white/10">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-xl bg-blue-500 flex items-center justify-center font-extrabold text-lg">L</div>
                    <div>
                        <h1 class="font-bold text-base leading-tight">LOKAL</h1>
                        <p class="text-xs text-gray-400">Admin Panel</p>
                    </div>
                </div>
            </div>

            <nav class="flex-1 px-3 py-6 space-y-1 overflow-y-auto">
                <a href="{{ route('admin.dashboard') }}" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>
                    Dashboard
                </a>
                <a href="{{ route('admin.umkm.index') }}" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
                    Verifikasi UMKM
                </a>
                <a href="{{ route('admin.bank-verification.index') }}" class="sidebar-item active flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium">
                    <svg class="w-5 h-5 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/></svg>
                    Verifikasi Bank
                </a>
                <a href="{{ route('admin.products.index') }}" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 17V7m0 10a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2h2a2 2 0 012 2m0 10a2 2 0 002 2h2a2 2 0 002-2M9 7a2 2 0 012-2h2a2 2 0 012 2m0 10V7"/></svg>
                    Produk
                </a>
                <a href="{{ route('admin.orders.index') }}" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    Transaksi Order
                </a>
                <a href="{{ route('admin.wallets.index') }}" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/></svg>
                    Manajemen Wallet
                </a>
                <a href="{{ route('admin.wallet-histories.index') }}" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/></svg>
                    Riwayat Mutasi
                </a>
                <a href="{{ route('admin.coins.index') }}" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    Riwayat Koin
                </a>
                <a href="{{ route('admin.settings.index') }}" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.066 2.573c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.573 1.066c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.066-2.573c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                    Pengaturan
                </a>
            </nav>

            <div class="px-4 py-4 border-t border-white/10">
                <div class="flex items-center gap-3">
                    <div class="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-xs font-bold uppercase">
                        {{ strtoupper(substr(auth()->user()->name ?? 'A', 0, 1)) }}
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium truncate">{{ auth()->user()->name ?? 'Admin' }}</p>
                        <p class="text-xs text-gray-400 truncate">{{ auth()->user()->email ?? '' }}</p>
                    </div>
                    <form method="POST" action="{{ route('admin.logout') }}">
                        @csrf
                        <button type="submit" class="p-1.5 hover:bg-white/10 rounded-lg transition" title="Logout">
                            <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                        </button>
                    </form>
                </div>
            </div>
        </aside>

        {{-- ===== MAIN CONTENT ===== --}}
        <div class="flex-1 flex flex-col min-w-0">

            <header class="lg:hidden bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between">
                <div class="flex items-center gap-2">
                    <div class="w-8 h-8 rounded-lg bg-gray-900 flex items-center justify-center text-white font-bold text-sm">L</div>
                    <span class="font-bold text-gray-900">LOKAL Admin</span>
                </div>
                <form method="POST" action="{{ route('admin.logout') }}">
                    @csrf
                    <button type="submit" class="p-2 hover:bg-gray-100 rounded-lg transition">
                        <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                    </button>
                </form>
            </header>

            <main class="flex-1 overflow-y-auto p-6 lg:p-8">

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

            </main>
        </div>

    </div>

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

</body>
</html>