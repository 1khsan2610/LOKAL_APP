<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add proper columns to the existing settings table
        if (!Schema::hasColumn('settings', 'key')) {
            Schema::table('settings', function ($table) {
                $table->string('key')->unique()->after('id');
                $table->string('value')->after('key');
                $table->string('group')->default('general')->after('value');
                $table->string('label')->nullable()->after('group');
            });
        }

        // Insert default settings
        $defaults = [
            ['key' => 'commission_percent',       'value' => '5',  'group' => 'payment', 'label' => 'Komisi Platform (%)',       'created_at' => now(), 'updated_at' => now()],
            ['key' => 'cashback_percent',          'value' => '2',  'group' => 'payment', 'label' => 'Cashback Koin (%)',          'created_at' => now(), 'updated_at' => now()],
            ['key' => 'max_coin_discount_percent', 'value' => '20', 'group' => 'payment', 'label' => 'Maksimal Potongan Koin (%)', 'created_at' => now(), 'updated_at' => now()],
        ];

        foreach ($defaults as $default) {
            try {
                DB::table('settings')->updateOrInsert(
                    ['key' => $default['key']],
                    $default
                );
            } catch (\Exception $e) {
                // Skip if error
            }
        }
    }

    public function down(): void
    {
        // No clean down - data migration only
    }
};
