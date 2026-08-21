import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

// ═══════════════════════════════════════════════════════════════════
//  CartProvider
// ═══════════════════════════════════════════════════════════════════
class CartProvider extends ChangeNotifier {
  final _api = ApiService();

  List<CartItemModel> _items = [];
  bool _isLoading = false;

  List<CartItemModel> get items      => _items;
  bool                get isLoading  => _isLoading;
  int get totalItems  => _items.fold(0, (s, i) => s + i.quantity);
  int get subtotal    => _items.fold(0, (s, i) => s + i.subtotal);
  int get shippingFee => _items.isEmpty ? 0 : 10000;
  int get total       => subtotal + shippingFee;

  // Load cart from API
  Future<void> loadCart() async {
    _isLoading = true; notifyListeners();
    try {
      final resp = await _api.getCart();
      _items = (resp.data['data'] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList();
    } catch (_) {} finally {
      _isLoading = false; notifyListeners();
    }
  }

  // Add item
  Future<bool> addItem(int productId, int quantity, {int? variantId}) async {
    try {
      await _api.addToCart(productId, quantity, variantId: variantId);
      await loadCart();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update quantity
  Future<void> updateQuantity(int itemId, int quantity) async {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx < 0) return;
    final old = _items[idx].quantity;
    _items[idx].quantity = quantity;
    notifyListeners();
    try {
      await _api.updateCartItem(itemId, quantity);
    } catch (_) {
      _items[idx].quantity = old;
      notifyListeners();
    }
  }

  // Remove item
  Future<void> removeItem(int itemId) async {
    final removed = _items.firstWhere((i) => i.id == itemId);
    _items.removeWhere((i) => i.id == itemId);
    notifyListeners();
    try {
      await _api.removeCartItem(itemId);
    } catch (_) {
      _items.add(removed);
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    _items = []; notifyListeners();
    try { await _api.clearCart(); } catch (_) {}
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ProductProvider
// ═══════════════════════════════════════════════════════════════════
class ProductProvider extends ChangeNotifier {
  final _api = ApiService();

  List<ProductModel> _products     = [];
  List<ProductModel> _flashSale    = [];
  List<ProductModel> _searchResults = [];
  ProductModel?      _detail;
  bool _isLoading  = false;
  bool _hasMore    = true;
  int  _page       = 1;
  String? _currentCategory;

  List<ProductModel> get products      => _products;
  List<ProductModel> get flashSale     => _flashSale;
  List<ProductModel> get searchResults => _searchResults;
  ProductModel?      get detail        => _detail;
  bool               get isLoading     => _isLoading;
  bool               get hasMore       => _hasMore;

  // Load products with optional category filter
  Future<void> loadProducts({String? category, bool refresh = false}) async {
    if (refresh || category != _currentCategory) {
      _products = []; _page = 1; _hasMore = true;
      _currentCategory = category;
    }
    if (!_hasMore || _isLoading) return;

    _isLoading = true; notifyListeners();
    try {
      final resp = await _api.getProducts(category: category, page: _page);
      final data = resp.data['data'];
      final newItems = (data['data'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
      _products.addAll(newItems);
      _hasMore = data['current_page'] < data['last_page'];
      _page++;
    } catch (_) {} finally {
      _isLoading = false; notifyListeners();
    }
  }

  // Load more (pagination)
  Future<void> loadMore() => loadProducts(category: _currentCategory);

  // Load flash sale
  Future<void> loadFlashSale() async {
    try {
      final resp = await _api.getFlashSale();
      _flashSale = (resp.data['data'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  // Search
  Future<void> search(String query, {int? umkmId}) async {
    _isLoading = true; notifyListeners();
    try {
      final resp = await _api.searchProducts(query, umkmId: umkmId);
      _searchResults = (resp.data['data']['data'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } catch (_) {
      _searchResults = [];
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  // Get product detail
  Future<void> loadDetail(int id) async {
    _isLoading = true; notifyListeners();
    try {
      final resp = await _api.getProductDetail(id);
      _detail = ProductModel.fromJson(resp.data['data']);
    } catch (_) {} finally {
      _isLoading = false; notifyListeners();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  NotificationProvider
// ═══════════════════════════════════════════════════════════════════
class NotificationProvider extends ChangeNotifier {
  final _api = ApiService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications  => _notifications;
  bool                    get isLoading      => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> load() async {
    _isLoading = true; notifyListeners();
    try {
      final resp = await _api.getNotifications();
      _notifications = (resp.data['data'] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
    } catch (_) {} finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<void> markRead(int id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx < 0) return;
    try {
      await _api.markNotificationRead(id);
      _notifications[idx] = NotificationModel(
        id: _notifications[idx].id,
        title: _notifications[idx].title,
        body: _notifications[idx].body,
        type: _notifications[idx].type,
        isRead: true,
        createdAt: _notifications[idx].createdAt,
        data: _notifications[idx].data,
      );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _api.markAllNotificationsRead();
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id, title: n.title, body: n.body,
        type: n.type, isRead: true, createdAt: n.createdAt,
        data: n.data,
      )).toList();
      notifyListeners();
    } catch (_) {}
  }
}

// ═══════════════════════════════════════════════════════════════════
//  WalletProvider
// ═══════════════════════════════════════════════════════════════════
class WalletProvider extends ChangeNotifier {
  final _api = ApiService();

  WalletModel? _wallet;
  List<CoinTransactionModel> _transactions = [];
  bool _isLoading = false;

  WalletModel?               get wallet       => _wallet;
  List<CoinTransactionModel> get transactions => _transactions;
  bool                       get isLoading    => _isLoading;
  int get coinBalance => _wallet?.coinBalance ?? 0;
  int get rupiahValue => coinBalance * 10;

  Future<void> load() async {
    _isLoading = true; notifyListeners();
    try {
      final resp = await _api.getWallet();
      _wallet = WalletModel.fromJson(resp.data['data']);
    } catch (_) {} finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    try {
      final resp = await _api.getCoinTransactions();
      _transactions = (resp.data['data']['data'] as List)
          .map((e) => CoinTransactionModel.fromJson(e))
          .toList();
      notifyListeners();
    } catch (_) {}
  }
}
