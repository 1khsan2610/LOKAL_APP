<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\LokalCoinTransactionResource;
use App\Models\LokalCoinBalance;
use App\Services\LokalCoinService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WalletController extends Controller
{
    protected LokalCoinService $lokalCoinService;

    public function __construct(LokalCoinService $lokalCoinService)
    {
        $this->lokalCoinService = $lokalCoinService;
    }

    /**
     * Get wallet balance
     */
    public function balance(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $balance = $this->lokalCoinService->getBalance($user);

            return response()->json([
                'success' => true,
                'data' => [
                    'user_id' => $user->id,
                    'balance' => (float) $balance->balance,
                    'total_earned' => (float) $balance->total_earned,
                    'total_spent' => (float) $balance->total_spent,
                ],
            ], 200);
        } catch (\Exception $e) {
            \Log::error('Wallet balance error: ' . $e->getMessage() . ' ' . $e->getTraceAsString());
            return response()->json([
                'success' => false,
                'message' => 'Error fetching balance: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get wallet transaction history
     */
    public function history(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = $user->lokalCoinTransactions();

        // Filter by type
        if ($request->type) {
            $query->where('type', $request->type);
        }

        // Filter by source
        if ($request->source) {
            $query->where('source', $request->source);
        }

        // Filter by date range
        if ($request->start_date && $request->end_date) {
            $query->whereBetween('created_at', [$request->start_date, $request->end_date]);
        }

        $transactions = $query->orderBy('created_at', 'desc')->paginate(20);

        return response()->json([
            'success' => true,
            'data' => LokalCoinTransactionResource::collection($transactions->items()),
            'pagination' => [
                'total' => $transactions->total(),
                'per_page' => $transactions->perPage(),
                'current_page' => $transactions->currentPage(),
                'last_page' => $transactions->lastPage(),
            ],
        ], 200);
    }

    /**
     * Get expiring coins notification
     */
    public function expiringCoins(Request $request): JsonResponse
    {
        $user = $request->user();

        $totalExpiring = $this->lokalCoinService->notifyExpiringCoins($user);

        return response()->json([
            'success' => true,
            'data' => [
                'total_expiring' => (float) $totalExpiring,
                'expiring_date' => now()->addDays(30),
            ],
        ], 200);
    }
}
