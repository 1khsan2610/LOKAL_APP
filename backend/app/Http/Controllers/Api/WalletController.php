<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\Wallet;
use App\Models\CoinTransaction;
use Illuminate\Http\Request;

class WalletController extends Controller
{
    public function index()
    {
        $wallet = Wallet::where('user_id', auth()->id())->firstOrFail();
        return response()->json(['success' => true, 'data' => [
            'coin_balance' => $wallet->coin_balance,
            'rupiah_value' => $wallet->coin_balance * 10,
        ]]);
    }

    public function transactions(Request $request)
    {
        $txns = CoinTransaction::where('user_id', auth()->id())
            ->orderBy('created_at', 'desc')
            ->paginate(20);
        return response()->json(['success' => true, 'data' => $txns]);
    }

    public function redeem(Request $request)
    {
        $request->validate(['amount' => 'required|integer|min:1']);
        $wallet = Wallet::where('user_id', auth()->id())->firstOrFail();
        if ($wallet->coin_balance < $request->amount) {
            return response()->json(['success' => false, 'message' => 'Saldo Coin tidak mencukupi.'], 422);
        }
        return response()->json(['success' => true, 'message' => 'Coin berhasil digunakan.']);
    }
}
