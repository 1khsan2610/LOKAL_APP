

<?php $__env->startSection('content'); ?>
<div class="space-y-6">
    
    <div class="flex items-center justify-between">
        <div class="flex items-center gap-4">
            <a href="<?php echo e(route('admin.orders.index')); ?>" class="text-gray-400 hover:text-gray-600 transition">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            </a>
            <div>
                <h2 class="text-2xl font-bold text-gray-900">Detail Pesanan</h2>
                <p class="text-sm text-gray-500 font-mono"><?php echo e($order->order_number); ?></p>
            </div>
            <?php
                $statusBadges = [
                    'pending' => ['label' => 'Pending', 'color' => 'bg-gray-100 text-gray-700'],
                    'awaiting_payment' => ['label' => 'Menunggu Pembayaran', 'color' => 'bg-blue-100 text-blue-700'],
                    'processing' => ['label' => 'Sudah Dibayar ✅', 'color' => 'bg-emerald-100 text-emerald-700'],
                    'shipped' => ['label' => 'Dikirim 📦', 'color' => 'bg-cyan-100 text-cyan-700'],
                    'delivered' => ['label' => 'Selesai 🎉', 'color' => 'bg-green-100 text-green-700'],
                    'cancelled' => ['label' => 'Dibatalkan ❌', 'color' => 'bg-red-100 text-red-700'],
                ];
                $badge = $statusBadges[$order->status] ?? ['label' => ucfirst($order->status), 'color' => 'bg-gray-100'];
            ?>
            <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium <?php echo e($badge['color']); ?>">
                <?php echo e($badge['label']); ?>

            </span>
        </div>
        <div class="flex items-center gap-3">
            <a href="<?php echo e(route('admin.orders.edit', $order->id)); ?>"
               class="inline-flex items-center gap-2 px-4 py-2 bg-amber-50 text-amber-700 border border-amber-200 rounded-lg text-sm font-medium hover:bg-amber-100 transition">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                Edit
            </a>
            <form method="POST" action="<?php echo e(route('admin.orders.destroy', $order->id)); ?>"
                  onsubmit="return confirm('YAKIN ingin menghapus pesanan <?php echo e($order->order_number); ?>? Semua data terkait akan hilang!');">
                <?php echo csrf_field(); ?> <?php echo method_field('DELETE'); ?>
                <button type="submit"
                        class="inline-flex items-center gap-2 px-4 py-2 bg-red-50 text-red-700 border border-red-200 rounded-lg text-sm font-medium hover:bg-red-100 transition">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                    Hapus
                </button>
            </form>
        </div>
    </div>

    
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        <div class="bg-white rounded-xl border shadow-sm p-6">
            <h3 class="font-bold text-gray-900 mb-4">📋 Informasi Pesanan</h3>
            <div class="space-y-3 text-sm">
                <div class="flex justify-between">
                    <span class="text-gray-500">No. Pesanan</span>
                    <span class="font-mono font-medium"><?php echo e($order->order_number); ?></span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">Tanggal</span>
                    <span><?php echo e($order->created_at->format('d M Y H:i')); ?></span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">Status</span>
                    <span><?php echo e(ucfirst(str_replace('_', ' ', $order->status))); ?></span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">Subtotal</span>
                    <span class="font-mono">Rp <?php echo e(number_format($order->subtotal, 0, ',', '.')); ?></span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">Ongkos Kirim</span>
                    <span class="font-mono">Rp <?php echo e(number_format($order->shipping_fee, 0, ',', '.')); ?></span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">Diskon Koin</span>
                    <span class="font-mono <?php echo e($order->coin_discount > 0 ? 'text-amber-600' : ''); ?>">
                        <?php if($order->coin_discount > 0): ?> -Rp <?php echo e(number_format($order->coin_discount, 0, ',', '.')); ?>

                        <?php else: ?> —
                        <?php endif; ?>
                    </span>
                </div>
                <div class="flex justify-between border-t pt-3">
                    <span class="font-bold text-gray-900">Total Dibayar</span>
                    <span class="font-bold font-mono text-lg text-blue-600">Rp <?php echo e(number_format($order->total, 0, ',', '.')); ?></span>
                </div>
                <?php if($order->delivered_at): ?>
                <div class="flex justify-between">
                    <span class="text-gray-500">Diterima</span>
                    <span><?php echo e($order->delivered_at->format('d M Y H:i')); ?></span>
                </div>
                <?php endif; ?>
            </div>
        </div>

        
        <div class="bg-white rounded-xl border shadow-sm p-6">
            <h3 class="font-bold text-gray-900 mb-4">👤 Informasi Pembeli</h3>
            <div class="space-y-3 text-sm">
                <div class="flex justify-between">
                    <span class="text-gray-500">Nama</span>
                    <span class="font-medium"><?php echo e($order->user->name ?? '—'); ?></span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">Email</span>
                    <span><?php echo e($order->user->email ?? '—'); ?></span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">No. HP</span>
                    <span><?php echo e($order->user->phone ?? '—'); ?></span>
                </div>
                <?php if($order->address): ?>
                <div class="border-t pt-3">
                    <span class="text-gray-500 block mb-1">Alamat Pengiriman</span>
                    <p class="text-gray-900"><?php echo e($order->address->detail); ?>, <?php echo e($order->address->city); ?>, <?php echo e($order->address->province); ?></p>
                    <p class="text-xs text-gray-400 mt-1">Kode Pos: <?php echo e($order->address->zip); ?></p>
                </div>
                <?php endif; ?>
            </div>
        </div>

        
        <div class="bg-white rounded-xl border shadow-sm p-6">
            <h3 class="font-bold text-gray-900 mb-4">💳 Informasi Pembayaran</h3>
            <?php if($order->payment): ?>
            <div class="space-y-3 text-sm">
                <div class="flex justify-between">
                    <span class="text-gray-500">Status</span>
                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium
                        <?php switch($order->payment->status):
                            case ('paid'): ?> bg-emerald-100 text-emerald-700 <?php break; ?>
                            <?php case ('pending'): ?> bg-yellow-100 text-yellow-700 <?php break; ?>
                            <?php case ('challenge'): ?> bg-orange-100 text-orange-700 <?php break; ?>
                            <?php default: ?> bg-red-100 text-red-700
                        <?php endswitch; ?>">
                        <?php echo e(ucfirst($order->payment->status)); ?>

                    </span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">Metode</span>
                    <span><?php echo e($order->payment->payment_method ?? '—'); ?></span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">ID Transaksi</span>
                    <span class="font-mono text-xs"><?php echo e($order->payment->transaction_id ?? '—'); ?></span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">Dibayar Pada</span>
                    <span><?php echo e($order->payment->paid_at ? $order->payment->paid_at->format('d M Y H:i') : '—'); ?></span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">Kedaluwarsa</span>
                    <span><?php echo e($order->payment->expired_at ? $order->payment->expired_at->format('d M Y H:i') : '—'); ?></span>
                </div>
            </div>
            <?php else: ?>
            <p class="text-sm text-gray-400">Belum ada data pembayaran.</p>
            <?php endif; ?>
        </div>
    </div>

    
    <div class="bg-white rounded-xl border shadow-sm overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-100">
            <h3 class="font-bold text-gray-900">🛒 Item Pesanan</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="bg-gray-50 text-gray-500 text-left">
                        <th class="px-6 py-3 font-medium">Produk</th>
                        <th class="px-6 py-3 font-medium">UMKM</th>
                        <th class="px-6 py-3 font-medium">Qty</th>
                        <th class="px-6 py-3 font-medium">Harga</th>
                        <th class="px-6 py-3 font-medium">Subtotal</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    <?php $__currentLoopData = $order->items; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $item): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                    <tr>
                        <td class="px-6 py-4 font-medium text-gray-900"><?php echo e($item->product->name ?? 'Produk dihapus'); ?></td>
                        <td class="px-6 py-4"><?php echo e($item->product->umkm->name ?? '—'); ?></td>
                        <td class="px-6 py-4"><?php echo e($item->quantity); ?></td>
                        <td class="px-6 py-4 font-mono">Rp <?php echo e(number_format($item->price, 0, ',', '.')); ?></td>
                        <td class="px-6 py-4 font-mono font-medium">Rp <?php echo e(number_format($item->subtotal, 0, ',', '.')); ?></td>
                    </tr>
                    <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
                </tbody>
                <tfoot class="bg-gray-50">
                    <tr>
                        <td colspan="4" class="px-6 py-3 text-right font-medium text-gray-500">Subtotal</td>
                        <td class="px-6 py-3 font-mono font-bold">Rp <?php echo e(number_format($order->subtotal, 0, ',', '.')); ?></td>
                    </tr>
                    <tr>
                        <td colspan="4" class="px-6 py-3 text-right font-medium text-gray-500">Ongkos Kirim</td>
                        <td class="px-6 py-3 font-mono">Rp <?php echo e(number_format($order->shipping_fee, 0, ',', '.')); ?></td>
                    </tr>
                    <?php if($order->coin_discount > 0): ?>
                    <tr>
                        <td colspan="4" class="px-6 py-3 text-right font-medium text-amber-600">Diskon Koin</td>
                        <td class="px-6 py-3 font-mono text-amber-600">-Rp <?php echo e(number_format($order->coin_discount, 0, ',', '.')); ?></td>
                    </tr>
                    <?php endif; ?>
                    <tr>
                        <td colspan="4" class="px-6 py-3 text-right font-bold text-gray-900">Total</td>
                        <td class="px-6 py-3 font-mono font-bold text-lg text-blue-600">Rp <?php echo e(number_format($order->total, 0, ',', '.')); ?></td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>

    
    <?php if($walletHistories->count() > 0): ?>
    <div class="bg-white rounded-xl border shadow-sm overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-100">
            <h3 class="font-bold text-gray-900">💰 Riwayat Mutasi Dana (Wallet Histories)</h3>
            <p class="text-xs text-gray-400">Catatan pergerakan dana terkait pesanan ini.</p>
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
                        <th class="px-6 py-3 font-medium">Saldo Akhir</th>
                        <th class="px-6 py-3 font-medium">Deskripsi</th>
                        <th class="px-6 py-3 font-medium">Waktu</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    <?php $__currentLoopData = $walletHistories; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $h): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                    <?php
                        $icons = ['coin' => '🪙', 'cash' => '💰', 'commission' => '📊'];
                        $labels = ['coin' => 'Koin', 'cash' => 'Tunai', 'commission' => 'Komisi'];
                    ?>
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-3"><?php echo e($h->wallet->user->name ?? '—'); ?></td>
                        <td class="px-6 py-3">
                            <span class="text-xs font-medium <?php echo e($h->wallet->user->role === 'admin' ? 'text-purple-600' : ($h->wallet->user->role === 'umkm' ? 'text-emerald-600' : 'text-blue-600')); ?>">
                                <?php echo e(ucfirst($h->wallet->user->role ?? '')); ?>

                            </span>
                        </td>
                        <td class="px-6 py-3"><?php echo e($icons[$h->balance_type] ?? ''); ?> <?php echo e($labels[$h->balance_type] ?? $h->balance_type); ?></td>
                        <td class="px-6 py-3">
                            <?php if($h->type === 'credit'): ?>
                            <span class="text-emerald-600 font-medium">+ Kredit</span>
                            <?php else: ?>
                            <span class="text-red-600 font-medium">- Debit</span>
                            <?php endif; ?>
                        </td>
                        <td class="px-6 py-3 font-mono font-medium">Rp <?php echo e(number_format($h->amount, 0, ',', '.')); ?></td>
                        <td class="px-6 py-3 font-mono">Rp <?php echo e(number_format($h->balance_after, 0, ',', '.')); ?></td>
                        <td class="px-6 py-3 text-gray-600 max-w-xs truncate"><?php echo e($h->description); ?></td>
                        <td class="px-6 py-3 text-gray-500 whitespace-nowrap"><?php echo e($h->created_at->format('d/m H:i')); ?></td>
                    </tr>
                    <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
                </tbody>
            </table>
        </div>
    </div>
    <?php endif; ?>
</div>
<?php $__env->stopSection(); ?>
<?php echo $__env->make('layouts.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH C:\laragon\www\ekonomi_lokal\backend\resources\views/admin/orders/show.blade.php ENDPATH**/ ?>