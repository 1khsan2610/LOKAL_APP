

<?php $__env->startSection('content'); ?>
<div class="max-w-3xl mx-auto">
    <div class="space-y-6">
        
        <div class="flex items-center gap-4">
            <a href="<?php echo e(route('admin.orders.index')); ?>" class="text-gray-400 hover:text-gray-600 transition">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            </a>
            <div>
                <h2 class="text-2xl font-bold text-gray-900">Edit Pesanan</h2>
                <p class="text-sm text-gray-500 font-mono"><?php echo e($order->order_number); ?></p>
            </div>
        </div>

        
        <?php if(session('success')): ?>
        <div class="p-4 bg-emerald-50 border border-emerald-200 rounded-xl">
            <p class="text-sm font-medium text-emerald-700"><?php echo e(session('success')); ?></p>
        </div>
        <?php endif; ?>

        
        <?php if($errors->any()): ?>
        <div class="p-4 bg-red-50 border border-red-200 rounded-xl">
            <ul class="text-sm text-red-600">
                <?php $__currentLoopData = $errors->all(); $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $error): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                <li><?php echo e($error); ?></li>
                <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
            </ul>
        </div>
        <?php endif; ?>

        
        <div class="bg-white rounded-xl border shadow-sm p-6">
            <form method="POST" action="<?php echo e(route('admin.orders.update', $order->id)); ?>">
                <?php echo csrf_field(); ?>
                <?php echo method_field('PUT'); ?>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Status Pesanan</label>
                        <select name="status" class="w-full px-3 py-2 border rounded-lg text-sm">
                            <?php $__currentLoopData = $statuses; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $s): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                            <option value="<?php echo e($s); ?>" <?php echo e($order->status === $s ? 'selected' : ''); ?>>
                                <?php
                                    $labels = [
                                        'pending' => 'Pending',
                                        'awaiting_payment' => 'Menunggu Pembayaran',
                                        'processing' => 'Sudah Dibayar ✅',
                                        'shipped' => 'Dikirim 📦',
                                        'delivered' => 'Selesai 🎉',
                                        'cancelled' => 'Dibatalkan ❌',
                                    ];
                                ?>
                                <?php echo e($labels[$s] ?? ucfirst(str_replace('_', ' ', $s))); ?>

                            </option>
                            <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
                        </select>
                    </div>

                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Total (Rp)</label>
                        <input type="number" name="total" value="<?php echo e(old('total', $order->total)); ?>"
                               class="w-full px-3 py-2 border rounded-lg text-sm">
                    </div>

                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">No. Resi / Tracking</label>
                        <input type="text" name="tracking_number" value="<?php echo e(old('tracking_number', $order->tracking_number)); ?>"
                               class="w-full px-3 py-2 border rounded-lg text-sm" placeholder="Opsional">
                    </div>
                </div>

                
                <div class="mb-6">
                    <label class="block text-sm font-medium text-gray-700 mb-1">Catatan Pembeli</label>
                    <textarea name="notes" rows="3" class="w-full px-3 py-2 border rounded-lg text-sm" placeholder="Catatan dari pembeli..."><?php echo e(old('notes', $order->notes)); ?></textarea>
                </div>

                <div class="mb-6">
                    <label class="block text-sm font-medium text-gray-700 mb-1">Catatan Penjual</label>
                    <textarea name="seller_notes" rows="3" class="w-full px-3 py-2 border rounded-lg text-sm" placeholder="Catatan internal..."><?php echo e(old('seller_notes', $order->seller_notes)); ?></textarea>
                </div>

                
                <div class="bg-gray-50 rounded-lg p-4 mb-6">
                    <h4 class="text-sm font-semibold text-gray-700 mb-2">📋 Informasi Ringkas</h4>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-3 text-sm">
                        <div>
                            <span class="text-gray-500">Pembeli</span>
                            <p class="font-medium"><?php echo e($order->user->name ?? '—'); ?></p>
                        </div>
                        <div>
                            <span class="text-gray-500">Subtotal</span>
                            <p class="font-mono">Rp <?php echo e(number_format($order->subtotal, 0, ',', '.')); ?></p>
                        </div>
                        <div>
                            <span class="text-gray-500">Ongkir</span>
                            <p class="font-mono">Rp <?php echo e(number_format($order->shipping_fee, 0, ',', '.')); ?></p>
                        </div>
                        <div>
                            <span class="text-gray-500">Diskon Koin</span>
                            <p class="font-mono <?php echo e($order->coin_discount > 0 ? 'text-amber-600' : ''); ?>">
                                <?php echo e($order->coin_discount > 0 ? '-Rp '.number_format($order->coin_discount, 0, ',', '.') : '—'); ?>

                            </p>
                        </div>
                    </div>
                </div>

                
                <div class="flex items-center gap-4">
                    <button type="submit" class="px-6 py-2.5 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition">
                        Simpan Perubahan
                    </button>
                    <a href="<?php echo e(route('admin.orders.show', $order->id)); ?>" class="px-6 py-2.5 bg-gray-100 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-200 transition">
                        Batal
                    </a>
                </div>
            </form>
        </div>

        
        <div class="bg-white rounded-xl border border-red-200 shadow-sm p-6">
            <h3 class="font-bold text-red-600 mb-2">⚠️ Zona Berbahaya</h3>
            <p class="text-sm text-gray-500 mb-4">Menghapus pesanan akan menghapus semua data terkait (item, pembayaran, mutasi dana). Tindakan ini tidak bisa dibatalkan.</p>
            <form method="POST" action="<?php echo e(route('admin.orders.destroy', $order->id)); ?>"
                  onsubmit="return confirm('YAKIN ingin menghapus pesanan <?php echo e($order->order_number); ?>? Semua data terkait akan hilang!');">
                <?php echo csrf_field(); ?>
                <?php echo method_field('DELETE'); ?>
                <button type="submit" class="px-6 py-2.5 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700 transition">
                    Hapus Pesanan Permanen
                </button>
            </form>
        </div>
    </div>
</div>
<?php $__env->stopSection(); ?>
<?php echo $__env->make('layouts.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH D:\laragon\www\ekonomi_lokal\backend\resources\views/admin/orders/edit.blade.php ENDPATH**/ ?>