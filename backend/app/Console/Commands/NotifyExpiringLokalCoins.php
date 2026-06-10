<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Services\LokalCoinService;
use Illuminate\Console\Command;

class NotifyExpiringLokalCoins extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'coins:notify-expiring';

    /**
     * The description of the console command.
     *
     * @var string
     */
    protected $description = 'Notify users about Lokal Coins expiring in 30 days';

    /**
     * Execute the console command.
     */
    public function handle(LokalCoinService $lokalCoinService)
    {
        $this->info('Starting Lokal Coin expiration notification job...');

        $users = User::where('role', '!=', 'admin')->get();
        $notifiedUsers = 0;
        $totalExpiringCoins = 0;

        foreach ($users as $user) {
            $expiring = $lokalCoinService->notifyExpiringCoins($user);
            if ($expiring > 0) {
                $notifiedUsers++;
                $totalExpiringCoins += $expiring;
                $this->line("User #{$user->id}: {$expiring} coins expiring in 30 days");
            }
        }

        $this->info("Lokal Coin expiration notification job completed!");
        $this->info("Users notified: {$notifiedUsers}");
        $this->info("Total coins expiring: {$totalExpiringCoins}");
    }
}
