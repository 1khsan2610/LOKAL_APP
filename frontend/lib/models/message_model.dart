class MessageModel {
  final int id;
  final int chatId;
  final int senderId;
  final String messageContent;
  final String status; // sent, delivered, read
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? sender;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.messageContent,
    this.status = 'sent',
    required this.createdAt,
    required this.updatedAt,
    this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      chatId: json['chat_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      messageContent: json['message_content'] ?? '',
      status: json['status'] ?? 'sent',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      sender: json['sender'],
    );
  }

  Map<String, dynamic> toJson() => {
    'chat_id': chatId,
    'sender_id': senderId,
    'message_content': messageContent,
    'status': status,
  };

  bool get isRead => status == 'read';
  bool get isDelivered => status == 'delivered' || status == 'read';

  String get senderName => sender?['name'] ?? 'Unknown';
  String? get senderAvatar => sender?['avatar'];
}