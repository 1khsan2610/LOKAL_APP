import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';

// API Service provider
final apiServiceProvider = Provider((ref) => ApiService());

// Products list provider
class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ApiService apiService;

  ProductsNotifier({required this.apiService})
      : super(const AsyncValue.loading());

  Future<void> fetchProducts({
    String? searchQuery,
    String? category,
    double? minPrice,
    double? maxPrice,
    double radius = 5.0,
    int page = 1,
  }) async {
    state = const AsyncValue.loading();
    try {
      final products = await apiService.getProducts(
        page: page,
        category: category,
        search: searchQuery,
      );

      final productList = products
          .map((x) => Product.fromJson(x as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(productList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await apiService.createProduct(productData);
      // Refresh products list
      await fetchProducts();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final productsProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ProductsNotifier(apiService: apiService);
});

// Single product provider
final productDetailProvider =
    FutureProvider.family<Product, String>((ref, productId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getProduct(int.parse(productId));
    return Product.fromJson(response);
  } catch (e) {
    rethrow;
  }
});

// Product filter provider
final productFilterProvider =
    StateProvider<ProductFilter>((ref) => const ProductFilter());

// Filtered products provider
final filteredProductsProvider =
    FutureProvider<List<Product>>((ref) async {
  final filter = ref.watch(productFilterProvider);
  final notifier = ref.read(productsProvider.notifier);

  await notifier.fetchProducts(
    searchQuery: filter.searchQuery,
    category: filter.category,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
    radius: filter.radius,
  );

  return ref.watch(productsProvider).when(
    data: (products) => products,
    loading: () => [],
    error: (_, __) => [],
  );
});

// Product categories provider
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.get(
    '/products/categories',
    responseDecoder: (data) {
      if (data is Map && data.containsKey('categories')) {
        return List<String>.from(data['categories']);
      }
      return <String>[];
    },
  );
});
