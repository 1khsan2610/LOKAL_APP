<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Umkm;      // <--- Penting ditambahkan
use App\Models\Product;   // <--- Penting ditambahkan
use App\Models\Wallet;    // <--- Penting ditambahkan
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $defaultPasswordHash = Hash::make('password123');

        // ─── Admin ───────────────────────────────────────────────
        $admin = User::updateOrCreate(
            ['email' => 'admin@ekonomilokal.id'],
            [
                'name'              => 'Admin EkonomiLokal',
                'password'          => $defaultPasswordHash,
                'phone'             => '081200000001',
                'role'              => 'admin',
                'is_active'         => true,
                'email_verified_at' => now(),
            ]
        );
        Wallet::updateOrCreate(['user_id' => $admin->id], ['coin_balance' => 0]);

        // ─── UMKM Users ──────────────────────────────────────────
        $umkmData = [
            ['name' => 'Bu Sari', 'email' => 'busari@test.com', 'store' => 'Warung Bu Sari', 'cat' => 'Makanan', 'city' => 'Bandung', 'lat' => -6.9175, 'lng' => 107.6191],
            ['name' => 'Pak Kopi', 'email' => 'kopi@test.com', 'store' => 'Kopi Nusantara', 'cat' => 'Minuman', 'city' => 'Bogor', 'lat' => -6.5971, 'lng' => 106.8060],
            ['name' => 'Pak Batik', 'email' => 'batik@test.com', 'store' => 'Batik Garuda', 'cat' => 'Fashion', 'city' => 'Pekalongan', 'lat' => -6.8884, 'lng' => 109.6753],
            ['name' => 'Pak Tani', 'email' => 'tani@test.com', 'store' => 'Tani Makmur', 'cat' => 'Bahan Pokok', 'city' => 'Cianjur', 'lat' => -6.8231, 'lng' => 107.1440],
        ];

        foreach ($umkmData as $ud) {
            $user = User::updateOrCreate(
                ['email' => $ud['email']],
                [
                    'name'              => $ud['name'],
                    'password'          => $defaultPasswordHash,
                    'phone'             => '08120000000' . rand(1, 9),
                    'role'              => 'umkm',
                    'is_active'         => true,
                    'email_verified_at' => now(),
                ]
            );
            Wallet::updateOrCreate(['user_id' => $user->id], ['coin_balance' => rand(100, 500)]);
            Umkm::updateOrCreate(
                ['user_id' => $user->id],
                [
                    'name'        => $ud['store'],
                    'slug'        => Str::slug($ud['store']),
                    'category'    => $ud['cat'],
                    'description' => "UMKM lokal berkualitas dari " . $ud['city'],
                    'city'        => $ud['city'],
                    'province'    => 'Jawa Barat',
                    'latitude'    => $ud['lat'],
                    'longitude'   => $ud['lng'],
                    'avg_rating'  => round(rand(43, 50) / 10, 1),
                    'is_verified' => true,
                    'is_active'   => true,
                ]
            );
        }

        // ─── Konsumen ────────────────────────────────────────────
        $konsumen = User::updateOrCreate(
            ['email' => 'budi@test.com'],
            [
                'name'              => 'Budi Santoso',
                'password'          => $defaultPasswordHash,
                'phone'             => '081234567890',
                'role'              => 'konsumen',
                'is_active'         => true,
                'email_verified_at' => now(),
            ]
        );
        Wallet::updateOrCreate(['user_id' => $konsumen->id], ['coin_balance' => 1250]);

        // ─── Sample Products ─────────────────────────────────────
        $umkmId = Umkm::first()->id;
        $productData = [
            ['name' => 'Bakso Aci Spesial', 'price' => 15000, 'stock' => 45, 'category' => 'makanan'],
            ['name' => 'Seblak Hot Level 3', 'price' => 18000, 'stock' => 30, 'category' => 'makanan'],
            ['name' => 'Capucino Lokal Premium', 'price' => 22000, 'stock' => 100, 'category' => 'minuman'],
            ['name' => 'Coffee Latte Susu Segar', 'price' => 19000, 'stock' => 80, 'category' => 'minuman'],
            ['name' => 'Teh Herbal Jahe Merah', 'price' => 12000, 'stock' => 200, 'category' => 'minuman'],
            ['name' => 'Kemeja Batik Modern', 'price' => 145000, 'stock' => 25, 'category' => 'fashion'],
            ['name' => 'Beras Pandan Wangi 5kg', 'price' => 65000, 'stock' => 150, 'category' => 'bahan_pokok'],
            ['name' => 'Singkong Organik 1kg', 'price' => 8000, 'stock' => 200, 'category' => 'bahan_pokok'],
        ];

        foreach ($productData as $pd) {
            Product::create([
                'umkm_id'     => $umkmId,
                'name'        => $pd['name'],
                'slug'        => Str::slug($pd['name']) . '-' . Str::random(6),
                'description' => "Produk UMKM lokal berkualitas: " . $pd['name'],
                'price'       => $pd['price'],
                'stock'       => $pd['stock'],
                'category'    => $pd['category'],
                'weight'      => rand(100, 1000),
                'sold_count'  => rand(50, 500),
                'avg_rating'  => round(rand(43, 50) / 10, 1),
                'is_active'   => true,
            ]);
        }

        $this->command->info('✅ Database seeded successfully!');
    }
}