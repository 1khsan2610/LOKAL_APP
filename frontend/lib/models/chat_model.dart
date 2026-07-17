class ChatModel {
  final int id;
  final int senderId;
  final int receiverId;
  final int? productId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? receiver;
  final Map<String, dynamic>? product;
  final Map<String, dynamic>? otherUser;

  ChatModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.productId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.receiver,
    this.product,
    this.otherUser,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      productId: json['product_id'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      sender: json['sender'],
      receiver: json['receiver'],
      product: json['product'],
      otherUser: json['other_user'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    'receiver_id': receiverId,
    'product_id': productId,
    'last_message': lastMessage,
    'last_message_at': lastMessageAt?.toIso8601String(),
    'unread_count': unreadCount,
  };

  String get otherUserName => otherUser?['name'] ?? 'Unknown';
  String? get otherUserAvatar => otherUser?['avatar'];
  String get productName => product?['name'] ?? '';
}