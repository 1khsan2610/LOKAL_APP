// ═══════════════════════════════════════════════════════════════════
//  MODELS  —  ekonomi_lokal/frontend/lib/models/
// ═══════════════════════════════════════════════════════════════════

// ─── user_model.dart ────────────────────────────────────────────────
class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;
  final bool isActive;
  final WalletModel? wallet;
  final UmkmModel? umkm;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
    required this.isActive,
    this.wallet,
    this.umkm,
  });

  bool get isAdmin    => role == 'admin';
  bool get isUmkm     => role == 'umkm';
  bool get isKonsumen => role == 'konsumen';

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id:       j['id'],
    name:     j['name'],
    email:    j['email'],
    phone:    j['phone'] ?? '',
    role:     j['role'],
    avatar:   j['avatar'],
    isActive: j['is_active'] ?? true,
    wallet:   j['wallet'] != null ? WalletModel.fromJson(j['wallet']) : null,
    umkm:     j['umkm']   != null ? UmkmModel.fromJson(j['umkm'])     : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email, 'phone': phone,
    'role': role, 'avatar': avatar, 'is_active': isActive,
  };
}

// ─── wallet_model.dart ──────────────────────────────────────────────
class WalletModel {
  final int? id;
  final int coinBalance;
  final int? cashBalance;
  final int? commissionBalance;
  final int rupiahValue;
  final BankAccountModel? bankAccount;

  const WalletModel({
    this.id,
    required this.coinBalance,
    this.cashBalance,
    this.commissionBalance,
    required this.rupiahValue,
    this.bankAccount,
  });

  factory WalletModel.fromJson(Map<String, dynamic> j) => WalletModel(
    id: j['id'],
    coinBalance: j['coin_balance'] ?? 0,
    cashBalance: j['cash_balance'],
    commissionBalance: j['commission_balance'],
    rupiahValue: j['rupiah_value'] ?? ((j['coin_balance'] ?? 0) * 10),
    bankAccount: j['bank_account'] != null ? BankAccountModel.fromJson(j['bank_account']) : null,
  );
}

class BankAccountModel {
  final int id;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String status;

  const BankAccountModel({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    required this.status,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> j) => BankAccountModel(
    id: j['id'],
    bankName: j['bank_name'] ?? '',
    accountNumber: j['account_number'] ?? '',
    accountHolder: j['account_holder'] ?? '',
    status: j['status'] ?? 'pending',
  );
}

// ─── umkm_model.dart ────────────────────────────────────────────────
class UmkmModel {
  final int id;
  final int userId;
  final String name;
  final String? logo;
  final String? description;
  final String? phone;
  final String? address;
  final String? category;
  final String? city;
  final String? province;
  final double? latitude;
  final double? longitude;
  final double avgRating;
  final int totalSold;
  final bool isVerified;
  final bool isActive;

  const UmkmModel({
    required this.id,
    required this.userId,
    required this.name,
    this.logo,
    this.description,
    this.phone,
    this.address,
    this.category,
    this.city,
    this.province,
    this.latitude,
    this.longitude,
    this.avgRating = 0,
    this.totalSold = 0,
    this.isVerified = false,
    this.isActive = true,
  });

  factory UmkmModel.fromJson(Map<String, dynamic> j) => UmkmModel(
    id:          j['id'],
    userId:      j['user_id'],
    name:        j['name'],
    logo:        j['logo'],
    description: j['description'],
    phone:       j['phone'],
    address:     j['address'],
    category:    j['category'],
    city:        j['city'],
    province:    j['province'],
    latitude:    j['latitude'] != null ? double.tryParse(j['latitude'].toString()) : null,
    longitude:   j['longitude'] != null ? double.tryParse(j['longitude'].toString()) : null,
    avgRating:   (j['avg_rating'] ?? 0).toDouble(),
    totalSold:   j['total_sold'] ?? 0,
    isVerified:  j['is_verified'] ?? false,
    isActive:    j['is_active'] ?? true,
  );
}

// ─── product_model.dart ─────────────────────────────────────────────
class ProductModel {
  final int id;
  final int umkmId;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String category;
  final double weight;
  final int soldCount;
  final double avgRating;
  final bool isActive;
  final int? flashSalePrice;
  final int? flashSaleDiscount;
  final String? flashSaleEndsAt;
  final UmkmModel? umkm;
  final List<ProductImageModel> images;
  final List<ProductVariantModel> variants;

  const ProductModel({
    required this.id,
    required this.umkmId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.weight,
    required this.soldCount,
    required this.avgRating,
    required this.isActive,
    this.flashSalePrice,
    this.flashSaleDiscount,
    this.flashSaleEndsAt,
    this.umkm,
    this.images = const [],
    this.variants = const [],
  });

  String? get primaryImage => images.isNotEmpty
      ? images.firstWhere((i) => i.isPrimary, orElse: () => images.first).url
      : null;

  bool get hasFlashSale =>
      flashSalePrice != null && flashSaleEndsAt != null &&
      DateTime.tryParse(flashSaleEndsAt!)?.isAfter(DateTime.now()) == true;

  int get displayPrice => hasFlashSale ? flashSalePrice! : price;

  int get coinReward => (price / 1000).floor();

  factory ProductModel.fromJson(Map<String, dynamic> j) => ProductModel(
    id:                 j['id'],
    umkmId:             j['umkm_id'],
    name:               j['name'],
    description:        j['description'] ?? '',
    price:              j['price'] ?? 0,
    stock:              j['stock'] ?? 0,
    category:           j['category'] ?? '',
    weight:             (j['weight'] ?? 0).toDouble(),
    soldCount:          j['sold_count'] ?? 0,
    avgRating:          (j['avg_rating'] ?? 0).toDouble(),
    isActive:           j['is_active'] ?? true,
    flashSalePrice:     j['flash_sale_price'],
    flashSaleDiscount:  j['flash_sale_discount'],
    flashSaleEndsAt:    j['flash_sale_ends_at'],
    umkm:    j['umkm']   != null ? UmkmModel.fromJson(j['umkm'])             : null,
    images:  j['images'] != null ? (j['images'] as List).map((e) => ProductImageModel.fromJson(e)).toList()   : [],
    variants:j['variants']!= null ? (j['variants'] as List).map((e) => ProductVariantModel.fromJson(e)).toList(): [],
  );
}

class ProductImageModel {
  final int id;
  final String url;
  final bool isPrimary;
  const ProductImageModel({required this.id, required this.url, required this.isPrimary});
  factory ProductImageModel.fromJson(Map<String, dynamic> j) =>
      ProductImageModel(id: j['id'], url: j['url'], isPrimary: j['is_primary'] ?? false);
}

class ProductVariantModel {
  final int id;
  final String name;
  final String value;
  final int priceModifier;
  final int stock;
  const ProductVariantModel({required this.id, required this.name, required this.value, required this.priceModifier, required this.stock});
  factory ProductVariantModel.fromJson(Map<String, dynamic> j) =>
      ProductVariantModel(id: j['id'], name: j['name'], value: j['value'], priceModifier: j['price_modifier'] ?? 0, stock: j['stock'] ?? 0);
}

// ─── address_model.dart ─────────────────────────────────────────────
class AddressModel {
  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String detail;
  final String city;
  final String province;
  final String zip;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.detail,
    required this.city,
    required this.province,
    required this.zip,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> j) => AddressModel(
    id:            j['id'],
    label:         j['label'] ?? 'Rumah',
    recipientName: j['recipient_name'],
    phone:         j['phone'] ?? '',
    detail:        j['detail'],
    city:          j['city'],
    province:      j['province'] ?? '',
    zip:           j['zip'] ?? '',
    isDefault:     j['is_default'] ?? false,
  );

  String get fullAddress => '$detail, $city, $province $zip';
}

// ─── cart_model.dart ────────────────────────────────────────────────
class CartItemModel {
  final int id;
  final int productId;
  final int? variantId;
  int quantity;
  final ProductModel product;

  CartItemModel({
    required this.id,
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.product,
  });

  int get subtotal => product.displayPrice * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> j) => CartItemModel(
    id:        j['id'],
    productId: j['product_id'],
    variantId: j['variant_id'],
    quantity:  j['quantity'],
    product:   ProductModel.fromJson(j['product']),
  );
}

// ─── order_model.dart ───────────────────────────────────────────────
class OrderModel {
  final int id;
  final String orderNumber;
  final String status;
  final int subtotal;
  final int shippingFee;
  final String shippingMethod;
  final String? trackingNumber;
  final int coinDiscount;
  final int total;
  final String? notes;
  final String createdAt;
  final AddressModel? address;
  final List<OrderItemModel> items;
  final PaymentModel? payment;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.subtotal,
    required this.shippingFee,
    required this.shippingMethod,
    this.trackingNumber,
    required this.coinDiscount,
    required this.total,
    this.notes,
    required this.createdAt,
    this.address,
    this.items = const [],
    this.payment,
  });

  String get statusLabel => {
    'pending':          '⏳ Menunggu Bayar',
    'awaiting_payment': '💳 Menunggu Pembayaran',
    'processing':       '📦 Sedang Dikemas',
    'shipped':          '🚚 Dalam Pengiriman',
    'delivered':        '✅ Sudah Diterima',
    'cancelled':        '❌ Dibatalkan',
  }[status] ?? status;

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id:             j['id'],
    orderNumber:    j['order_number'],
    status:         j['status'],
    subtotal:       j['subtotal'] ?? 0,
    shippingFee:    j['shipping_fee'] ?? 0,
    shippingMethod: j['shipping_method'] ?? '',
    trackingNumber: j['tracking_number'],
    coinDiscount:   j['coin_discount'] ?? 0,
    total:          j['total'] ?? 0,
    notes:          j['notes'],
    createdAt:      j['created_at'] ?? '',
    address:   j['address'] != null  ? AddressModel.fromJson(j['address'])   : null,
    items:     j['items']   != null  ? (j['items'] as List).map((e) => OrderItemModel.fromJson(e)).toList() : [],
    payment:   j['payment'] != null  ? PaymentModel.fromJson(j['payment'])   : null,
  );
}

class OrderItemModel {
  final int id;
  final int productId;
  final int quantity;
  final int price;
  final int subtotal;
  final ProductModel? product;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> j) => OrderItemModel(
    id:        j['id'],
    productId: j['product_id'],
    quantity:  j['quantity'],
    price:     j['price'] ?? 0,
    subtotal:  j['subtotal'] ?? 0,
    product:   j['product'] != null ? ProductModel.fromJson(j['product']) : null,
  );
}

class PaymentModel {
  final int id;
  final String? snapToken;
  final String? snapUrl;
  final String status;
  final String? paymentMethod;
  final String? paidAt;

  const PaymentModel({
    required this.id,
    this.snapToken,
    this.snapUrl,
    required this.status,
    this.paymentMethod,
    this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> j) => PaymentModel(
    id:            j['id'],
    snapToken:     j['snap_token'],
    snapUrl:       j['snap_url'],
    status:        j['status'],
    paymentMethod: j['payment_method'],
    paidAt:        j['paid_at'],
  );
}

// ─── notification_model.dart ────────────────────────────────────────
class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
    id:        j['id'],
    title:     j['title'],
    body:      j['body'],
    type:      j['type'] ?? 'general',
    isRead:    j['is_read'] ?? false,
    createdAt: j['created_at'] ?? '',
    data:      j['data'] is Map<String, dynamic> ? j['data'] : null,
  );
}

// ─── coin_transaction_model.dart ────────────────────────────────────
class CoinTransactionModel {
  final int id;
  final String type; // 'credit' | 'debit'
  final int amount;
  final String description;
  final int balanceAfter;
  final String? expiresAt;
  final String createdAt;

  const CoinTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.balanceAfter,
    this.expiresAt,
    required this.createdAt,
  });

  bool get isCredit => type == 'credit';

  factory CoinTransactionModel.fromJson(Map<String, dynamic> j) => CoinTransactionModel(
    id:           j['id'],
    type:         j['type'],
    amount:       j['amount'] ?? 0,
    description:  j['description'],
    balanceAfter: j['balance_after'] ?? 0,
    expiresAt:    j['expires_at'],
    createdAt:    j['created_at'] ?? '',
  );
}

// ─── review_model.dart ──────────────────────────────────────────────
class ReviewModel {
  final int id;
  final int userId;
  final String userName;
  final int productId;
  final int orderId;
  final int rating;
  final String? comment;
  final List<String>? images;
  final String createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.productId,
    required this.orderId,
    required this.rating,
    this.comment,
    this.images,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> j) => ReviewModel(
    id:        j['id'],
    userId:    j['user_id'],
    userName:  j['user']?['name'] ?? 'Pengguna',
    productId: j['product_id'],
    orderId:   j['order_id'],
    rating:    j['rating'] ?? 0,
    comment:   j['comment'],
    images:    j['images'] != null ? List<String>.from(j['images']) : null,
    createdAt: j['created_at'] ?? '',
  );
}
