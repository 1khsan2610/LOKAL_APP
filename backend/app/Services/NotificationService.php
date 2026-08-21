<?php

namespace App\Services;

use App\Models\Notification;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    /**
     * n8n Webhook base URL from config
     */
    private function getWebhookUrl(): ?string
    {
        return config('services.n8n.webhook_url');
    }

    /**
     * Send notification to a user (save to DB + trigger n8n webhook)
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

        // Trigger n8n webhook for push notification (F-07)
        $this->triggerN8nWebhook([
            'event'     => 'user_notification',
            'user_id'   => $userId,
            'title'     => $payload['title'],
            'body'      => $payload['body'],
            'type'      => $payload['type'] ?? 'general',
            'data'      => $payload['data'] ?? null,
        ]);
    }

    /**
     * Broadcast to all users (admin)
     */
    public function broadcast(array $payload): void
    {
        $this->triggerN8nWebhook([
            'event' => 'broadcast',
            'title' => $payload['title'],
            'body'  => $payload['body'],
            'type'  => $payload['type'] ?? 'general',
            'data'  => $payload['data'] ?? null,
        ]);
    }

    /**
     * Trigger event-specific n8n webhook (F-07: Otomasi via n8n)
     *
     * Events:
     * - order.new       : Pesanan baru dibuat
     * - payment.settlement : Pembayaran sukses
     * - order.shipped   : Pesanan dikirim
     * - stock.low       : Stok menipis (< 10)
     * - bank.verified   : Verifikasi bank
     */
    public function triggerEvent(string $event, array $data): void
    {
        $this->triggerN8nWebhook(array_merge([
            'event' => $event,
        ], $data));
    }

    /**
     * Send HTTP POST to n8n webhook trigger
     */
    private function triggerN8nWebhook(array $payload): void
    {
        $webhookUrl = $this->getWebhookUrl();

        if (empty($webhookUrl)) {
            // n8n not configured, skip silently
            return;
        }

        try {
            $response = Http::timeout(5)
                ->withHeaders([
                    'Content-Type'  => 'application/json',
                    'X-Source'      => 'LOKAL-Backend',
                ])
                ->post($webhookUrl, $payload);

            if (!$response->successful()) {
                Log::warning('n8n webhook trigger failed', [
                    'url'      => $webhookUrl,
                    'status'   => $response->status(),
                    'response' => $response->body(),
                ]);
            }
        } catch (\Exception $e) {
            Log::error('n8n webhook exception', [
                'error' => $e->getMessage(),
            ]);
        }
    }
}