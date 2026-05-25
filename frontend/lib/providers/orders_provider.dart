import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

// Orders list provider
class OrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final ApiService apiService;

  OrdersNotifier({required this.apiService})
      : super(const AsyncValue.loading());

  Future<void> fetchOrders({int page = 1, String? status}) async {
    state = const AsyncValue.loading();
    try {
      final orders = await apiService.getOrders();
      final orderList = orders
          .map((x) => Order.fromJson(x as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(orderList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Order> createOrder({
    required List<OrderItem> items,
    required double subtotal,
    required double tax,
    required double shippingCost,
    required double coinUsed,
    required PaymentMethod paymentMethod,
    String? shippingAddress,
    String? notes,
  }) async {
    try {
      final response = await apiService.createOrder({
        'items': items.map((x) => x.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'shipping_cost': shippingCost,
        'coin_used': coinUsed,
        'payment_method': paymentMethod.toString().split('.').last,
        'shipping_address': shippingAddress,
        'notes': notes,
      });

      final order = Order.fromJson(response);

      // Refresh orders list
      if (state case AsyncValue(value: List<Order> orders)) {
        state = AsyncValue.data([order, ...orders]);
      }

      return order;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Order> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) async {
    try {
      // This would need to be implemented in ApiService
      final updatedOrder = Order(
        id: orderId,
        userId: '',
        items: [],
        totalPrice: 0,
        subtotal: 0,
        tax: 0,
        shippingCost: 0,
        coinUsed: 0,
        coinDiscount: 0,
        status: newStatus,
        paymentMethod: PaymentMethod.gopay,
        createdAt: DateTime.now(),
      );

      // Update in local state
      if (state case AsyncValue(value: List<Order> orders)) {
        final newOrders = orders.map((order) {
          return order.id == orderId ? updatedOrder : order;
        }).toList();
        state = AsyncValue.data(newOrders);
      }

      return updatedOrder;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, AsyncValue<List<Order>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return OrdersNotifier(apiService: apiService);
});

// Single order detail provider
final orderDetailProvider =
    FutureProvider.family<Order, String>((ref, orderId) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.get(
    '/orders/$orderId',
    responseDecoder: (data) => Order.fromJson(data),
  );
});

// Cart state
class CartState {
  final List<CartItem> items;
  final double coinDiscount;

  CartState({
    required this.items,
    required this.coinDiscount,
  });

  CartState copyWith({
    List<CartItem>? items,
    double? coinDiscount,
  }) {
    return CartState(
      items: items ?? this.items,
      coinDiscount: coinDiscount ?? this.coinDiscount,
    );
  }

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  double get tax => subtotal * 0.1; // 10% tax

  double get shippingCost => 15000.0; // Fixed shipping

  double get discountAmount =>
      (subtotal * coinDiscount).clamp(0, subtotal * 0.2);

  double get total => subtotal + tax + shippingCost - discountAmount;
}

// Cart notifier
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier()
      : super(CartState(
        items: [],
        coinDiscount: 0,
      ));

  void addItem(Product product) {
    final existingItem =
        state.items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingItem.quantity > 0) {
      existingItem.incrementQuantity();
      state = state.copyWith(
        items: [...state.items],
      );
    } else {
      state = state.copyWith(
        items: [...state.items, CartItem(product: product)],
      );
    }
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items
          .where((item) => item.product.id != productId)
          .toList(),
    );
  }

  void updateQuantity(String productId, int quantity) {
    final items = state.items;
    final itemIndex =
        items.indexWhere((item) => item.product.id == productId);

    if (itemIndex >= 0) {
      if (quantity <= 0) {
        removeItem(productId);
      } else {
        items[itemIndex].quantity = quantity;
        state = state.copyWith(items: [...items]);
      }
    }
  }

  void setCoinDiscount(double coinDiscount) {
    state = state.copyWith(coinDiscount: coinDiscount);
  }

  void clearCart() {
    state = CartState(
      items: [],
      coinDiscount: 0,
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
