<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login — LOKAL App</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .login-gradient { background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 50%, #0f172a 100%); }
    </style>
</head>
<body class="bg-gray-50 antialiased">
    <div class="min-h-screen flex">

        {{-- Left Side — Branding / Visual --}}
        <div class="hidden lg:flex lg:w-1/2 login-gradient relative items-center justify-center p-12">
            <div class="relative z-10 text-center max-w-md">
                <div class="w-24 h-24 mx-auto mb-8 rounded-full bg-white/10 flex items-center justify-center border border-white/20">
                    <span class="text-4xl font-extrabold text-white">L</span>
                </div>
                <h1 class="text-4xl font-extrabold text-white mb-4">LOKAL Admin</h1>
                <p class="text-gray-300 leading-relaxed">
                    Kelola UMKM, pantau transaksi, dan kendalikan ekosistem koin dari satu panel terpadu.
                </p>
                <div class="mt-10 space-y-4 text-left">
                    <div class="flex items-center gap-4 text-gray-300">
                        <div class="w-8 h-8 rounded-lg bg-emerald-500/20 flex items-center justify-center flex-shrink-0">
                            <svg class="w-4 h-4 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                        </div>
                        <span class="text-sm">Verifikasi & kelola data UMKM</span>
                    </div>
                    <div class="flex items-center gap-4 text-gray-300">
                        <div class="w-8 h-8 rounded-lg bg-emerald-500/20 flex items-center justify-center flex-shrink-0">
                            <svg class="w-4 h-4 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                        </div>
                        <span class="text-sm">Pantau transaksi & pendapatan</span>
                    </div>
                    <div class="flex items-center gap-4 text-gray-300">
                        <div class="w-8 h-8 rounded-lg bg-emerald-500/20 flex items-center justify-center flex-shrink-0">
                            <svg class="w-4 h-4 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                        </div>
                        <span class="text-sm">Atur sistem koin & loyalitas</span>
                    </div>
                </div>
            </div>
            {{-- Decorative blur --}}
            <div class="w-96 h-96 bg-cyan-400/10 rounded-full absolute -bottom-20 -left-20 blur-3xl"></div>
            <div class="w-64 h-64 bg-blue-500/10 rounded-full absolute -top-10 -right-10 blur-3xl"></div>
        </div>

        {{-- Right Side — Login Form --}}
        <div class="w-full lg:w-1/2 flex items-center justify-center p-8 sm:p-12">
            <div class="w-full max-w-sm">
                {{-- Logo Mobile --}}
                <div class="lg:hidden text-center mb-8">
                    <div class="w-16 h-16 mx-auto rounded-full bg-gray-900 flex items-center justify-center mb-3">
                        <span class="text-2xl font-extrabold text-white">L</span>
                    </div>
                    <h2 class="text-2xl font-bold text-gray-900">LOKAL Admin</h2>
                    <p class="text-sm text-gray-500 mt-1">Masuk ke panel admin</p>
                </div>

                <h2 class="hidden lg:block text-2xl font-bold text-gray-900 mb-2">Selamat Datang Kembali</h2>
                <p class="hidden lg:block text-sm text-gray-500 mb-8">Masuk untuk mengelola panel admin LOKAL.</p>

                @if ($errors->any())
                <div class="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl">
                    <div class="flex items-center gap-2">
                        <svg class="w-5 h-5 text-red-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        <p class="text-sm font-medium text-red-700">{{ $errors->first('email') }}</p>
                    </div>
                </div>
                @endif

                @if (session('status'))
                <div class="mb-6 p-4 bg-green-50 border border-green-200 rounded-xl">
                    <p class="text-sm font-medium text-green-700">{{ session('status') }}</p>
                </div>
                @endif

                <form method="POST" action="{{ route('login') }}" class="space-y-5">
                    @csrf

                    {{-- Email --}}
                    <div>
                        <label for="email" class="block text-sm font-medium text-gray-700 mb-1.5">Email Admin</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
                            </div>
                            <input type="email" name="email" id="email" value="{{ old('email') }}"
                                   class="w-full pl-11 pr-4 py-3 border border-gray-200 rounded-xl text-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all @error('email') border-red-300 bg-red-50 @enderror"
                                   placeholder="admin@lokal.app" required autofocus autocomplete="email">
                        </div>
                    </div>

                    {{-- Password --}}
                    <div>
                        <label for="password" class="block text-sm font-medium text-gray-700 mb-1.5">Password</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                            </div>
                            <input type="password" name="password" id="password"
                                   class="w-full pl-11 pr-4 py-3 border border-gray-200 rounded-xl text-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all @error('password') border-red-300 bg-red-50 @enderror"
                                   placeholder="••••••••" required autocomplete="current-password">
                        </div>
                    </div>

                    {{-- Remember + Submit --}}
                    <div class="flex items-center justify-between">
                        <label class="flex items-center gap-2 cursor-pointer">
                            <input type="checkbox" name="remember" class="w-4 h-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500">
                            <span class="text-sm text-gray-600">Ingat saya</span>
                        </label>
                    </div>

                    <button type="submit"
                            class="w-full py-3 px-4 bg-gray-900 hover:bg-gray-800 text-white font-semibold rounded-xl transition-all duration-200 shadow-lg shadow-gray-900/20 focus:outline-none focus:ring-2 focus:ring-gray-900/50">
                        Masuk ke Dashboard
                    </button>
                </form>

                <p class="mt-8 text-center text-xs text-gray-400">
                    &copy; {{ date('Y') }} LOKAL App. Hanya untuk admin terdaftar.
                </p>
            </div>
        </div>

    </div>
</body>
</html>