<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\Umkm;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ProductImageUploadTest extends TestCase
{
    use RefreshDatabase;

    public function test_umkm_can_upload_product_images_using_images_array_key(): void
    {
        Storage::fake('public');

        $user = User::create([
            'name' => 'UMKM Test',
            'email' => 'umkm@test.com',
            'password' => 'password123',
            'phone' => '081234567890',
            'role' => 'umkm',
            'is_active' => true,
        ]);

        $umkm = Umkm::create([
            'user_id' => $user->id,
            'name' => 'Toko Test',
            'slug' => 'toko-test',
            'category' => 'makanan',
            'is_verified' => true,
            'is_active' => true,
        ]);

        $product = Product::create([
            'umkm_id' => $umkm->id,
            'name' => 'Produk Test',
            'slug' => 'produk-test',
            'description' => 'Deskripsi produk',
            'category' => 'makanan',
            'price' => 10000,
            'stock' => 10,
            'weight' => 250,
            'is_active' => true,
        ]);

        $response = $this->actingAs($user, 'api')->postJson("/api/umkm/products/{$product->id}/images", [
            'images' => [
                UploadedFile::fake()->image('product-1.jpg', 600, 600),
            ],
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true);
    }
}
