<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\PaymentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentWebhookController extends Controller
{
    protected PaymentService $paymentService;

    public function __construct(PaymentService $paymentService)
    {
        $this->paymentService = $paymentService;
    }

    /**
     * Handle Midtrans payment notification webhook
     */
    public function midtransWebhook(Request $request): JsonResponse
    {
        // Verify signature (Midtrans library handles this)
        try {
            $notification = $request->all();

            $result = $this->paymentService->handleNotification($notification);

            return response()->json($result, 200);
        } catch (\Exception $e) {
            \Log::error('Midtrans webhook error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Webhook processing failed',
            ], 500);
        }
    }

    /**
     * Get payment details
     */
    public function getStatus(Request $request): JsonResponse
    {
        $request->validate([
            'transaction_id' => 'required|string',
        ]);

        $result = $this->paymentService->getPaymentStatus($request->transaction_id);

        return response()->json($result, 200);
    }
}
