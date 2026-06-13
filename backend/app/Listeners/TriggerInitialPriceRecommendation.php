<?php

namespace App\Listeners;

use App\Events\ProductCreatedEvent;
use App\Services\MlRecommendationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\Log;

class TriggerInitialPriceRecommendation implements ShouldQueue
{
    use InteractsWithQueue;

    protected MlRecommendationService $mlService;

    /**
     * Create the event listener.
     */
    public function __construct(MlRecommendationService $mlService)
    {
        $this->mlService = $mlService;
    }

    /**
     * Handle the event - trigger async ML analysis for new product
     */
    public function handle(ProductCreatedEvent $event): void
    {
        try {
            $product = $event->product;

            // Get UMKM coordinates if available
            $latitude = $product->umkm?->latitude ?? 0;
            $longitude = $product->umkm?->longitude ?? 0;

            // Trigger async recommendation
            $result = $this->mlService->triggerAsyncRecommendation(
                $product,
                (float) $latitude,
                (float) $longitude
            );

            if ($result['success']) {
                Log::info('Initial price recommendation triggered for product', [
                    'product_id' => $product->id,
                    'request_id' => $result['request_id'],
                ]);
            } else {
                Log::warning('Failed to trigger initial recommendation', [
                    'product_id' => $product->id,
                    'error' => $result['message'] ?? 'Unknown error',
                ]);
            }
        } catch (\Exception $e) {
            Log::error('Error in TriggerInitialPriceRecommendation', [
                'product_id' => $event->product->id,
                'exception' => $e->getMessage(),
            ]);

            // Don't fail the event, just log the error
        }
    }
}
