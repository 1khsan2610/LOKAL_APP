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
                <a href="<?php echo e(route('admin.dashboard')); ?>" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>
                    Dashboard
                </a>
                <a href="<?php echo e(route('admin.umkm.index')); ?>" class="sidebar-item flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-gray-300">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
                    Verifikasi UMKM
                </a>
                <a href="<?php echo e(route('admin.bank-verification.index')); ?>" class="sidebar-item active flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium">
                    <svg class="w-5 h-5 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/></svg>
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
                    <h1 class="text-2xl lg:text-3xl font-extrabold text-gray-900">🏦 Verifikasi Rekening Bank UMKM</h1>
                    <p class="text-gray-500 mt-1">Setujui atau tolak rekening bank yang diajukan oleh UMKM untuk penarikan dana.</p>
                </div>

                <?php if(session('success')): ?>
                <div class="mb-6 p-4 bg-emerald-50 border border-emerald-200 rounded-xl">
                    <p class="text-sm font-medium text-emerald-700"><?php echo e(session('success')); ?></p>
                </div>
                <?php endif; ?>

                <?php if($errors->any()): ?>
                <div class="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl">
                    <ul class="list-disc list-inside text-sm text-red-700">
                        <?php $__currentLoopData = $errors->all(); $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $error): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                            <li><?php echo e($error); ?></li>
                        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
                    </ul>
                </div>
                <?php endif; ?>

                
                <div class="mb-10">
                    <h2 class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                        <span class="w-2.5 h-2.5 rounded-full bg-amber-400 inline-block"></span>
                        Menunggu Verifikasi
                        <span class="text-sm font-normal text-gray-400">(<?php echo e($pendingAccounts->total()); ?>)</span>
                    </h2>

                    <?php if($pendingAccounts->count() === 0): ?>
                        <div class="bg-white rounded-2xl p-8 border border-gray-100 shadow-sm text-center">
                            <p class="text-gray-400">Tidak ada rekening bank yang menunggu verifikasi.</p>
                        </div>
                    <?php else: ?>
                        <div class="space-y-4">
                            <?php $__currentLoopData = $pendingAccounts; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $account): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                            <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                                <div class="flex items-start justify-between gap-4">
                                    <div class="flex-1">
                                        <div class="flex items-center gap-2 mb-2">
                                            <span class="px-2.5 py-0.5 bg-amber-100 text-amber-700 text-xs font-semibold rounded-full">Pending</span>
                                            <span class="text-sm text-gray-400"><?php echo e($account->created_at->format('d M Y H:i')); ?></span>
                                        </div>
                                        <h3 class="text-base font-semibold text-gray-900"><?php echo e($account->bank_name); ?></h3>
                                        <p class="text-sm text-gray-600 mt-1">
                                            <span class="font-medium">No. Rekening:</span> <?php echo e($account->account_number); ?>

                                        </p>
                                        <p class="text-sm text-gray-600">
                                            <span class="font-medium">A/N:</span> <?php echo e($account->account_holder); ?>

                                        </p>
                                        <?php if($account->umkm): ?>
                                        <p class="text-sm text-gray-500 mt-1">
                                            <span class="font-medium">UMKM:</span> <?php echo e($account->umkm->name); ?>

                                            <?php if($account->umkm->is_verified): ?>
                                                <span class="ml-1 text-xs text-emerald-600 bg-emerald-50 px-1.5 py-0.5 rounded">Verified</span>
                                            <?php else: ?>
                                                <span class="ml-1 text-xs text-amber-600 bg-amber-50 px-1.5 py-0.5 rounded">Unverified</span>
                                            <?php endif; ?>
                                        </p>
                                        <?php endif; ?>
                                    </div>
                                    <div class="flex items-center gap-2 flex-shrink-0">
                                        <form method="POST" action="<?php echo e(route('admin.bank-verification.approve', $account->id)); ?>">
                                            <?php echo csrf_field(); ?>
                                            <button type="submit" class="px-4 py-2 bg-emerald-500 hover:bg-emerald-600 text-white text-sm font-semibold rounded-xl transition">
                                                Setujui
                                            </button>
                                        </form>
                                        <button type="button" onclick="openRejectModal(<?php echo e($account->id); ?>, '<?php echo e($account->bank_name); ?>', '<?php echo e($account->account_holder); ?>')"
                                            class="px-4 py-2 bg-red-100 hover:bg-red-200 text-red-700 text-sm font-medium rounded-xl transition">
                                            Tolak
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
                        </div>

                        <div class="mt-4">
                            <?php echo e($pendingAccounts->links()); ?>

                        </div>
                    <?php endif; ?>
                </div>

                
                <div>
                    <h2 class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                        <span class="w-2.5 h-2.5 rounded-full bg-emerald-400 inline-block"></span>
                        Riwayat Verifikasi
                        <span class="text-sm font-normal text-gray-400">(<?php echo e($approvedAccounts->total()); ?>)</span>
                    </h2>

                    <?php if($approvedAccounts->count() === 0): ?>
                        <div class="bg-white rounded-2xl p-8 border border-gray-100 shadow-sm text-center">
                            <p class="text-gray-400">Belum ada riwayat verifikasi.</p>
                        </div>
                    <?php else: ?>
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
                                        <?php $__currentLoopData = $approvedAccounts; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $account): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                                        <tr class="hover:bg-gray-50/50">
                                            <td class="px-4 py-3 font-medium text-gray-900"><?php echo e($account->bank_name); ?></td>
                                            <td class="px-4 py-3 text-gray-700"><?php echo e($account->account_number); ?></td>
                                            <td class="px-4 py-3 text-gray-700"><?php echo e($account->account_holder); ?></td>
                                            <td class="px-4 py-3 text-gray-700"><?php echo e($account->umkm?->name ?? '-'); ?></td>
                                            <td class="px-4 py-3">
                                                <?php if($account->status === 'approved'): ?>
                                                    <span class="px-2 py-0.5 bg-emerald-100 text-emerald-700 text-xs font-semibold rounded-full">Disetujui</span>
                                                <?php elseif($account->status === 'rejected'): ?>
                                                    <span class="px-2 py-0.5 bg-red-100 text-red-700 text-xs font-semibold rounded-full" title="<?php echo e($account->rejection_reason); ?>">Ditolak</span>
                                                <?php endif; ?>
                                            </td>
                                            <td class="px-4 py-3 text-gray-500 text-xs">
                                                <?php echo e($account->verified_at ? $account->verified_at->format('d M Y H:i') : '-'); ?>

                                                <?php if($account->verifier): ?>
                                                    <br>oleh <?php echo e($account->verifier->name); ?>

                                                <?php endif; ?>
                                            </td>
                                        </tr>
                                        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <div class="mt-4">
                            <?php echo e($approvedAccounts->links()); ?>

                        </div>
                    <?php endif; ?>
                </div>

                <p class="mt-8 text-center text-xs text-gray-400">
                    &copy; <?php echo e(date('Y')); ?> LOKAL App — Panel Admin v2.0
                </p>

            </main>
        </div>

    </div>

    
    <div id="rejectModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 hidden">
        <div class="bg-white rounded-2xl p-6 w-full max-w-md mx-4 shadow-2xl">
            <h3 class="text-lg font-bold text-gray-900 mb-2">Tolak Rekening Bank</h3>
            <p class="text-sm text-gray-500 mb-4" id="rejectModalInfo">Masukkan alasan penolakan.</p>

            <form method="POST" action="" id="rejectForm">
                <?php echo csrf_field(); ?>
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
</html><?php /**PATH D:\laragon\www\LOKAL_APP\backend\resources\views/admin/bank-verification/index.blade.php ENDPATH**/ ?>