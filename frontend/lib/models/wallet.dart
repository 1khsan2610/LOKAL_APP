enum CoinTransactionType {
  reward,
  usage,
  review,
  bonus,
  expiry,
}

class Wallet {
  final String userId;
  final double coinBalance;
  final double coinExpiring30Days;
  final DateTime lastUpdated;
  final List<CoinTransaction> recentTransactions;

  const Wallet({
    required this.userId,
    required this.coinBalance,
    required this.coinExpiring30Days,
    required this.lastUpdated,
    required this.recentTransactions,
  });

  Wallet copyWith({
    String? userId,
    double? coinBalance,
    double? coinExpiring30Days,
    DateTime? lastUpdated,
    List<CoinTransaction>? recentTransactions,
  }) {
    return Wallet(
      userId: userId ?? this.userId,
      coinBalance: coinBalance ?? this.coinBalance,
      coinExpiring30Days: coinExpiring30Days ?? this.coinExpiring30Days,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      userId: (json['user_id'] ?? '').toString(),
      coinBalance: (json['coin_balance'] as num?)?.toDouble() ?? 0,
      coinExpiring30Days:
          (json['coin_expiring_30_days'] as num?)?.toDouble() ?? 0,
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? '') ??
          DateTime.now(),
      recentTransactions: List<CoinTransaction>.from(
        (json['recent_transactions'] as List?)?.map(
              (x) => CoinTransaction.fromJson(x),
            ) ??
            [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'coin_balance': coinBalance,
      'coin_expiring_30_days': coinExpiring30Days,
      'last_updated': lastUpdated.toIso8601String(),
      'recent_transactions':
          recentTransactions.map((x) => x.toJson()).toList(),
    };
  }

  List<Object?> get props => [
    userId,
    coinBalance,
    coinExpiring30Days,
    lastUpdated,
    recentTransactions,
  ];
}

class CoinTransaction {
  final String id;
  final String userId;
  final CoinTransactionType type;
  final double amount;
  final String? description;
  final String? referenceId; // orderId atau reviewId
  final DateTime expiresAt;
  final DateTime createdAt;

  const CoinTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.description,
    this.referenceId,
    required this.expiresAt,
    required this.createdAt,
  });

  CoinTransaction copyWith({
    String? id,
    String? userId,
    CoinTransactionType? type,
    double? amount,
    String? description,
    String? referenceId,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return CoinTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      referenceId: referenceId ?? this.referenceId,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isExpiring {
    final now = DateTime.now();
    final daysUntilExpiry = expiresAt.difference(now).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  String get typeLabel {
    switch (type) {
      case CoinTransactionType.reward:
        return 'Reward Transaksi';
      case CoinTransactionType.usage:
        return 'Penggunaan Koin';
      case CoinTransactionType.review:
        return 'Reward Ulasan';
      case CoinTransactionType.bonus:
        return 'Bonus Pengguna Baru';
      case CoinTransactionType.expiry:
        return 'Koin Kadaluwarsa';
    }
  }

  String get typeIcon {
    switch (type) {
      case CoinTransactionType.reward:
        return '💰';
      case CoinTransactionType.usage:
        return '💸';
      case CoinTransactionType.review:
        return '⭐';
      case CoinTransactionType.bonus:
        return '🎁';
      case CoinTransactionType.expiry:
        return '⏰';
    }
  }

  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    return CoinTransaction(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      type: _parseType(json['type']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description'] != null ? json['description'].toString() : null,
      referenceId: json['reference_id'] != null ? json['reference_id'].toString() : null,
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ??
          DateTime.now().add(const Duration(days: 180)),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'description': description,
      'reference_id': referenceId,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  static CoinTransactionType _parseType(dynamic typeValue) {
    if (typeValue is String) {
      switch (typeValue.toLowerCase()) {
        case 'reward':
          return CoinTransactionType.reward;
        case 'usage':
          return CoinTransactionType.usage;
        case 'review':
          return CoinTransactionType.review;
        case 'bonus':
          return CoinTransactionType.bonus;
        case 'expiry':
          return CoinTransactionType.expiry;
      }
    }
    return CoinTransactionType.reward;
  }

  List<Object?> get props =>
      [id, userId, type, amount, description, referenceId, expiresAt, createdAt];
}
