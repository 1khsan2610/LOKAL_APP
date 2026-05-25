enum NotificationType {
  orderConfirmed,
  orderShipped,
  orderDelivered,
  paymentSuccessful,
  paymentFailed,
  coinRewarded,
  lowStock,
  promotion,
  general,
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.imageUrl,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    String? imageUrl,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get typeLabel {
    switch (type) {
      case NotificationType.orderConfirmed:
        return 'Pesanan Dikonfirmasi';
      case NotificationType.orderShipped:
        return 'Pesanan Dikirim';
      case NotificationType.orderDelivered:
        return 'Pesanan Diterima';
      case NotificationType.paymentSuccessful:
        return 'Pembayaran Berhasil';
      case NotificationType.paymentFailed:
        return 'Pembayaran Gagal';
      case NotificationType.coinRewarded:
        return 'Koin Diterima';
      case NotificationType.lowStock:
        return 'Stok Menipis';
      case NotificationType.promotion:
        return 'Promosi';
      case NotificationType.general:
        return 'Pemberitahuan';
    }
  }

  String get typeIcon {
    switch (type) {
      case NotificationType.orderConfirmed:
        return '✅';
      case NotificationType.orderShipped:
        return '📦';
      case NotificationType.orderDelivered:
        return '🎉';
      case NotificationType.paymentSuccessful:
        return '💳';
      case NotificationType.paymentFailed:
        return '❌';
      case NotificationType.coinRewarded:
        return '💰';
      case NotificationType.lowStock:
        return '⚠️';
      case NotificationType.promotion:
        return '🎁';
      case NotificationType.general:
        return 'ℹ️';
    }
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      type: _parseType(json['type']),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      imageUrl: json['image_url'] != null ? json['image_url'].toString() : null,
      data: json['data'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'image_url': imageUrl,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static NotificationType _parseType(dynamic typeValue) {
    if (typeValue is String) {
      switch (typeValue.toLowerCase()) {
        case 'order_confirmed':
          return NotificationType.orderConfirmed;
        case 'order_shipped':
          return NotificationType.orderShipped;
        case 'order_delivered':
          return NotificationType.orderDelivered;
        case 'payment_successful':
          return NotificationType.paymentSuccessful;
        case 'payment_failed':
          return NotificationType.paymentFailed;
        case 'coin_rewarded':
          return NotificationType.coinRewarded;
        case 'low_stock':
          return NotificationType.lowStock;
        case 'promotion':
          return NotificationType.promotion;
        default:
          return NotificationType.general;
      }
    }
    return NotificationType.general;
  }

  List<Object?> get props =>
      [id, userId, type, title, message, imageUrl, data, isRead, createdAt];
}
