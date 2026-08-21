import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/mobile_frame.dart';

/// Halaman Chat Real-time antara konsumen dan UMKM.
///
/// Fitur:
/// - Kirim dan terima pesan
/// - Status pesan (sent/delivered/read) dengan ikon centang
/// - Input field otomatis naik saat keyboard muncul (tidak overflow)
/// - SafeArea + padding bawah untuk gesture navigation
/// - Responsif untuk semua ukuran layar
class ChatScreen extends StatefulWidget {
  final ChatModel? chat;
  final int? initialChatId;
  final int? receiverId;
  final String? receiverName;
  final String? receiverAvatar;
  final int? productId;

  const ChatScreen({
    super.key,
    this.chat,
    this.initialChatId,
    this.receiverId,
    this.receiverName,
    this.receiverAvatar,
    this.productId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> _messages = [];
  ChatModel? _chat;
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  int _currentUserId = 0;

  int? _chatId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Inisialisasi: ambil data user & muat pesan
  Future<void> _initChat() async {
    try {
      // Ambil user ID dari AuthProvider yang sudah ada
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _currentUserId = user.id;
      }

      // Jika ada chat yang sudah di-pass, langsung muat pesan
      if (widget.chat != null) {
        setState(() {
          _chat = widget.chat;
          _chatId = _chat!.id;
        });
        await _loadMessages();
      } else if (widget.initialChatId != null) {
        // Muat chat berdasarkan ID
        _chatId = widget.initialChatId;
        await _loadMessages();
      } else {
        // Chat baru (belum ada percakapan sebelumnya)
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Load semua pesan dari server
  Future<void> _loadMessages() async {
    if (_chatId == null) return;

    try {
      setState(() => _isLoading = true);

      final result = await _chatService.getChatDetail(_chatId!);
      setState(() {
        _chat = result['chat'] as ChatModel;
        _messages = result['messages'] as List<MessageModel>;
        _isLoading = false;
        _error = null;
      });

      // Scroll ke pesan terbaru
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Kirim pesan
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      Map<String, dynamic> result;

      if (_chatId != null) {
        // Chat sudah ada, tentukan receiver_id dari chat
        final receiverId = widget.receiverId ??
            _chat!.receiverId;
        // Pastikan receiver_id bukan diri sendiri
        final targetReceiver = receiverId == _currentUserId
            ? _chat!.senderId
            : receiverId;

        result = await _chatService.sendMessage(
          receiverId: targetReceiver,
          message: text,
          chatId: _chatId,
        );
      } else {
        // Chat baru, kirim dengan receiver_id
        final targetReceiver = widget.receiverId ??
            widget.chat?.receiverId ??
            0;

        result = await _chatService.sendMessage(
          receiverId: targetReceiver,
          message: text,
          productId: widget.productId,
        );
      }

      final newMessage = result['message'] as MessageModel;
      final updatedChat = result['chat'] as ChatModel;

      setState(() {
        _messages.add(newMessage);
        _chat = updatedChat;
        _chatId = updatedChat.id;
        _isSending = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  /// Scroll ke pesan paling bawah
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Format tanggal untuk pemisah (seperti "Hari ini", "Kemarin", atau tanggal)
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) return 'Hari ini';
    if (messageDate == today.subtract(const Duration(days: 1))) return 'Kemarin';
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Determine the OTHER person's name (NOT the current user)
    // Priority: explicit receiverName > chat.otherUserName > computed from sender/receiver
    final screen = _buildScreen(context);
    return MobileFrame(child: screen);
  }

  Widget _buildScreen(BuildContext context) {
    // Determine the OTHER person's name (NOT the current user)
    // Priority: explicit receiverName > chat.otherUserName > computed from sender/receiver
    String otherName = widget.receiverName?.isNotEmpty == true
        ? widget.receiverName!
        : 'Chat';
    
    if (_chat != null) {
      // Explicitly compute: if currentUserId == senderId, other = receiver
      // if currentUserId == receiverId, other = sender
      if (_currentUserId == _chat!.senderId) {
        // Current user is sender, so other is receiver
        if (_chat?.receiver?['name'] != null && (_chat!.receiver!['name'] as String).isNotEmpty) {
          otherName = _chat!.receiver!['name'];
        } else if (_chat?.receiver?['shop_name'] != null && (_chat!.receiver!['shop_name'] as String).isNotEmpty) {
          otherName = _chat!.receiver!['shop_name'];
        } else if (_chat?.otherUserName.isNotEmpty == true) {
          otherName = _chat!.otherUserName;
        }
      } else {
        // Current user is receiver, so other is sender
        if (_chat?.sender?['name'] != null && (_chat!.sender!['name'] as String).isNotEmpty) {
          otherName = _chat!.sender!['name'];
        } else if (_chat?.sender?['shop_name'] != null && (_chat!.sender!['shop_name'] as String).isNotEmpty) {
          otherName = _chat!.sender!['shop_name'];
        } else if (_chat?.otherUserName.isNotEmpty == true) {
          otherName = _chat!.otherUserName;
        }
      }
    }
    
    // Fallback to widget receiverName if still default
    if (otherName == 'Chat' && widget.receiverName?.isNotEmpty == true) {
      otherName = widget.receiverName!;
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Row(
          children: [
            // Avatar lawan bicara di AppBar
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              backgroundImage: (_chat?.otherUserAvatar ?? widget.receiverAvatar) != null
                  ? NetworkImage(_chat?.otherUserAvatar ?? widget.receiverAvatar!)
                  : null,
              child: (_chat?.otherUserAvatar ?? widget.receiverAvatar) == null
                  ? Text(
                      otherName[0].toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (_chat?.productName != null &&
                      _chat!.productName.isNotEmpty)
                    Text(
                      'Pesan tentang ${_chat!.productName}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Tombol refresh (manual polling)
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadMessages,
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SafeArea(
            child: Column(
              children: [
                // ── Daftar Pesan ──────────────────────────────────────
                Expanded(
                  child: _buildMessageList(),
                ),

                // ── Input Field ───────────────────────────────────────
                _buildInputBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Daftar pesan dengan loading, error, atau empty state
  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primary,
          strokeWidth: 2.5,
        ),
      );
    }

    if (_error != null && _messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.textHint,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadMessages,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppTheme.textHint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada pesan',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kirim pesan pertama Anda',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textHint,
              ),
            ),
          ],
        ),
      );
    }

    // Gunakan ListView.builder untuk performa, dengan pemisah tanggal
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.senderId == _currentUserId;

        // Tampilkan pemisah tanggal jika tanggal berbeda dengan pesan sebelumnya
        Widget dateSeparator = const SizedBox.shrink();
        if (index == 0 ||
            _messages[index - 1].createdAt.day != message.createdAt.day) {
          dateSeparator = Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatDate(message.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            dateSeparator,
            MessageBubble(
              message: message.messageContent,
              timestamp: message.createdAt,
              isMe: isMe,
              status: isMe ? message.status : 'sent',
              senderName: !isMe ? message.senderName : null,
              senderAvatar: !isMe ? message.senderAvatar : null,
            ),
          ],
        );
      },
    );
  }

  /// Input bar dengan text field dan tombol kirim.
  /// 
  /// Menggunakan MediaQuery.viewInsetsOf untuk menangani keyboard
  /// tanpa menyebabkan overflow.
  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 8,
            bottom: MediaQuery.viewInsetsOf(context).bottom > 0 ? 12 : 8,
            top: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Text field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 120, // Maks 4 baris
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.bg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: SingleChildScrollView(
                    controller: ScrollController(),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null, // Multi-line
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        hintStyle: TextStyle(
                          color: AppTheme.textHint,
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Tombol kirim
              Container(
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _isSending ? null : _sendMessage,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                  constraints: const BoxConstraints(
                    minWidth: 42,
                    minHeight: 42,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}