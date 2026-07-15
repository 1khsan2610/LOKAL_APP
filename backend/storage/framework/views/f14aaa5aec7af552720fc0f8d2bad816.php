

<?php $__env->startSection('content'); ?>
<div class="p-6 max-w-2xl">
    <div class="flex items-center gap-4 mb-4">
        <a href="<?php echo e(route('admin.dashboard')); ?>" class="text-gray-400 hover:text-gray-600 transition">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
        </a>
        <h2 class="text-xl font-bold"><?php echo e($mode === 'edit' ? 'Edit' : 'Tambah'); ?> UMKM</h2>
    </div>

    <?php if($errors->any()): ?>
    <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded"><?php echo e($errors->first()); ?></div>
    <?php endif; ?>

    <form method="POST" action="<?php echo e($mode === 'edit' ? route('admin.umkm.update', $umkm->id) : route('admin.umkm.store')); ?>">
        <?php echo csrf_field(); ?>
        <?php if($mode === 'edit'): ?> <?php echo method_field('PUT'); ?> <?php endif; ?>

        <div class="mb-3">
            <label class="block text-sm font-medium mb-1">Nama</label>
            <input name="name" value="<?php echo e(old('name', $umkm->name)); ?>" class="w-full px-3 py-2 border rounded" />
        </div>

        <div class="grid grid-cols-2 gap-3">
            <div>
                <label class="block text-sm font-medium mb-1">Kota</label>
                <input name="city" value="<?php echo e(old('city', $umkm->city)); ?>" class="w-full px-3 py-2 border rounded" />
            </div>
            <div>
                <label class="block text-sm font-medium mb-1">Kategori</label>
                <input name="category" value="<?php echo e(old('category', $umkm->category)); ?>" class="w-full px-3 py-2 border rounded" />
            </div>
        </div>

        <div class="mb-3 mt-3">
            <label class="block text-sm font-medium mb-1">Deskripsi</label>
            <textarea name="description" class="w-full px-3 py-2 border rounded"><?php echo e(old('description', $umkm->description)); ?></textarea>
        </div>

        <div class="flex items-center gap-4 mt-3">
            <label><input type="checkbox" name="is_verified" value="1" <?php echo e(old('is_verified', $umkm->is_verified) ? 'checked' : ''); ?>> Verified</label>
            <label><input type="checkbox" name="is_active" value="1" <?php echo e(old('is_active', $umkm->is_active ?? 1) ? 'checked' : ''); ?>> Active</label>
        </div>

        <div class="mt-4">
            <button class="px-4 py-2 bg-blue-600 text-white rounded"><?php echo e($mode === 'edit' ? 'Simpan' : 'Buat'); ?></button>
            <a href="<?php echo e(route('admin.umkm.index')); ?>" class="ml-3 text-gray-600">Batal</a>
        </div>
    </form>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH D:\laragon\www\LOKAL_APP\backend\resources\views/admin/umkm/form.blade.php ENDPATH**/ ?>