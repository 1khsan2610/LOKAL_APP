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
        Schema::create('otp_codes', function (Blueprint $table) {
            $table->id();
            $table->string('phone_number')->unique();
            $table->string('code', 6);
            $table->integer('attempts')->default(0);
            $table->boolean('is_verified')->default(false);
            $table->dateTime('expires_at');
            $table->dateTime('blocked_until')->nullable();
            $table->timestamps();
            
            // Index untuk query cepat
            $table->index('phone_number');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('otp_codes');
    }
};
