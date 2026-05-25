import 'package:frontend/models/product.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

enum PaymentMethod {
  gopay,
  ovo,
  dana,
  bank_transfer,
  qris,
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? productImage;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.productImage,
  });

  double get subtotal => price * quantity;

  String get name => productName;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: (json['product_id'] ?? '').toString(),
      productName: (json['product_name'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] ?? 1,
      productImage: json['product_image'] != null ? json['product_image'].toString() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'product_image': productImage,
    };
  }

  List<Object?> get props =>
      [productId, productName, price, quantity, productImage];
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shippingCost;
  final double coinUsed;
  final double coinDiscount;
  final double totalPrice;
  final OrderStatus status;
  final PaymentMethod? paymentMethod;
  final String? paymentId;
  final String? shippingAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shippingCost,
    required this.coinUsed,
    required this.coinDiscount,
    required this.totalPrice,
    required this.status,
    this.paymentMethod,
    this.paymentId,
    this.shippingAddress,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? shippingCost,
    double? coinUsed,
    double? coinDiscount,
    double? totalPrice,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    String? paymentId,
    String? shippingAddress,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shippingCost: shippingCost ?? this.shippingCost,
      coinUsed: coinUsed ?? this.coinUsed,
      coinDiscount: coinDiscount ?? this.coinDiscount,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      items: List<OrderItem>.from(
        (json['items'] as List?)?.map((x) => OrderItem.fromJson(x)) ?? [],
      ),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0,
      coinUsed: (json['coin_used'] as num?)?.toDouble() ?? 0,
      coinDiscount: (json['coin_discount'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(json['status']),
      paymentMethod: _parsePaymentMethod(json['payment_method']),
      paymentId: json['payment_id'] != null ? json['payment_id'].toString() : null,
      shippingAddress: json['shipping_address'] != null ? json['shipping_address'].toString() : null,
      notes: json['notes'] != null ? json['notes'].toString() : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items.map((x) => x.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping_cost': shippingCost,
      'coin_used': coinUsed,
      'coin_discount': coinDiscount,
      'total_price': totalPrice,
      'status': status.toString().split('.').last,
      'payment_method': paymentMethod?.toString().split('.').last,
      'payment_id': paymentId,
      'shipping_address': shippingAddress,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  static OrderStatus _parseStatus(dynamic statusValue) {
    if (statusValue is String) {
      switch (statusValue.toLowerCase()) {
        case 'confirmed':
          return OrderStatus.confirmed;
        case 'processing':
          return OrderStatus.processing;
        case 'shipped':
          return OrderStatus.shipped;
        case 'delivered':
          return OrderStatus.delivered;
        case 'cancelled':
          return OrderStatus.cancelled;
        case 'refunded':
          return OrderStatus.refunded;
        default:
          return OrderStatus.pending;
      }
    }
    return OrderStatus.pending;
  }

  static PaymentMethod? _parsePaymentMethod(dynamic methodValue) {
    if (methodValue is String) {
      switch (methodValue.toLowerCase()) {
        case 'gopay':
          return PaymentMethod.gopay;
        case 'ovo':
          return PaymentMethod.ovo;
        case 'dana':
          return PaymentMethod.dana;
        case 'bank_transfer':
          return PaymentMethod.bank_transfer;
        case 'qris':
          return PaymentMethod.qris;
      }
    }
    return null;
  }

  List<Object?> get props => [
    id,
    userId,
    items,
    subtotal,
    tax,
    shippingCost,
    coinUsed,
    coinDiscount,
    totalPrice,
    status,
    paymentMethod,
    paymentId,
    shippingAddress,
    notes,
    createdAt,
    updatedAt,
    completedAt,
  ];

  double get total => totalPrice;
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;

  void incrementQuantity() => quantity++;

  void decrementQuantity() {
    if (quantity > 1) quantity--;
  }

  List<Object?> get props => [product, quantity];
}
