enum UserRole { consumer, umkm, producer }

class User {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? avatar;
  final UserRole role;
  final bool isVerified;
  final String? address;
  final String? city;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.avatar,
    required this.role,
    required this.isVerified,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    String? avatar,
    UserRole? role,
    bool? isVerified,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? '').toString(),
      phone: (json['phone'] ?? json['phone_number'] ?? '').toString(),
      name: json['name'] != null ? json['name'].toString() : null,
      email: json['email'] != null ? json['email'].toString() : null,
      avatar: json['avatar'] != null ? json['avatar'].toString() : null,
      role: _parseRole(json['role']),
      isVerified: json['is_verified'] ?? false,
      address: json['address'] != null ? json['address'].toString() : null,
      city: json['city'] != null ? json['city'].toString() : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role.toString().split('.').last,
      'is_verified': isVerified,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static UserRole _parseRole(dynamic roleValue) {
    if (roleValue is String) {
      switch (roleValue.toLowerCase()) {
        case 'umkm':
          return UserRole.umkm;
        case 'producer':
          return UserRole.producer;
        default:
          return UserRole.consumer;
      }
    }
    return UserRole.consumer;
  }

}

class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] ?? {}),
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ??
          DateTime.now().add(const Duration(hours: 24)),
    );
  }

  List<Object?> get props => [user, accessToken, refreshToken, expiresAt];
}
