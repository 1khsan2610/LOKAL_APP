<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Services\LokalCoinService;
use Illuminate\Console\Command;

class ExpireLokalCoins extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'coins:expire';

    /**
     * The description of the console command.
     *
     * @var string
     */
    protected $description = 'Expire Lokal Coins that have reached 6-month expiration date';

    /**
     * Execute the console command.
     */
    public function handle(LokalCoinService $lokalCoinService)
    {
        $this->info('Starting Lokal Coin expiration job...');

        $users = User::where('role', '!=', 'admin')->get();
        $totalExpired = 0;
        $totalUsers = 0;

        foreach ($users as $user) {
            $expired = $lokalCoinService->expireCoins($user);
            if ($expired > 0) {
                $totalExpired += $expired;
                $totalUsers++;
                $this->line("User #{$user->id}: Expired {$expired} coins");
            }
        }

        $this->info("Lokal Coin expiration job completed!");
        $this->info("Total users affected: {$totalUsers}");
        $this->info("Total coins expired: {$totalExpired}");
    }
}
