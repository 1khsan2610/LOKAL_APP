<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LOKAL App — Platform UMKM Indonesia</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .hero-gradient { background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 50%, #0f172a 100%); }
        .card-hover { transition: all 0.3s ease; }
        .card-hover:hover { transform: translateY(-6px); box-shadow: 0 20px 40px rgba(0,0,0,0.12); }
        .stat-card { transition: all 0.3s ease; }
        .stat-card:hover { transform: translateY(-4px); box-shadow: 0 12px 30px rgba(0,0,0,0.08); }
    </style>
</head>
<body class="bg-gray-50 text-gray-900 antialiased">

    
    <nav class="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-100">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex items-center justify-between h-16">
                <div class="flex items-center gap-2">
                    <span class="text-xl font-extrabold tracking-tight text-gray-900">Ekonomi</span>
                    <span class="text-xl font-extrabold tracking-tight text-blue-600">Lokal</span>
                    <span class="text-xs font-medium text-gray-400 bg-gray-100 px-2 py-0.5 rounded-full">v2.0</span>
                </div>
                <div class="flex items-center gap-4">
                    <a href="<?php echo e(route('login')); ?>" class="inline-flex items-center gap-2 px-5 py-2.5 bg-gray-900 text-white text-sm font-semibold rounded-xl hover:bg-gray-800 transition-all duration-200 shadow-sm">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"/></svg>
                        Admin Login
                    </a>
                </div>
            </div>
        </div>
    </nav>

    
    <section class="hero-gradient min-h-screen flex items-center pt-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-32">
            <div class="grid lg:grid-cols-2 gap-12 items-center">
                <div class="space-y-8">
                    <span class="inline-flex items-center gap-1.5 px-4 py-1.5 bg-white/10 text-white/90 text-xs font-semibold rounded-full border border-white/10">
                        <span class="w-2 h-2 bg-emerald-400 rounded-full animate-pulse"></span>
                        Platform UMKM Digital
                    </span>
                    <div>
                        <h1 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white leading-tight tracking-tight">
                            Bangun Bisnis
                            <span class="bg-gradient-to-r from-cyan-400 to-blue-500 bg-clip-text text-transparent">Lokal</span>
                            yang Kuat
                        </h1>
                    </div>
                    <p class="text-lg text-gray-300 leading-relaxed max-w-lg">
                        LOKAL adalah ekosistem digital yang memberdayakan UMKM Indonesia untuk go-digital, 
                        terhubung dengan konsumen, dan berkembang bersama.
                    </p>
                    <div class="flex flex-wrap gap-4">
                        <a href="<?php echo e(route('login')); ?>" class="inline-flex items-center gap-2 px-8 py-3.5 bg-white text-gray-900 font-bold rounded-xl hover:bg-gray-100 transition-all shadow-lg shadow-white/10">
                            Masuk ke Dashboard
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"/></svg>
                        </a>
                    </div>
                </div>
                <div class="hidden lg:flex justify-center">
                    <div class="relative">
                        <div class="w-96 h-96 bg-gradient-to-br from-cyan-400/20 to-blue-600/20 rounded-full blur-3xl absolute -top-20 -right-20"></div>
                        <div class="relative bg-white/5 backdrop-blur-sm border border-white/10 rounded-3xl p-12 shadow-2xl flex items-center justify-center">
                            <img src="<?php echo e(asset('images/logo.jpg')); ?>" alt="LOKAL Logo" class="h-48 w-auto max-w-full">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    
    <section id="tentang" class="py-20 lg:py-28 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid lg:grid-cols-2 gap-14 items-center">
                <div>
                    <span class="text-xs font-semibold text-blue-600 bg-blue-50 px-4 py-1.5 rounded-full">Tentang Kami</span>
                    <h2 class="text-3xl sm:text-4xl font-extrabold text-gray-900 mt-4 mb-6 leading-tight">
                        Menghubungkan Produk Lokal<br>dengan Masyarakat
                    </h2>
                    <p class="text-gray-600 leading-relaxed">
                        Kami percaya bahwa setiap pembelian produk lokal memberikan dampak nyata 
                        bagi pertumbuhan ekonomi daerah. Melalui platform ini, kami membantu pelaku 
                        usaha memasarkan produknya dengan lebih mudah dan menjangkau lebih banyak pelanggan.
                    </p>
                </div>
                <div class="bg-blue-50 rounded-3xl p-8 lg:p-10 border border-blue-100">
                    <div class="grid grid-cols-2 gap-5">
                        <div class="bg-white rounded-2xl p-5 text-center shadow-sm">
                            <div class="w-10 h-10 mx-auto rounded-xl bg-blue-100 flex items-center justify-center mb-3">
                                <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>
                            </div>
                            <div class="text-2xl font-extrabold text-gray-900"><?php echo e($stats['total_umkm'] ?? '500+'); ?></div>
                            <div class="text-xs text-gray-500 mt-1">UMKM Tergabung</div>
                        </div>
                        <div class="bg-white rounded-2xl p-5 text-center shadow-sm">
                            <div class="w-10 h-10 mx-auto rounded-xl bg-green-100 flex items-center justify-center mb-3">
                                <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"/></svg>
                            </div>
                            <div class="text-2xl font-extrabold text-gray-900">5.000+</div>
                            <div class="text-xs text-gray-500 mt-1">Produk Lokal</div>
                        </div>
                        <div class="bg-white rounded-2xl p-5 text-center shadow-sm">
                            <div class="w-10 h-10 mx-auto rounded-xl bg-purple-100 flex items-center justify-center mb-3">
                                <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 10h4.764a2 2 0 011.789 2.894l-3.5 7A2 2 0 0115.263 21h-4.017c-.163 0-.326-.02-.485-.06L7 20m7-10V5a2 2 0 00-2-2h-.095c-.5 0-.905.405-.905.905 0 .714-.211 1.412-.608 2.006L7 11v9m7-10h-2M7 20H5a2 2 0 01-2-2v-6a2 2 0 012-2h2.5"/></svg>
                            </div>
                            <div class="text-2xl font-extrabold text-gray-900">10.000+</div>
                            <div class="text-xs text-gray-500 mt-1">Pelanggan Puas</div>
                        </div>
                        <div class="bg-white rounded-2xl p-5 text-center shadow-sm">
                            <div class="w-10 h-10 mx-auto rounded-xl bg-orange-100 flex items-center justify-center mb-3">
                                <svg class="w-5 h-5 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                            </div>
                            <div class="text-2xl font-extrabold text-gray-900">50+</div>
                            <div class="text-xs text-gray-500 mt-1">Kota Terjangkau</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    
    <section id="keunggulan" class="py-20 lg:py-28 bg-gray-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center max-w-2xl mx-auto mb-14">
                <span class="text-xs font-semibold text-emerald-600 bg-emerald-50 px-4 py-1.5 rounded-full">Keunggulan</span>
                <h2 class="text-3xl sm:text-4xl font-extrabold text-gray-900 mt-4">Mengapa Memilih Kami?</h2>
            </div>

            <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
                
                <div class="stat-card bg-white rounded-2xl p-7 border border-gray-100 shadow-sm text-center">
                    <div class="w-14 h-14 mx-auto rounded-2xl bg-indigo-100 flex items-center justify-center mb-5">
                        <span class="text-2xl">🛍️</span>
                    </div>
                    <h3 class="font-bold text-gray-900 text-base mb-2">Produk Asli UMKM</h3>
                    <p class="text-gray-500 text-sm leading-relaxed">Semua produk berasal dari pelaku UMKM lokal dengan kualitas terjamin.</p>
                </div>

                
                <div class="stat-card bg-white rounded-2xl p-7 border border-gray-100 shadow-sm text-center">
                    <div class="w-14 h-14 mx-auto rounded-2xl bg-blue-100 flex items-center justify-center mb-5">
                        <span class="text-2xl">🚚</span>
                    </div>
                    <h3 class="font-bold text-gray-900 text-base mb-2">Pengiriman Cepat</h3>
                    <p class="text-gray-500 text-sm leading-relaxed">Pengiriman cepat dan aman ke seluruh kota di Indonesia.</p>
                </div>

                
                <div class="stat-card bg-white rounded-2xl p-7 border border-gray-100 shadow-sm text-center">
                    <div class="w-14 h-14 mx-auto rounded-2xl bg-emerald-100 flex items-center justify-center mb-5">
                        <span class="text-2xl">💳</span>
                    </div>
                    <h3 class="font-bold text-gray-900 text-base mb-2">Pembayaran Mudah</h3>
                    <p class="text-gray-500 text-sm leading-relaxed">Berbagai metode pembayaran yang aman, cepat, dan terpercaya.</p>
                </div>

                
                <div class="stat-card bg-white rounded-2xl p-7 border border-gray-100 shadow-sm text-center">
                    <div class="w-14 h-14 mx-auto rounded-2xl bg-amber-100 flex items-center justify-center mb-5">
                        <span class="text-2xl">⭐</span>
                    </div>
                    <h3 class="font-bold text-gray-900 text-base mb-2">Kualitas Terjamin</h3>
                    <p class="text-gray-500 text-sm leading-relaxed">Setiap produk telah melalui proses kurasi dan verifikasi ketat.</p>
                </div>
            </div>
        </div>
    </section>

    
    <section class="py-20 lg:py-28 hero-gradient">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center max-w-3xl mx-auto mb-14">
                <span class="inline-flex items-center gap-1.5 px-4 py-1.5 bg-white/10 text-white/90 text-xs font-semibold rounded-full border border-white/10">
                    Statistik
                </span>
                <h2 class="text-3xl sm:text-4xl font-extrabold text-white mt-4">Dampak Kami dalam Angka</h2>
            </div>

            <div class="grid grid-cols-2 lg:grid-cols-4 gap-6">
                <div class="bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl p-8 text-center">
                    <div class="text-4xl lg:text-5xl font-extrabold text-white mb-2">500+</div>
                    <div class="text-sm text-gray-300 font-medium">UMKM Bergabung</div>
                </div>
                <div class="bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl p-8 text-center">
                    <div class="text-4xl lg:text-5xl font-extrabold text-white mb-2">5.000+</div>
                    <div class="text-sm text-gray-300 font-medium">Produk Lokal</div>
                </div>
                <div class="bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl p-8 text-center">
                    <div class="text-4xl lg:text-5xl font-extrabold text-white mb-2">10.000+</div>
                    <div class="text-sm text-gray-300 font-medium">Pelanggan Puas</div>
                </div>
                <div class="bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl p-8 text-center">
                    <div class="text-4xl lg:text-5xl font-extrabold text-white mb-2">50+</div>
                    <div class="text-sm text-gray-300 font-medium">Kota Terjangkau</div>
                </div>
            </div>
        </div>
    </section>

    
    <section id="visi" class="py-20 lg:py-28 bg-white">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <span class="text-xs font-semibold text-purple-600 bg-purple-50 px-4 py-1.5 rounded-full">Visi</span>
            <h2 class="text-3xl sm:text-4xl font-extrabold text-gray-900 mt-4 mb-6">Mendorong Pertumbuhan Ekonomi Lokal</h2>
            <p class="text-gray-600 text-lg leading-relaxed max-w-3xl mx-auto">
                Menjadi platform digital yang memperkuat daya saing produk lokal serta 
                meningkatkan kesejahteraan pelaku usaha di seluruh Indonesia.
            </p>
        </div>
    </section>

    
    <section id="team" class="py-20 lg:py-28 bg-white border-t border-gray-100">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center max-w-2xl mx-auto mb-16">
                <span class="text-xs font-semibold text-blue-600 bg-blue-50 px-4 py-1.5 rounded-full">Tim Kami</span>
                <h2 class="text-3xl sm:text-4xl font-extrabold text-gray-900 mt-4">Di Balik LOKAL</h2>
                <p class="text-gray-500 mt-3 leading-relaxed">Para inovator yang bekerja keras membangun ekosistem digital untuk UMKM Indonesia.</p>
            </div>

            <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-6">
                <?php $__currentLoopData = $team; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $member): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                <div class="card-hover bg-white rounded-2xl p-6 text-center border border-gray-100 shadow-sm">
                    <?php $photoPath = public_path('images/team/' . $member['photo']); ?>
                    <?php if(file_exists($photoPath) && $member['photo']): ?>
                    <img src="<?php echo e(asset('images/team/' . $member['photo'])); ?>"
                         alt="<?php echo e($member['name']); ?>"
                         class="w-16 h-16 mx-auto rounded-full object-cover shadow-md mb-4 border-2 border-blue-100">
                    <?php else: ?>
                    <div class="w-16 h-16 mx-auto rounded-full bg-gradient-to-br from-blue-500 to-cyan-400 flex items-center justify-center text-white text-xl font-bold shadow-md mb-4">
                        <?php echo e(strtoupper(substr($member['name'], 0, 1))); ?>

                    </div>
                    <?php endif; ?>
                    <h3 class="font-semibold text-sm text-gray-900 leading-tight"><?php echo e($member['name']); ?></h3>
                    <p class="text-xs text-gray-400 mt-1"><?php echo e($member['role']); ?></p>
                </div>
                <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
            </div>
        </div>
    </section>

    
    <section class="py-20 lg:py-28 hero-gradient">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <h2 class="text-3xl sm:text-4xl font-extrabold text-white mb-4 leading-tight">
                Belanja Produk Lokal,<br>Berikan Dampak Nyata
            </h2>
            <p class="text-lg text-gray-300 leading-relaxed max-w-2xl mx-auto mb-8">
                Setiap transaksi yang Anda lakukan turut membantu perkembangan UMKM 
                dan perekonomian daerah.
            </p>
            <a href="<?php echo e(route('login')); ?>" class="inline-flex items-center gap-2 px-8 py-3.5 bg-white text-gray-900 font-bold rounded-xl hover:bg-gray-100 transition-all shadow-lg shadow-white/10">
                Mulai Sekarang
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"/></svg>
            </a>
        </div>
    </section>

    
    <footer class="bg-gray-900 text-gray-400 py-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-8 pb-8 border-b border-gray-800 mb-8">
                <div>
                    <div class="text-2xl font-extrabold text-white mb-2">LOKAL</div>
                    <p class="text-sm leading-relaxed">Platform digital untuk memberdayakan UMKM Indonesia.</p>
                </div>
                <div>
                    <h4 class="font-semibold text-white text-sm mb-3">Navigasi</h4>
                    <ul class="space-y-2 text-sm">
                        <li><a href="#" class="hover:text-white transition">Beranda</a></li>
                        <li><a href="#tentang" class="hover:text-white transition">Tentang</a></li>
                        <li><a href="#keunggulan" class="hover:text-white transition">Keunggulan</a></li>
                        <li><a href="#team" class="hover:text-white transition">Tim</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="font-semibold text-white text-sm mb-3">Layanan</h4>
                    <ul class="space-y-2 text-sm">
                        <li><a href="#" class="hover:text-white transition">Pusat Bantuan</a></li>
                        <li><a href="#" class="hover:text-white transition">Syarat & Ketentuan</a></li>
                        <li><a href="#" class="hover:text-white transition">Kebijakan Privasi</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="font-semibold text-white text-sm mb-3">Kontak</h4>
                    <ul class="space-y-2 text-sm">
                        <li>hello@lokal.app</li>
                        <li>@lokal_app</li>
                    </ul>
                </div>
            </div>
            <p class="text-center text-sm">© <?php echo e(date('Y')); ?> LOKAL App. All rights reserved.</p>
        </div>
    </footer>

</body>
</html><?php /**PATH D:\laragon\www\LOKAL_APP\backend\resources\views/landing.blade.php ENDPATH**/ ?>