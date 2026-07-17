<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — LOKAL Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .sidebar-item { transition: all 0.2s ease; }
        .sidebar-item:hover { background: rgba(255,255,255,0.08); }
        .sidebar-item.active { background: rgba(255,255,255,0.12); border-left: 3px solid #3b82f6; }
        .stat-card { transition: all 0.3s ease; }
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 12px 30px rgba(0,0,0,0.08); }
        .sidebar-gradient { background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%); }
    </style>
</head>
<body class="bg-gray-50 antialiased">

    <div class="flex h-screen overflow-hidden">

        
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
                
                <a href="<?php echo e(route('admin.dashboard')); ?>" class="sidebar-item active flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium">
                    <svg class="w-5 h-5 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>
                    Dashboard
                </a>

                
                <a href="<?php echo e(route('admin.umkm.index')); ?>" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
                    Verifikasi UMKM
                    <?php if($stats['umkm_pending'] > 0): ?>
                    <span class="ml-auto bg-amber-500 text-white text-xs font-bold px-2 py-0.5 rounded-full"><?php echo e($stats['umkm_pending']); ?></span>
                    <?php endif; ?>
                </a>

                
                <a href="<?php echo e(route('admin.bank-verification.index')); ?>" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/></svg>
                    Verifikasi Bank
                </a>

                
                <a href="<?php echo e(route('admin.products.index')); ?>" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 17V7m0 10a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2h2a2 2 0 012 2m0 10a2 2 0 002 2h2a2 2 0 002-2M9 7a2 2 0 012-2h2a2 2 0 012 2m0 10V7"/></svg>
                    Produk
                </a>

                
                <a href="<?php echo e(route('admin.orders.index')); ?>" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    Transaksi Order
                </a>

                
                <a href="<?php echo e(route('admin.wallets.index')); ?>" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/></svg>
                    Manajemen Wallet
                </a>

                
                <a href="<?php echo e(route('admin.wallet-histories.index')); ?>" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/></svg>
                    Riwayat Mutasi
                </a>

                
                <a href="<?php echo e(route('admin.coins.index')); ?>" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    Riwayat Koin
                </a>

                
                <a href="<?php echo e(route('admin.settings.index')); ?>" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.066 2.573c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.573 1.066c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.066-2.573c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                    Pengaturan
                </a>
            </nav>

            
            <div class="px-4 py-4 border-t border-white/10">
                <div class="flex items-center gap-3">
                    <div class="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-xs font-bold uppercase">
                        <?php echo e(strtoupper(substr(auth()->user()->name ?? 'A', 0, 1))); ?>

                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium truncate"><?php echo e(auth()->user()->name ?? 'Admin'); ?></p>
                        <p class="text-xs text-gray-400 truncate"><?php echo e(auth()->user()->email ?? ''); ?></p>
                    </div>
                    <form method="POST" action="<?php echo e(route('admin.logout')); ?>">
                        <?php echo csrf_field(); ?>
                        <button type="submit" class="p-1.5 hover:bg-white/10 rounded-lg transition" title="Logout">
                            <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                        </button>
                    </form>
                </div>
            </div>
        </aside>

        
        <div class="flex-1 flex flex-col min-w-0">

            
            <header class="lg:hidden bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between">
                <div class="flex items-center gap-2">
                    <div class="w-8 h-8 rounded-lg bg-gray-900 flex items-center justify-center text-white font-bold text-sm">L</div>
                    <span class="font-bold text-gray-900">LOKAL Admin</span>
                </div>
                <form method="POST" action="<?php echo e(route('admin.logout')); ?>">
                    <?php echo csrf_field(); ?>
                    <button type="submit" class="p-2 hover:bg-gray-100 rounded-lg transition">
                        <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                    </button>
                </form>
            </header>

            
            <main class="flex-1 overflow-y-auto p-6 lg:p-8">

                
                <div class="mb-8">
                    <h1 class="text-2xl lg:text-3xl font-extrabold text-gray-900">Dashboard</h1>
                    <p class="text-gray-500 mt-1">Ringkasan data platform LOKAL dan sirkulasi dana.</p>
                </div>

                
                <?php if(session('success')): ?>
                <div class="mb-6 p-4 bg-emerald-50 border border-emerald-200 rounded-xl">
                    <p class="text-sm font-medium text-emerald-700"><?php echo e(session('success')); ?></p>
                </div>
                <?php endif; ?>

                
                <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-8">
                    
                    <div class="stat-card bg-white rounded-2xl p-5 lg:p-6 border border-gray-100 shadow-sm">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-10 h-10 rounded-xl bg-blue-100 flex items-center justify-center">
                                <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>
                            </div>
                            <span class="text-xs font-medium text-gray-400 bg-gray-50 px-2 py-1 rounded-full">Total</span>
                        </div>
                        <p class="text-2xl lg:text-3xl font-extrabold text-gray-900"><?php echo e($stats['total_umkm']); ?></p>
                        <p class="text-sm text-gray-500 mt-1">UMKM Terdaftar</p>
                    </div>

                    
                    <div class="stat-card bg-white rounded-2xl p-5 lg:p-6 border border-gray-100 shadow-sm">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-10 h-10 rounded-xl bg-amber-100 flex items-center justify-center">
                                <svg class="w-5 h-5 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                            </div>
                            <span class="text-xs font-medium text-amber-600 bg-amber-50 px-2 py-1 rounded-full">Pending</span>
                        </div>
                        <p class="text-2xl lg:text-3xl font-extrabold text-amber-600"><?php echo e($stats['umkm_pending']); ?></p>
                        <p class="text-sm text-gray-500 mt-1">Menunggu Verifikasi</p>
                    </div>

                    
                    <div class="stat-card bg-white rounded-2xl p-5 lg:p-6 border border-gray-100 shadow-sm">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-10 h-10 rounded-xl bg-emerald-100 flex items-center justify-center">
                                <svg class="w-5 h-5 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                            </div>
                            <span class="text-xs font-medium text-emerald-600 bg-emerald-50 px-2 py-1 rounded-full">Verified</span>
                        </div>
                        <p class="text-2xl lg:text-3xl font-extrabold text-emerald-600"><?php echo e($stats['umkm_verified']); ?></p>
                        <p class="text-sm text-gray-500 mt-1">UMKM Terverifikasi</p>
                    </div>

                    
                    <div class="stat-card bg-white rounded-2xl p-5 lg:p-6 border border-gray-100 shadow-sm">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-10 h-10 rounded-xl bg-purple-100 flex items-center justify-center">
                                <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/></svg>
                            </div>
                            <span class="text-xs font-medium text-purple-600 bg-purple-50 px-2 py-1 rounded-full">Aktif</span>
                        </div>
                        <p class="text-2xl lg:text-3xl font-extrabold text-purple-600"><?php echo e($stats['total_products']); ?></p>
                        <p class="text-sm text-gray-500 mt-1">Produk Aktif</p>
                    </div>
                </div>

                
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-8">
                    
                    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <div class="flex items-center gap-3 mb-3">
                            <div class="w-8 h-8 rounded-lg bg-orange-100 flex items-center justify-center">
                                <svg class="w-4 h-4 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>
                            </div>
                            <span class="text-sm font-semibold text-gray-700">Total Orders</span>
                        </div>
                        <p class="text-xl font-extrabold text-gray-900"><?php echo e($stats['total_orders']); ?></p>
                    </div>

                    
                    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <div class="flex items-center gap-3 mb-3">
                            <div class="w-8 h-8 rounded-lg bg-green-100 flex items-center justify-center">
                                <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                            </div>
                            <span class="text-sm font-semibold text-gray-700">Revenue</span>
                        </div>
                        <p class="text-xl font-extrabold text-gray-900">Rp <?php echo e(number_format($stats['total_revenue'], 0, ',', '.')); ?></p>
                    </div>

                    
                    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <div class="flex items-center gap-3 mb-3">
                            <div class="w-8 h-8 rounded-lg bg-cyan-100 flex items-center justify-center">
                                <svg class="w-4 h-4 text-cyan-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                            </div>
                            <span class="text-sm font-semibold text-gray-700">Transaksi Koin</span>
                        </div>
                        <p class="text-xl font-extrabold text-gray-900"><?php echo e($stats['total_coin_transactions']); ?></p>
                    </div>

                    
                    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <div class="flex items-center gap-3 mb-3">
                            <div class="w-8 h-8 rounded-lg bg-indigo-100 flex items-center justify-center">
                                <svg class="w-4 h-4 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>
                            </div>
                            <span class="text-sm font-semibold text-gray-700">Total Users</span>
                        </div>
                        <p class="text-xl font-extrabold text-gray-900"><?php echo e($stats['total_users']); ?></p>
                    </div>
                </div>

                
                <div class="mb-6">
                    <h2 class="text-xl font-bold text-gray-900 mb-4">💰 Sirkulasi Dana Platform</h2>
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-8">
                    
                    <div class="stat-card bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <div class="flex items-center gap-3 mb-3">
                            <div class="w-8 h-8 rounded-lg bg-blue-100 flex items-center justify-center">
                                <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                            </div>
                            <span class="text-sm font-semibold text-gray-700">Saldo Komisi Admin</span>
                        </div>
                        <p class="text-xl font-extrabold text-blue-600">Rp <?php echo e(number_format($stats['commission_balance'], 0, ',', '.')); ?></p>
                        <p class="text-xs text-gray-400 mt-1">Dari potongan 5% transaksi</p>
                    </div>

                    
                    <div class="stat-card bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <div class="flex items-center gap-3 mb-3">
                            <div class="w-8 h-8 rounded-lg bg-emerald-100 flex items-center justify-center">
                                <svg class="w-4 h-4 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
                            </div>
                            <span class="text-sm font-semibold text-gray-700">Total Saldo UMKM</span>
                        </div>
                        <p class="text-xl font-extrabold text-emerald-600">Rp <?php echo e(number_format($stats['total_umkm_cash'], 0, ',', '.')); ?></p>
                        <p class="text-xs text-gray-400 mt-1">Bisa ditarik oleh UMKM</p>
                    </div>

                    
                    <div class="stat-card bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <div class="flex items-center gap-3 mb-3">
                            <div class="w-8 h-8 rounded-lg bg-amber-100 flex items-center justify-center">
                                <svg class="w-4 h-4 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                            </div>
                            <span class="text-sm font-semibold text-gray-700">Total Koin Konsumen</span>
                        </div>
                        <p class="text-xl font-extrabold text-amber-600"><?php echo e(number_format($stats['total_consumer_coin'], 0, ',', '.')); ?> 🪙</p>
                        <p class="text-xs text-gray-400 mt-1">~ Rp <?php echo e(number_format($stats['total_consumer_coin'] * 10, 0, ',', '.')); ?></p>
                    </div>

                    
                    <div class="stat-card bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <div class="flex items-center gap-3 mb-3">
                            <div class="w-8 h-8 rounded-lg bg-purple-100 flex items-center justify-center">
                                <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/></svg>
                            </div>
                            <span class="text-sm font-semibold text-gray-700">Mutasi Hari Ini</span>
                        </div>
                        <p class="text-xl font-extrabold text-purple-600"><?php echo e($stats['today_mutations']); ?></p>
                        <p class="text-xs text-gray-400 mt-1">Transaksi tercatat</p>
                    </div>
                </div>

                
                <div class="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm mb-8">
                    <h3 class="text-lg font-bold text-gray-900 mb-4">📈 Komisi Masuk (7 Hari Terakhir)</h3>
                    <div class="flex items-end gap-2 h-32">
                        <?php $__currentLoopData = $stats['commission_chart']; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $day): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                        <?php
                            $maxTotal = $stats['commission_chart']->max('total');
                            $height = $maxTotal > 0 ? ($day['total'] / $maxTotal) * 100 : 0;
                            $dayName = \Carbon\Carbon::parse($day['date'])->isoFormat('dd');
                        ?>
                        <div class="flex-1 flex flex-col items-center gap-1">
                            <span class="text-xs text-gray-400 font-medium">Rp<?php echo e(number_format($day['total'], 0, ',', '.')); ?></span>
                            <div class="w-full bg-blue-50 rounded-t-lg relative" style="height: 100px;">
                                <div class="absolute bottom-0 w-full bg-blue-500 rounded-t-lg transition-all duration-300" style="height: <?php echo e($height); ?>%;"></div>
                            </div>
                            <span class="text-xs text-gray-500"><?php echo e($dayName); ?></span>
                        </div>
                        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
                    </div>
                </div>

                
                <p class="mt-8 text-center text-xs text-gray-400">
                    &copy; <?php echo e(date('Y')); ?> LOKAL App — Panel Admin v2.0
                </p>

            </main>
        </div>

    </div>

</body>
</html><?php /**PATH C:\laragon\www\ekonomi_lokal\backend\resources\views/admin/dashboard.blade.php ENDPATH**/ ?>