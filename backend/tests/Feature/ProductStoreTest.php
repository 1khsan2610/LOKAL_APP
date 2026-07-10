<?php

namespace Tests\Feature;

use App\Models\Umkm;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProductStoreTest extends TestCase
{
    use RefreshDatabase;

    public function test_umkm_can_create_product_with_valid_payload(): void
    {
        $user = User::create([
            'name' => 'UMKM Test',
            'email' => 'umkm-create@test.com',
            'password' => 'password123',
            'phone' => '081234567890',
            'role' => 'umkm',
            'is_active' => true,
        ]);

        Umkm::create([
            'user_id' => $user->id,
            'name' => 'Toko Test',
            'slug' => 'toko-test',
            'category' => 'makanan',
            'is_verified' => true,
            'is_active' => true,
        ]);

        $response = $this->actingAs($user, 'api')->postJson('/api/umkm/products', [
            'name' => 'Keripik Singkong',
            'description' => 'Keripik renyah',
            'price' => 15000,
            'stock' => 20,
            'category' => 'makanan',
            'weight' => 250,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.name', 'Keripik Singkong');
    }
}
