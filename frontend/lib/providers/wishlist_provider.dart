import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  static const String _storageKey = 'wishlist_product_ids';

  final List<int> _favoriteProductIds = [];
  bool _isLoading = false;

  List<int> get favoriteProductIds => List.unmodifiable(_favoriteProductIds);
  bool get isLoading => _isLoading;

  WishlistProvider() {
    load();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_storageKey) ?? [];
      _favoriteProductIds
        ..clear()
        ..addAll(ids.map(int.parse).whereType<int>());
    } catch (_) {
      _favoriteProductIds.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(int productId) => _favoriteProductIds.contains(productId);

  Future<void> toggleFavorite(ProductModel product) async {
    final productId = product.id;
    if (isFavorite(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _favoriteProductIds.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _favoriteProductIds.map((id) => id.toString()).toList(),
    );
  }
}
