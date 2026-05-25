import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

// Wallet provider
final walletProvider = FutureProvider<Wallet>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getWalletBalance();
    return Wallet.fromJson(response);
  } catch (e) {
    rethrow;
  }
});

// Wallet transactions provider
final walletTransactionsProvider =
    FutureProvider.family<List<CoinTransaction>, int>((ref, page) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final transactions = await apiService.getWalletHistory();
    return transactions
        .map((x) => CoinTransaction.fromJson(x as Map<String, dynamic>))
        .toList();
  } catch (e) {
    rethrow;
  }
});

// Expiring coins provider
final expiringCoinsProvider = FutureProvider<List<CoinTransaction>>((ref) async {
  try {
    // This would need to be implemented in API
    return <CoinTransaction>[];
  } catch (e) {
    rethrow;
  }
});

// Wallet notifier untuk handle coin operations
class WalletNotifier extends StateNotifier<AsyncValue<Wallet>> {
  final ApiService apiService;

  WalletNotifier({required this.apiService}) : super(const AsyncValue.loading());

  Future<void> refreshWallet() async {
    state = const AsyncValue.loading();
    try {
      final response = await apiService.getWalletBalance();
      final wallet = Wallet.fromJson(response);
      state = AsyncValue.data(wallet);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> useCoin({
    required double amount,
    required String orderId,
  }) async {
    try {
      // This would need to be implemented in ApiService
      // Refresh wallet
      await refreshWallet();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final walletStateProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<Wallet>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return WalletNotifier(apiService: apiService);
});
