<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // UMKM Stores
        Schema::create('umkms', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('slug')->unique()->nullable();
            $table->string('category');
            $table->text('description')->nullable();
            $table->string('logo')->nullable();
            $table->string('banner')->nullable();
            $table->string('phone')->nullable();
            $table->string('address')->nullable();
            $table->string('city')->nullable();
            $table->string('province')->nullable();
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->float('avg_rating')->default(0);
            $table->integer('total_sold')->default(0);
            $table->boolean('is_verified')->default(false);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // Products
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('umkm_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description');
            $table->unsignedBigInteger('price');
            $table->integer('stock')->default(0);
            $table->string('category');
            $table->float('weight')->default(0);
            $table->integer('sold_count')->default(0);
            $table->float('avg_rating')->default(0);
            $table->boolean('is_active')->default(true);
            $table->unsignedBigInteger('flash_sale_price')->nullable();
            $table->integer('flash_sale_discount')->nullable();
            $table->timestamp('flash_sale_ends_at')->nullable();
            $table->timestamps();

            $table->index('category');
            $table->index('is_active');
        });

        // Product Images
        Schema::create('product_images', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->string('url');
            $table->boolean('is_primary')->default(false);
            $table->timestamps();
        });

        // Product Variants
        Schema::create('product_variants', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('value');
            $table->integer('price_modifier')->default(0);
            $table->integer('stock')->default(0);
            $table->timestamps();
        });

        // Addresses
        Schema::create('addresses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('label')->default('Rumah');
            $table->string('recipient_name');
            $table->string('phone');
            $table->text('detail');
            $table->string('city');
            $table->string('province');
            $table->string('zip', 10);
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->boolean('is_default')->default(false);
            $table->timestamps();
        });

        // Cart
        Schema::create('carts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->foreignId('variant_id')->nullable()->constrained('product_variants')->nullOnDelete();
            $table->integer('quantity')->default(1);
            $table->timestamps();

            $table->unique(['user_id', 'product_id', 'variant_id']);
        });

        // Orders
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_number')->unique();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('address_id')->constrained();
            $table->enum('status', ['pending','awaiting_payment','processing','shipped','delivered','cancelled'])->default('pending');
            $table->unsignedBigInteger('subtotal');
            $table->unsignedBigInteger('shipping_fee')->default(0);
            $table->string('shipping_method');
            $table->string('tracking_number')->nullable();
            $table->unsignedBigInteger('coin_discount')->default(0);
            $table->unsignedBigInteger('total');
            $table->text('notes')->nullable();
            $table->text('seller_notes')->nullable();
            $table->timestamp('delivered_at')->nullable();
            $table->timestamps();

            $table->index('status');
            $table->index('user_id');
        });

        // Order Items
        Schema::create('order_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained();
            $table->foreignId('variant_id')->nullable()->constrained('product_variants');
            $table->integer('quantity');
            $table->unsignedBigInteger('price');
            $table->unsignedBigInteger('subtotal');
            $table->timestamps();
        });

        // Payments
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->cascadeOnDelete();
            $table->string('snap_token')->nullable();
            $table->string('snap_url')->nullable();
            $table->string('transaction_id')->nullable();
            $table->string('payment_method')->nullable();
            $table->enum('status', ['pending','paid','challenge','cancel','deny','expire'])->default('pending');
            $table->unsignedBigInteger('amount')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamp('expired_at')->nullable();
            $table->json('raw_response')->nullable();
            $table->timestamps();
        });

        // Wallets & Coin
        Schema::create('wallets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->unsignedBigInteger('coin_balance')->default(0);
            $table->timestamps();
        });

        Schema::create('coin_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->enum('type', ['credit', 'debit']);
            $table->unsignedBigInteger('amount');
            $table->string('description');
            $table->unsignedBigInteger('balance_after');
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->index('expires_at');
        });

        // Reviews
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->foreignId('order_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('rating');
            $table->text('comment')->nullable();
            $table->json('images')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'product_id', 'order_id']);
        });

        // Notifications
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('body');
            $table->string('type')->default('general');
            $table->json('data')->nullable();
            $table->boolean('is_read')->default(false);
            $table->timestamps();

            $table->index(['user_id', 'is_read']);
        });

        // Device Tokens (FCM/APNs)
        Schema::create('device_tokens', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('token')->unique();
            $table->enum('platform', ['android', 'ios']);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('device_tokens');
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('reviews');
        Schema::dropIfExists('coin_transactions');
        Schema::dropIfExists('wallets');
        Schema::dropIfExists('payments');
        Schema::dropIfExists('order_items');
        Schema::dropIfExists('orders');
        Schema::dropIfExists('carts');
        Schema::dropIfExists('addresses');
        Schema::dropIfExists('product_variants');
        Schema::dropIfExists('product_images');
        Schema::dropIfExists('products');
        Schema::dropIfExists('umkms');
    }
};
