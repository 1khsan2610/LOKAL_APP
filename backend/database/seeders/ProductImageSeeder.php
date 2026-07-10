<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Product;
use App\Models\ProductImage;

class ProductImageSeeder extends Seeder
{
    public function run(): void
    {
        $baseUrl = trim(config('app.url', env('APP_URL', 'http://localhost')), '/');
        $baseUrl = "$baseUrl/storage/products";

        $nameMap = [
            'Bakso Aci Spesial' => 'bakso-aci.jpg',
            'Seblak Hot Level 3' => 'seblak-hot.webp',
            'Capucino Lokal Premium' => 'capucino.png',
            'Coffee Latte Susu Segar' => 'cofee-latte.png',
            'Teh Herbal Jahe Merah'  => 'teh-herbal.jpeg',
            'Kemeja Batik Modern'    => 'kemeja.png',
            'Beras Pandan Wangi 5kg' => 'beras.jpeg',
            'Singkong Organik 1kg'   => 'singkong.jpeg',
        ];

        $products = Product::all();

        foreach ($products as $product) {
            $fileName = $nameMap[$product->name] ?? null;

            if (!$fileName) {
                $this->command->warn("Tidak ada gambar untuk produk #{$product->id} ({$product->name}), dilewati.");
                continue;
            }

            ProductImage::updateOrCreate(
                [
                    'product_id' => $product->id,
                    'url'        => "{$baseUrl}/{$fileName}",
                ],
                [
                    'is_primary' => true,
                ]
            );

            $this->command->info("✓ Gambar untuk produk #{$product->id} ({$product->name}) berhasil diset.");
        }
    }
}