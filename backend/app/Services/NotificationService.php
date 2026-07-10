<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\DeviceToken;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    /**
     * Send notification to a user (save to DB + push FCM)
     */
    public function sendToUser(int $userId, array $payload): void
    {
        // Save to database
        Notification::create([
            'user_id' => $userId,
            'title'   => $payload['title'],
            'body'    => $payload['body'],
            'type'    => $payload['type'] ?? 'general',
            'data'    => $payload['data'] ?? null,
            'is_read' => false,
        ]);

        // Send FCM push notification
        $this->sendPush($userId, $payload);
    }

    /**
     * Broadcast to all users (admin)
     */
    public function broadcast(array $payload): void
    {
        $tokens = DeviceToken::pluck('token')->chunk(500);

        foreach ($tokens as $chunk) {
            $this->sendFCMMulticast($chunk->toArray(), $payload);
        }
    }

    /**
     * Send push to specific user's devices
     */
    private function sendPush(int $userId, array $payload): void
    {
        $tokens = DeviceToken::where('user_id', $userId)->pluck('token')->toArray();

        if (empty($tokens)) return;

        $this->sendFCMMulticast($tokens, $payload);
    }

    /**
     * FCM Multicast send
     */
    private function sendFCMMulticast(array $tokens, array $payload): void
    {
        $serverKey = config('services.fcm.server_key');
        if (!$serverKey) return;

        try {
            $response = Http::withHeaders([
                'Authorization' => "key={$serverKey}",
                'Content-Type'  => 'application/json',
            ])->post('https://fcm.googleapis.com/fcm/send', [
                'registration_ids' => $tokens,
                'notification'     => [
                    'title' => $payload['title'],
                    'body'  => $payload['body'],
                    'sound' => 'default',
                ],
                'data' => array_merge($payload['data'] ?? [], [
                    'type'  => $payload['type'] ?? 'general',
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ]),
                'priority' => 'high',
            ]);

            if (!$response->successful()) {
                Log::warning('FCM send failed', ['response' => $response->body()]);
            }
        } catch (\Exception $e) {
            Log::error('FCM exception', ['error' => $e->getMessage()]);
        }
    }
}
