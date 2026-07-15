<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add cash_balance (for UMKM withdrawable cash) and commission_balance (for admin commission pool)
        Schema::table('wallets', function (Blueprint $table) {
            $table->unsignedBigInteger('cash_balance')->default(0)->after('coin_balance');
            $table->unsignedBigInteger('commission_balance')->default(0)->after('cash_balance');
        });

        // Create wallet_histories table for transparent fund movement records
        Schema::create('wallet_histories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wallet_id')->constrained()->cascadeOnDelete();
            $table->enum('type', ['credit', 'debit']);
            $table->enum('balance_type', ['coin', 'cash', 'commission']);
            $table->unsignedBigInteger('amount');
            $table->unsignedBigInteger('balance_before');
            $table->unsignedBigInteger('balance_after');
            $table->string('description');
            $table->string('reference_type')->nullable()->comment('e.g. order, withdrawal, coin_usage, cashback');
            $table->unsignedBigInteger('reference_id')->nullable();
            $table->timestamps();

            $table->index(['wallet_id', 'created_at']);
            $table->index(['reference_type', 'reference_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallet_histories');

        Schema::table('wallets', function (Blueprint $table) {
            $table->dropColumn(['cash_balance', 'commission_balance']);
        });
    }
};