

<?php $__env->startSection('content'); ?>
<div class="p-6 max-w-2xl">
    <div class="flex items-center gap-4 mb-4">
        <a href="<?php echo e(route('admin.dashboard')); ?>" class="text-gray-400 hover:text-gray-600 transition">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
        </a>
        <h2 class="text-xl font-bold"><?php echo e($mode === 'edit' ? 'Edit' : 'Tambah'); ?> Produk</h2>
    </div>

    <?php if($errors->any()): ?>
    <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded"><?php echo e($errors->first()); ?></div>
    <?php endif; ?>

    <form method="POST" action="<?php echo e($mode === 'edit' ? route('admin.products.update', $product->id) : route('admin.products.store')); ?>">
        <?php echo csrf_field(); ?>
        <?php if($mode === 'edit'): ?> <?php echo method_field('PUT'); ?> <?php endif; ?>

        <div class="mb-3">
            <label class="block text-sm font-medium mb-1">Nama</label>
            <input name="name" value="<?php echo e(old('name', $product->name)); ?>" class="w-full px-3 py-2 border rounded" required />
        </div>

        <div class="grid grid-cols-2 gap-3">
            <div>
                <label class="block text-sm font-medium mb-1">Harga</label>
                <input name="price" type="number" value="<?php echo e(old('price', $product->price)); ?>" class="w-full px-3 py-2 border rounded" required />
            </div>
            <div>
                <label class="block text-sm font-medium mb-1">Stok</label>
                <input name="stock" type="number" value="<?php echo e(old('stock', $product->stock ?? 0)); ?>" class="w-full px-3 py-2 border rounded" />
            </div>
        </div>

        <div class="mb-3 mt-3">
            <label class="block text-sm font-medium mb-1">UMKM (opsional)</label>
            <select name="umkm_id" class="w-full px-3 py-2 border rounded">
                <option value="">- Pilih UMKM -</option>
                <?php $__currentLoopData = $umkms; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $id => $name): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                    <option value="<?php echo e($id); ?>" <?php echo e(old('umkm_id', $product->umkm_id) == $id ? 'selected' : ''); ?>><?php echo e($name); ?></option>
                <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
            </select>
        </div>

        <div class="mb-3">
            <label class="block text-sm font-medium mb-1">Kategori</label>
            <input name="category" value="<?php echo e(old('category', $product->category)); ?>" class="w-full px-3 py-2 border rounded" />
        </div>

        <div class="mb-3">
            <label class="block text-sm font-medium mb-1">Deskripsi</label>
            <textarea name="description" class="w-full px-3 py-2 border rounded"><?php echo e(old('description', $product->description)); ?></textarea>
        </div>

        <div class="flex items-center gap-4 mt-3">
            <label><input type="checkbox" name="is_active" value="1" <?php echo e(old('is_active', $product->is_active ?? 1) ? 'checked' : ''); ?>> Aktif</label>
        </div>

        <div class="mt-4">
            <button class="px-4 py-2 bg-blue-600 text-white rounded"><?php echo e($mode === 'edit' ? 'Simpan' : 'Buat'); ?></button>
            <a href="<?php echo e(route('admin.products.index')); ?>" class="ml-3 text-gray-600">Batal</a>
        </div>
    </form>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH D:\laragon\www\LOKAL_APP\backend\resources\views/admin/products/form.blade.php ENDPATH**/ ?>