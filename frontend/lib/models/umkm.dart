class UMKM {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? logo;
  final String? banner;
  final String? address;
  final String city;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final String category;
  final double rating;
  final int reviewCount;
  final int productCount;
  final int followerCount;
  final String? nibNumber;
  final String? siupNumber;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UMKM({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.logo,
    this.banner,
    this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.productCount,
    required this.followerCount,
    this.nibNumber,
    this.siupNumber,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  UMKM copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? logo,
    String? banner,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    String? phone,
    String? website,
    String? category,
    double? rating,
    int? reviewCount,
    int? productCount,
    int? followerCount,
    String? nibNumber,
    String? siupNumber,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UMKM(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      banner: banner ?? this.banner,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      productCount: productCount ?? this.productCount,
      followerCount: followerCount ?? this.followerCount,
      nibNumber: nibNumber ?? this.nibNumber,
      siupNumber: siupNumber ?? this.siupNumber,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UMKM.fromJson(Map<String, dynamic> json) {
    return UMKM(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description'] != null ? json['description'].toString() : null,
      logo: json['logo'] != null ? json['logo'].toString() : null,
      banner: json['banner'] != null ? json['banner'].toString() : null,
      address: json['address'] != null ? json['address'].toString() : null,
      city: (json['city'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      phone: json['phone'] != null ? json['phone'].toString() : null,
      website: json['website'] != null ? json['website'].toString() : null,
      category: (json['category'] ?? '').toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] ?? 0,
      productCount: json['product_count'] ?? 0,
      followerCount: json['follower_count'] ?? 0,
      nibNumber: json['nib_number'] != null ? json['nib_number'].toString() : null,
      siupNumber: json['siup_number'] != null ? json['siup_number'].toString() : null,
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'logo': logo,
      'banner': banner,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'website': website,
      'category': category,
      'rating': rating,
      'review_count': reviewCount,
      'product_count': productCount,
      'follower_count': followerCount,
      'nib_number': nibNumber,
      'siup_number': siupNumber,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  List<Object?> get props => [
    id,
    userId,
    name,
    description,
    logo,
    banner,
    address,
    city,
    latitude,
    longitude,
    phone,
    website,
    category,
    rating,
    reviewCount,
    productCount,
    followerCount,
    nibNumber,
    siupNumber,
    isVerified,
    isActive,
    createdAt,
    updatedAt,
  ];
}

class AnalyticsSummary {
  final double totalRevenue;
  final double revenueGrowth;
  final int totalOrders;
  final int totalCustomers;
  final int topProductId;
  final String topProductName;
  final double topProductRevenue;
  final double averageRating;
  final List<DailyRevenue> dailyRevenue;
  final List<ProductSales> productSales;

  const AnalyticsSummary({
    required this.totalRevenue,
    required this.revenueGrowth,
    required this.totalOrders,
    required this.totalCustomers,
    required this.topProductId,
    required this.topProductName,
    required this.topProductRevenue,
    required this.averageRating,
    required this.dailyRevenue,
    required this.productSales,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      revenueGrowth: (json['revenue_growth'] as num?)?.toDouble() ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      totalCustomers: json['total_customers'] ?? 0,
      topProductId: json['top_product']['id'] ?? '',
      topProductName: json['top_product']['name'] ?? '',
      topProductRevenue:
          (json['top_product']['revenue'] as num?)?.toDouble() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      dailyRevenue: List<DailyRevenue>.from(
        (json['daily_revenue'] as List?)?.map((x) => DailyRevenue.fromJson(x)) ??
            [],
      ),
      productSales: List<ProductSales>.from(
        (json['product_sales'] as List?)?.map((x) => ProductSales.fromJson(x)) ??
            [],
      ),
    );
  }

  List<Object?> get props => [
    totalRevenue,
    revenueGrowth,
    totalOrders,
    totalCustomers,
    topProductId,
    topProductName,
    topProductRevenue,
    averageRating,
    dailyRevenue,
    productSales,
  ];
}

class DailyRevenue {
  final String date;
  final double revenue;
  final int orders;

  const DailyRevenue({
    required this.date,
    required this.revenue,
    required this.orders,
  });

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      date: json['date'] ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      orders: json['orders'] ?? 0,
    );
  }

  List<Object?> get props => [date, revenue, orders];
}

class ProductSales {
  final String productId;
  final String productName;
  final int quantity;
  final double revenue;

  const ProductSales({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.revenue,
  });

  factory ProductSales.fromJson(Map<String, dynamic> json) {
    return ProductSales(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }

  List<Object?> get props => [productId, productName, quantity, revenue];
}
