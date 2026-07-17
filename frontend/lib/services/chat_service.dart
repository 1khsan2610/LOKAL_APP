import 'package:dio/dio.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'api_service.dart';

class ChatService {
  final ApiService _api = ApiService();

  /// 🔹 GET /chat — Ambil daftar chat milik user
  Future<Map<String, dynamic>> getChats({int page = 1}) async {
    try {
      final response = await _api.dio.get('/chat', queryParameters: {'page': page});
      final data = response.data;
      if (data['success'] == true) {
        final List<ChatModel> chats = (data['data'] as List)
            .map((e) => ChatModel.fromJson(e))
            .toList();
        return {
          'chats': chats,
          'meta': data['meta'] ?? {},
        };
      }
      throw Exception(data['message'] ?? 'Gagal memuat chat');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 🔹 GET /chat/{id} — Ambil detail chat + semua pesan
  Future<Map<String, dynamic>> getChatDetail(int chatId) async {
    try {
      final response = await _api.dio.get('/chat/$chatId');
      final data = response.data;
      if (data['success'] == true) {
        final chatData = data['data'];
        final ChatModel chat = ChatModel.fromJson(chatData['chat']);
        final List<MessageModel> messages = (chatData['messages'] as List)
            .map((e) => MessageModel.fromJson(e))
            .toList();
        final Map<String, dynamic>? otherUser = chatData['other_user'];
        return {
          'chat': chat,
          'messages': messages,
          'other_user': otherUser,
        };
      }
      throw Exception(data['message'] ?? 'Gagal memuat pesan');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 🔹 POST /chat/send — Kirim pesan baru
  Future<Map<String, dynamic>> sendMessage({
    required int receiverId,
    required String message,
    int? productId,
    int? chatId,
  }) async {
    try {
      final response = await _api.dio.post('/chat/send', data: {
        'receiver_id': receiverId,
        'message': message,
        if (productId != null) 'product_id': productId,
        if (chatId != null) 'chat_id': chatId,
      });
      final data = response.data;
      if (data['success'] == true) {
        final MessageModel messageModel =
            MessageModel.fromJson(data['data']['message']);
        final ChatModel chat = ChatModel.fromJson(data['data']['chat']);
        return {
          'message': messageModel,
          'chat': chat,
        };
      }
      throw Exception(data['message'] ?? 'Gagal mengirim pesan');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 🔹 POST /chat/start-from-product — Mulai chat dari halaman produk
  Future<ChatModel> startFromProduct(int productId) async {
    try {
      final response = await _api.dio.post('/chat/start-from-product', data: {
        'product_id': productId,
      });
      final data = response.data;
      if (data['success'] == true) {
        return ChatModel.fromJson(data['data']['chat']);
      }
      throw Exception(data['message'] ?? 'Gagal memulai chat');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 🔹 PATCH /chat/{id}/mark-read — Tandai semua pesan sudah dibaca
  Future<void> markAsRead(int chatId) async {
    try {
      await _api.dio.patch('/chat/$chatId/mark-read');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 🔹 GET /chat/unread-count — Hitung total unread
  Future<int> getUnreadCount() async {
    try {
      final response = await _api.dio.get('/chat/unread-count');
      final data = response.data;
      if (data['success'] == true) {
        return data['data']['total_unread'] ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// ✏️ Helper: parse error dari Dio
  String _handleError(DioException e) {
    if (e.response != null) {
      final msg = e.response?.data?['message'];
      if (msg != null) return msg.toString();
      return 'Server error: ${e.response?.statusCode}';
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Koneksi timeout. Periksa jaringan Anda.';
    }
    return 'Terjadi kesalahan jaringan.';
  }
}