<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Enhanced audit_logs table for immutable financial transaction logging (NF-SAFE-02)
     */
    public function up(): void
    {
        // Add columns to audit_logs table if they don't exist
        if (!Schema::hasColumn('audit_logs', 'transaction_type')) {
            Schema::table('audit_logs', function (Blueprint $table) {
                $table->string('transaction_type')->nullable()->comment('Type: wallet_topup, payment, transfer, refund, etc');
                $table->decimal('amount', 15, 2)->nullable()->comment('Transaction amount in Rupiah');
                $table->string('reference_id')->nullable()->unique()->comment('Unique transaction reference');
                $table->json('metadata')->nullable()->comment('Additional metadata - user_agent, ip_address, location, etc');
                $table->string('status')->default('recorded')->comment('recorded, completed, failed, cancelled');
                
                // Ensure UPDATED_AT is null (immutable logs)
                $table->dropTimestamps();
                $table->timestamp('created_at')->useCurrent();
                
                // Indexes for financial queries
                $table->index('transaction_type');
                $table->index('reference_id');
                $table->index(['user_id', 'transaction_type']);
                $table->index(['created_at']);
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('audit_logs', function (Blueprint $table) {
            $table->dropIndexIfExists(['transaction_type']);
            $table->dropIndexIfExists(['reference_id']);
            $table->dropIndexIfExists(['user_id', 'transaction_type']);
            $table->dropIndexIfExists(['created_at']);
            
            if (Schema::hasColumn('audit_logs', 'transaction_type')) {
                $table->dropColumn([
                    'transaction_type',
                    'amount',
                    'reference_id',
                    'metadata',
                    'status'
                ]);
            }
        });
    }
};
