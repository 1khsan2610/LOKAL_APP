<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ isset($setting) ? 'Edit' : 'Tambah' }} Pengaturan — LOKAL Admin</title>
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
                <a href="{{ route('admin.bank-verification.index') }}" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/></svg>
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
                <a href="{{ route('admin.settings.index') }}" class="sidebar-item active flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium">
                    <svg class="w-5 h-5 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.066 2.573c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.573 1.066c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.066-2.573c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
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
                    <h1 class="text-2xl lg:text-3xl font-extrabold text-gray-900">
                        {{ isset($setting) ? '✏️ Edit Pengaturan' : '➕ Tambah Pengaturan' }}
                    </h1>
                    <p class="text-gray-500 mt-1">{{ isset($setting) ? 'Ubah nilai pengaturan yang sudah ada.' : 'Buat pengaturan baru untuk platform.' }}</p>
                </div>

                @if ($errors->any())
                <div class="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl">
                    <ul class="list-disc list-inside text-sm text-red-700">
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
                @endif

                <div class="bg-white rounded-2xl p-6 lg:p-8 border border-gray-100 shadow-sm max-w-2xl">
                    <form method="POST" action="{{ isset($setting) ? route('admin.settings.update', $setting->id) : route('admin.settings.store') }}">
                        @csrf
                        @if (isset($setting))
                        @method('PUT')
                        @endif

                        {{-- Key --}}
                        <div class="mb-5">
                            <label for="key" class="block text-sm font-semibold text-gray-700 mb-2">
                                Key <span class="text-red-500">*</span>
                            </label>
                            <input type="text" name="key" id="key" required
                                value="{{ old('key', $setting->key ?? '') }}"
                                class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm font-mono"
                                placeholder="contoh: commission_percent">
                            <p class="text-xs text-gray-400 mt-1.5">Identifier unik untuk pengaturan ini (gunakan snake_case).</p>
                        </div>

                        {{-- Label --}}
                        <div class="mb-5">
                            <label for="label" class="block text-sm font-semibold text-gray-700 mb-2">
                                Label <span class="text-red-500">*</span>
                            </label>
                            <input type="text" name="label" id="label" required
                                value="{{ old('label', $setting->label ?? '') }}"
                                class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
                                placeholder="contoh: Komisi Platform (%)">
                            <p class="text-xs text-gray-400 mt-1.5">Nama tampilan untuk pengaturan ini.</p>
                        </div>

                        {{-- Value --}}
                        <div class="mb-5">
                            <label for="value" class="block text-sm font-semibold text-gray-700 mb-2">
                                Value <span class="text-red-500">*</span>
                            </label>
                            <input type="text" name="value" id="value" required
                                value="{{ old('value', $setting->value ?? '') }}"
                                class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
                                placeholder="contoh: 5">
                            <p class="text-xs text-gray-400 mt-1.5">Nilai dari pengaturan ini.</p>
                        </div>

                        {{-- Group --}}
                        <div class="mb-8">
                            <label for="group" class="block text-sm font-semibold text-gray-700 mb-2">
                                Group <span class="text-red-500">*</span>
                            </label>
                            <select name="group" id="group" required
                                class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm">
                                <option value="payment" {{ (old('group', $setting->group ?? '') === 'payment') ? 'selected' : '' }}>Payment</option>
                                <option value="general" {{ (old('group', $setting->group ?? '') === 'general') ? 'selected' : '' }}>General</option>
                                <option value="commission" {{ (old('group', $setting->group ?? '') === 'commission') ? 'selected' : '' }}>Commission</option>
                                <option value="feature" {{ (old('group', $setting->group ?? '') === 'feature') ? 'selected' : '' }}>Feature</option>
                                <option value="other" {{ (old('group', $setting->group ?? '') === 'other') ? 'selected' : '' }}>Other</option>
                            </select>
                            <p class="text-xs text-gray-400 mt-1.5">Kategori untuk mengelompokkan pengaturan.</p>
                        </div>

                        <div class="flex items-center gap-3 pt-4 border-t border-gray-100">
                            <button type="submit"
                                class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-xl transition text-sm">
                                {{ isset($setting) ? '💾 Simpan Perubahan' : '➕ Tambah Pengaturan' }}
                            </button>
                            <a href="{{ route('admin.settings.index') }}"
                                class="px-6 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium rounded-xl transition text-sm">
                                Batal
                            </a>
                        </div>
                    </form>
                </div>

                <p class="mt-8 text-center text-xs text-gray-400">
                    &copy; {{ date('Y') }} LOKAL App — Panel Admin v2.0
                </p>

            </main>
        </div>

    </div>

</body>
</html>