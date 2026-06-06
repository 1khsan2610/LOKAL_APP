<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('phone_number')->unique();
            $table->string('name');
            $table->enum('role', ['consumer', 'umkm', 'producer'])->default('consumer');
            $table->string('email')->nullable()->unique();
            $table->string('password');
            $table->text('address')->nullable();
            $table->point('location')->nullable(); // POINT type for geospatial queries
            $table->string('city')->nullable();
            $table->string('profile_image_url')->nullable();
            $table->boolean('is_verified')->default(false); // For UMKM/Producer verification
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
            
            // Indexes for performance
            $table->index('phone_number');
            $table->index('role');
            // Note: Spatial/location index requires NOT NULL, nullable location columns can't be indexed
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};

