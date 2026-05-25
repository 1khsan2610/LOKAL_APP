class Product {
  final String id;
  final String umkmId;
  final String name;
  final String description;
  final double price;
  final double? recommendedPrice;
  final int stock;
  final String category;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final Map<String, dynamic>? attributes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.umkmId,
    required this.name,
    required this.description,
    required this.price,
    this.recommendedPrice,
    required this.stock,
    required this.category,
    required this.images,
    required this.rating,
    required this.reviewCount,
    this.attributes,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? umkmId,
    String? name,
    String? description,
    double? price,
    double? recommendedPrice,
    int? stock,
    String? category,
    List<String>? images,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? attributes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      umkmId: umkmId ?? this.umkmId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      recommendedPrice: recommendedPrice ?? this.recommendedPrice,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      attributes: attributes ?? this.attributes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasLowStock => stock < 10;
  bool get outOfStock => stock <= 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      umkmId: (json['umkm_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      recommendedPrice:
          (json['recommended_price'] as num?)?.toDouble(),
      stock: json['stock'] ?? 0,
      category: (json['category'] ?? '').toString(),
      images: List<String>.from(
        (json['images'] as List?)?.map((x) => x.toString()) ?? []
      ),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] ?? 0,
      attributes: json['attributes'],
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
      'umkm_id': umkmId,
      'name': name,
      'description': description,
      'price': price,
      'recommended_price': recommendedPrice,
      'stock': stock,
      'category': category,
      'images': images,
      'rating': rating,
      'review_count': reviewCount,
      'attributes': attributes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  List<Object?> get props => [
    id,
    umkmId,
    name,
    description,
    price,
    recommendedPrice,
    stock,
    category,
    images,
    rating,
    reviewCount,
    attributes,
    isActive,
    createdAt,
    updatedAt,
  ];
}

class ProductFilter {
  final String? searchQuery;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final double radius;
  final int? sortBy; // 0=rating, 1=price_low, 2=price_high, 3=newest

  const ProductFilter({
    this.searchQuery,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.radius = 5.0,
    this.sortBy,
  });

  ProductFilter copyWith({
    String? searchQuery,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? radius,
    int? sortBy,
  }) {
    return ProductFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      radius: radius ?? this.radius,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  List<Object?> get props =>
      [searchQuery, category, minPrice, maxPrice, minRating, radius, sortBy];
}
