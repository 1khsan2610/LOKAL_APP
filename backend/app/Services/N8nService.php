<?php

namespace App\Services;

use App\Models\Order;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class N8nService
{
    protected string $webhookUrl;
    protected int $timeout;
    protected ?string $apiKey;

    public function __construct()
    {
        $this->webhookUrl = rtrim(config('services.n8n.webhook_url', ''), '/');
        $this->timeout = (int) config('services.n8n.timeout', 10);
        $this->apiKey = config('services.n8n.api_key');
    }

    public function triggerWorkflow(string $workflowKey, array $payload = []): bool
    {
        if (empty($this->webhookUrl)) {
            Log::warning('n8n webhook URL is not configured.');
            return false;
        }

        $url = $this->buildWebhookUrl($workflowKey);

        $response = Http::timeout($this->timeout)
            ->acceptJson()
            ->withHeaders($this->defaultHeaders())
            ->post($url, $payload);

        if ($response->successful()) {
            return true;
        }

        Log::warning('n8n webhook request failed.', [
            'url' => $url,
            'status' => $response->status(),
            'body' => $response->body(),
            'payload' => $payload,
        ]);

        return false;
    }

    public function buildOrderPayload(Order $order): array
    {
        return [
            'event' => 'order.confirmed',
            'order' => [
                'id' => $order->id,
                'order_number' => $order->order_number,
                'status' => $order->status,
                'total_amount' => $order->total_amount,
                'items' => $order->items->map(fn ($item) => [
                    'product_id' => $item->product_id,
                    'product_name' => $item->product_name,
                    'quantity' => $item->quantity,
                    'price' => $item->product_price,
                ])->toArray(),
            ],
            'consumer' => [
                'id' => $order->consumer_id,
                'name' => $order->consumer->name,
                'phone' => $order->consumer->phone_number,
                'email' => $order->consumer->email,
            ],
            'umkm' => [
                'id' => $order->umkm_id,
                'name' => $order->umkm->name ?? $order->umkm->user?->name,
                'phone' => $order->umkm->phone_number ?? null,
                'owner_user_id' => $order->umkm->user_id,
            ],
        ];
    }

    protected function buildWebhookUrl(string $workflowKey): string
    {
        return $this->webhookUrl . '/' . ltrim($workflowKey, '/');
    }

    protected function defaultHeaders(): array
    {
        $headers = [
            'Accept' => 'application/json',
            'Content-Type' => 'application/json',
        ];

        if (!empty($this->apiKey)) {
            $headers['X-API-KEY'] = $this->apiKey;
        }

        return $headers;
    }
}
