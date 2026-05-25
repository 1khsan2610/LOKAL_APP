import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/umkm.dart';
import '../services/api_service.dart';

// UMKM list provider
class UMKMNotifier extends StateNotifier<AsyncValue<List<UMKM>>> {
  final ApiService apiService;

  UMKMNotifier({required this.apiService})
      : super(const AsyncValue.loading());

  Future<void> fetchNearbyUMKM({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    state = const AsyncValue.loading();
    try {
      final queryParams = {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      };

      final umkmList = await apiService.get(
        '/umkm/nearby',
        queryParameters: queryParams,
        responseDecoder: (data) {
          if (data is Map && data.containsKey('data')) {
            return List<UMKM>.from(
              (data['data'] as List).map((x) => UMKM.fromJson(x)),
            );
          }
          return <UMKM>[];
        },
      );

      state = AsyncValue.data(umkmList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetchUMKMByCategory(String category) async {
    state = const AsyncValue.loading();
    try {
      final umkmList = await apiService.get(
        '/umkm',
        queryParameters: {'category': category},
        responseDecoder: (data) {
          if (data is Map && data.containsKey('data')) {
            return List<UMKM>.from(
              (data['data'] as List).map((x) => UMKM.fromJson(x)),
            );
          }
          return <UMKM>[];
        },
      );

      state = AsyncValue.data(umkmList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final umkmProvider =
    StateNotifierProvider<UMKMNotifier, AsyncValue<List<UMKM>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UMKMNotifier(apiService: apiService);
});

// Single UMKM detail provider
final umkmDetailProvider =
    FutureProvider.family<UMKM, String>((ref, umkmId) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.get(
    '/umkm/$umkmId',
    responseDecoder: (data) => UMKM.fromJson(data),
  );
});

// UMKM Analytics provider
final umkmAnalyticsProvider = FutureProvider.family<AnalyticsSummary, String>(
  (ref, umkmId) async {
    final apiService = ref.watch(apiServiceProvider);
    return await apiService.get(
      '/umkm/$umkmId/analytics/summary',
      responseDecoder: (data) => AnalyticsSummary.fromJson(data),
    );
  },
);

final apiServiceProvider = Provider((ref) => ApiService());
