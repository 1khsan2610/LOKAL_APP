

<?php $__env->startSection('content'); ?>
<div class="space-y-6">
    
    <div class="flex items-center gap-4">
        <a href="<?php echo e(route('admin.dashboard')); ?>" class="text-gray-400 hover:text-gray-600 transition">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
        </a>
        <div>
            <h2 class="text-2xl font-bold text-gray-900">Transaksi Order</h2>
            <p class="text-sm text-gray-500">Pantau semua pesanan, pembayaran, dan sirkulasi dana.</p>
        </div>
    </div>

    
    <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-8 gap-3">
        <?php
            $statCards = [
                ['label' => 'Total', 'key' => 'total_orders', 'color' => 'text-gray-900', 'bg' => 'bg-gray-100'],
                ['label' => 'Pending', 'key' => 'pending', 'color' => 'text-amber-600', 'bg' => 'bg-amber-50'],
                ['label' => 'Menunggu Bayar', 'key' => 'awaiting_payment', 'color' => 'text-blue-600', 'bg' => 'bg-blue-50'],
                ['label' => 'Sudah Dibayar', 'key' => 'processing', 'color' => 'text-emerald-600', 'bg' => 'bg-emerald-50'],
                ['label' => 'Dikirim', 'key' => 'shipped', 'color' => 'text-cyan-600', 'bg' => 'bg-cyan-50'],
                ['label' => 'Selesai', 'key' => 'delivered', 'color' => 'text-green-600', 'bg' => 'bg-green-50'],
                ['label' => 'Dibatalkan', 'key' => 'cancelled', 'color' => 'text-red-600', 'bg' => 'bg-red-50'],
            ];
        ?>
        <?php $__currentLoopData = $statCards; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $card): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
        <a href="<?php echo e(route('admin.orders.index', array_merge(request()->query(), ['status' => $card['key'] !== 'total_orders' ? str_replace('_', '.', $card['key']) : null]))); ?>"
           class="<?php echo e($card['bg']); ?> rounded-xl p-4 border shadow-sm hover:shadow-md transition">
            <p class="text-xs font-medium text-gray-500"><?php echo e($card['label']); ?></p>
            <p class="text-lg font-extrabold <?php echo e($card['color']); ?>"><?php echo e($stats[$card['key']] ?? 0); ?></p>
        </a>
        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
    </div>

    
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div class="bg-white rounded-xl p-4 border shadow-sm">
            <p class="text-xs text-gray-500">💰 Revenue (Selesai)</p>
            <p class="text-lg font-extrabold text-green-600">Rp <?php echo e(number_format($stats['total_revenue'], 0, ',', '.')); ?></p>
        </div>
        <div class="bg-white rounded-xl p-4 border shadow-sm">
            <p class="text-xs text-gray-500">📊 Total Komisi Terkumpul</p>
            <p class="text-lg font-extrabold text-blue-600">Rp <?php echo e(number_format($stats['total_commission'], 0, ',', '.')); ?></p>
        </div>
        <div class="bg-white rounded-xl p-4 border shadow-sm">
            <p class="text-xs text-gray-500">🪙 Total Cashback Koin</p>
            <p class="text-lg font-extrabold text-amber-600"><?php echo e(number_format($stats['total_cashback_coin'], 0, ',', '.')); ?> 🪙</p>
        </div>
    </div>

    
    <div class="bg-white rounded-xl border shadow-sm p-4">
        <form method="GET" class="flex flex-wrap gap-3 items-end">
            <div>
                <label class="text-xs text-gray-500 block mb-1">Cari</label>
                <input type="text" name="search" value="<?php echo e(request('search')); ?>" placeholder="No. pesanan, nama, email..."
                       class="px-3 py-2 border rounded-lg text-sm w-64">
            </div>
            <div>
                <label class="text-xs text-gray-500 block mb-1">Status Pesanan</label>
                <select name="status" class="px-3 py-2 border rounded-lg text-sm">
                    <option value="">Semua Status</option>
                    <option value="pending" <?php echo e(request('status') === 'pending' ? 'selected' : ''); ?>>Pending</option>
                    <option value="awaiting_payment" <?php echo e(request('status') === 'awaiting_payment' ? 'selected' : ''); ?>>Menunggu Pembayaran</option>
                    <option value="processing" <?php echo e(request('status') === 'processing' ? 'selected' : ''); ?>>Sudah Dibayar</option>
                    <option value="shipped" <?php echo e(request('status') === 'shipped' ? 'selected' : ''); ?>>Dikirim</option>
                    <option value="delivered" <?php echo e(request('status') === 'delivered' ? 'selected' : ''); ?>>Selesai</option>
                    <option value="cancelled" <?php echo e(request('status') === 'cancelled' ? 'selected' : ''); ?>>Dibatalkan</option>
                </select>
            </div>
            <div>
                <label class="text-xs text-gray-500 block mb-1">Status Pembayaran</label>
                <select name="payment_status" class="px-3 py-2 border rounded-lg text-sm">
                    <option value="">Semua</option>
                    <option value="pending" <?php echo e(request('payment_status') === 'pending' ? 'selected' : ''); ?>>Pending</option>
                    <option value="paid" <?php echo e(request('payment_status') === 'paid' ? 'selected' : ''); ?>>Paid / Lunas</option>
                    <option value="challenge" <?php echo e(request('payment_status') === 'challenge' ? 'selected' : ''); ?>>Challenge</option>
                    <option value="cancel" <?php echo e(request('payment_status') === 'cancel' ? 'selected' : ''); ?>>Cancel</option>
                    <option value="deny" <?php echo e(request('payment_status') === 'deny' ? 'selected' : ''); ?>>Deny</option>
                    <option value="expire" <?php echo e(request('payment_status') === 'expire' ? 'selected' : ''); ?>>Expire</option>
                </select>
            </div>
            <div>
                <label class="text-xs text-gray-500 block mb-1">Dari Tanggal</label>
                <input type="date" name="date_from" value="<?php echo e(request('date_from')); ?>" class="px-3 py-2 border rounded-lg text-sm">
            </div>
            <div>
                <label class="text-xs text-gray-500 block mb-1">Sampai Tanggal</label>
                <input type="date" name="date_to" value="<?php echo e(request('date_to')); ?>" class="px-3 py-2 border rounded-lg text-sm">
            </div>
            <div class="flex gap-2">
                <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm">Filter</button>
                <a href="<?php echo e(route('admin.orders.index')); ?>" class="px-4 py-2 bg-gray-100 text-gray-600 rounded-lg text-sm">Reset</a>
            </div>
        </form>
    </div>

    
    <div class="bg-white rounded-xl border shadow-sm overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
            <h3 class="font-semibold text-gray-900">Daftar Pesanan (<?php echo e($orders->total()); ?>)</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="bg-gray-50 text-gray-500 text-left">
                        <th class="px-6 py-3 font-medium">No. Pesanan</th>
                        <th class="px-6 py-3 font-medium">Pembeli</th>
                        <th class="px-6 py-3 font-medium">Status</th>
                        <th class="px-6 py-3 font-medium">Pembayaran</th>
                        <th class="px-6 py-3 font-medium">Subtotal</th>
                        <th class="px-6 py-3 font-medium">Diskon Koin</th>
                        <th class="px-6 py-3 font-medium">Total</th>
                        <th class="px-6 py-3 font-medium">Tanggal</th>
                        <th class="px-6 py-3 font-medium text-right">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    <?php $__empty_1 = true; $__currentLoopData = $orders; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $order): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
                    <?php
                        // Mapping status yang lebih jelas
                        $statusDisplay = [
                            'pending' => ['label' => 'Pending', 'color' => 'bg-gray-100 text-gray-700'],
                            'awaiting_payment' => ['label' => 'Menunggu Bayar', 'color' => 'bg-blue-100 text-blue-700'],
                            'processing' => ['label' => 'Sudah Dibayar ✅', 'color' => 'bg-emerald-100 text-emerald-700'],
                            'shipped' => ['label' => 'Dikirim 📦', 'color' => 'bg-cyan-100 text-cyan-700'],
                            'delivered' => ['label' => 'Selesai 🎉', 'color' => 'bg-green-100 text-green-700'],
                            'cancelled' => ['label' => 'Dibatalkan ❌', 'color' => 'bg-red-100 text-red-700'],
                        ];
                        $statusInfo = $statusDisplay[$order->status] ?? ['label' => ucfirst($order->status), 'color' => 'bg-gray-100'];

                        $paymentStatusColors = [
                            'pending' => 'bg-yellow-100 text-yellow-700',
                            'paid' => 'bg-emerald-100 text-emerald-700',
                            'challenge' => 'bg-orange-100 text-orange-700',
                            'cancel' => 'bg-red-100 text-red-700',
                            'deny' => 'bg-red-100 text-red-700',
                            'expire' => 'bg-gray-100 text-gray-700',
                        ];
                        $paymentStatusLabels = [
                            'pending' => 'Pending',
                            'paid' => 'Lunas ✅',
                            'challenge' => 'Challenge',
                            'cancel' => 'Dibatalkan',
                            'deny' => 'Ditolak',
                            'expire' => 'Kadaluwarsa',
                        ];
                    ?>
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4 font-mono font-medium text-blue-600"><?php echo e($order->order_number); ?></td>
                        <td class="px-6 py-4">
                            <div class="font-medium text-gray-900"><?php echo e($order->user->name ?? '—'); ?></div>
                            <div class="text-xs text-gray-400"><?php echo e($order->user->email ?? ''); ?></div>
                        </td>
                        <td class="px-6 py-4">
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium <?php echo e($statusInfo['color']); ?>">
                                <?php echo e($statusInfo['label']); ?>

                            </span>
                        </td>
                        <td class="px-6 py-4">
                            <?php if($order->payment): ?>
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium <?php echo e($paymentStatusColors[$order->payment->status] ?? 'bg-gray-100'); ?>">
                                <?php echo e($paymentStatusLabels[$order->payment->status] ?? ucfirst($order->payment->status)); ?>

                            </span>
                            <div class="text-xs text-gray-400 mt-0.5"><?php echo e($order->payment->payment_method ?? ''); ?></div>
                            <?php else: ?>
                            <span class="text-xs text-gray-400">—</span>
                            <?php endif; ?>
                        </td>
                        <td class="px-6 py-4 font-mono">Rp <?php echo e(number_format($order->subtotal, 0, ',', '.')); ?></td>
                        <td class="px-6 py-4 font-mono <?php echo e($order->coin_discount > 0 ? 'text-amber-600' : 'text-gray-400'); ?>">
                            <?php if($order->coin_discount > 0): ?>
                            -Rp <?php echo e(number_format($order->coin_discount, 0, ',', '.')); ?>

                            <?php else: ?>
                            —
                            <?php endif; ?>
                        </td>
                        <td class="px-6 py-4 font-mono font-bold">Rp <?php echo e(number_format($order->total, 0, ',', '.')); ?></td>
                        <td class="px-6 py-4 text-gray-500 whitespace-nowrap"><?php echo e($order->created_at->format('d/m/y H:i')); ?></td>
                        <td class="px-6 py-4 text-right">
                            <div class="flex items-center justify-end gap-2">
                                <a href="<?php echo e(route('admin.orders.show', $order->id)); ?>"
                                   class="inline-flex items-center gap-1 text-blue-600 hover:text-blue-800 text-sm font-medium"
                                   title="Detail">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                                </a>
                                <a href="<?php echo e(route('admin.orders.edit', $order->id)); ?>"
                                   class="inline-flex items-center gap-1 text-amber-600 hover:text-amber-800 text-sm font-medium"
                                   title="Edit">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                                </a>
                                <form method="POST" action="<?php echo e(route('admin.orders.destroy', $order->id)); ?>"
                                      onsubmit="return confirm('Yakin ingin menghapus pesanan <?php echo e($order->order_number); ?>?');"
                                      class="inline">
                                    <?php echo csrf_field(); ?>
                                    <?php echo method_field('DELETE'); ?>
                                    <button type="submit"
                                            class="inline-flex items-center gap-1 text-red-600 hover:text-red-800 text-sm font-medium"
                                            title="Hapus">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
                    <tr><td colspan="9" class="px-6 py-8 text-center text-gray-400">Belum ada pesanan.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        <?php if($orders->hasPages()): ?>
        <div class="px-6 py-4 border-t">
            <?php echo e($orders->links()); ?>

        </div>
        <?php endif; ?>
    </div>
</div>
<?php $__env->stopSection(); ?>
<?php echo $__env->make('layouts.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH D:\laragon\www\LOKAL_APP\backend\resources\views/admin/orders/index.blade.php ENDPATH**/ ?>