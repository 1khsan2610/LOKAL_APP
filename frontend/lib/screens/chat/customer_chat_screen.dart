import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/chat_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/mobile_frame.dart';

/// Halaman Chat Konsumen — tampilan chat dari sisi pembeli
/// dengan header toko, product card attachment, dan input bar lengkap.
class CustomerChatScreen extends StatefulWidget {
  final ChatModel? chat;
  final int? initialChatId;
  final int? receiverId;
  final String? receiverName;
  final String? receiverAvatar;
  final String? storeName;
  final String? storeLogo;
  final int? productId;
  final ProductModel? product;

  const CustomerChatScreen({
    super.key,
    this.chat,
    this.initialChatId,
    this.receiverId,
    this.receiverName,
    this.receiverAvatar,
    this.storeName,
    this.storeLogo,
    this.productId,
    this.product,
  });

  @override
  State<CustomerChatScreen> createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
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

  // Product card shown in chat
  ProductModel? _attachedProduct;

  @override
  void initState() {
    super.initState();
    _attachedProduct = widget.product;
    _initChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    try {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _currentUserId = user.id;
      }

      if (widget.chat != null) {
        setState(() {
          _chat = widget.chat;
          _chatId = _chat!.id;
        });
        await _loadMessages();
      } else if (widget.initialChatId != null) {
        _chatId = widget.initialChatId;
        await _loadMessages();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      Map<String, dynamic> result;

      if (_chatId != null) {
        final receiverId = widget.receiverId ??
            _chat!.receiverId;
        final targetReceiver = receiverId == _currentUserId
            ? _chat!.senderId
            : receiverId;

        result = await _chatService.sendMessage(
          receiverId: targetReceiver,
          message: text,
          chatId: _chatId,
        );
      } else {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) return 'Hari ini';
    if (messageDate == today.subtract(const Duration(days: 1))) return 'Kemarin';
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Add product to cart via CartProvider
  Future<void> _addToCart(ProductModel product) async {
    final cartProvider = context.read<CartProvider>();
    final success = await cartProvider.addItem(product.id, 1);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '${product.name} ditambahkan ke keranjang'
                : 'Gagal menambahkan ke keranjang',
          ),
          backgroundColor: success ? AppTheme.success : AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileFrame(child: _buildScreen(context));
  }

  Widget _buildScreen(BuildContext context) {
    // Determine store name
    String storeName = widget.storeName?.isNotEmpty == true
        ? widget.storeName!
        : 'Warung Bu Sari';

    if (_chat != null) {
      if (_currentUserId == _chat!.senderId) {
        if (_chat?.receiver?['shop_name'] != null &&
            (_chat!.receiver!['shop_name'] as String).isNotEmpty) {
          storeName = _chat!.receiver!['shop_name'];
        } else if (_chat?.receiver?['name'] != null &&
            (_chat!.receiver!['name'] as String).isNotEmpty) {
          storeName = _chat!.receiver!['name'];
        }
      } else {
        if (_chat?.sender?['shop_name'] != null &&
            (_chat!.sender!['shop_name'] as String).isNotEmpty) {
          storeName = _chat!.sender!['shop_name'];
        } else if (_chat?.sender?['name'] != null &&
            (_chat!.sender!['name'] as String).isNotEmpty) {
          storeName = _chat!.sender!['name'];
        }
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0.5,
        scrolledUnderElevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            // Store Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.surface2,
              backgroundImage: (widget.storeLogo ?? _chat?.otherUserAvatar) != null
                  ? NetworkImage(widget.storeLogo ?? _chat!.otherUserAvatar!)
                  : null,
              child: (widget.storeLogo ?? _chat?.otherUserAvatar) == null
                  ? Text(
                      storeName[0].toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            // Store Name + Online Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Online',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Kunjungi Toko Button
            OutlinedButton(
              onPressed: () {
                // Navigate to store profile
                context.push('/umkm/dashboard');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Kunjungi Toko'),
            ),
            const SizedBox(width: 4),
            // Help Icon
            IconButton(
              icon: const Icon(Icons.help_outline, size: 20),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            // Kebab Menu
            IconButton(
              icon: const Icon(Icons.more_vert, size: 20),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SafeArea(
            child: Column(
              children: [
                // ── Message List ──────────────────────────────────────
                Expanded(
                  child: _buildMessageList(),
                ),
                // ── Product Card Attachment ───────────────────────────
                if (_attachedProduct != null)
                  _buildProductCard(_attachedProduct!),
                // ── Input Bar ─────────────────────────────────────────
                _buildInputBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Product card attachment displayed inside chat
  Widget _buildProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: product.primaryImage != null
                    ? Image.network(
                        product.primaryImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.surface2,
                          child: const Icon(
                            Icons.image_outlined,
                            color: AppTheme.textHint,
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.surface2,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppTheme.textHint,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(product.displayPrice)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Add to Cart Button
            ElevatedButton.icon(
              onPressed: () => _addToCart(product),
              icon: const Icon(Icons.shopping_cart_outlined, size: 16),
              label: Text(
                'Tambah ke Keranjang',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Message list with loading, error, empty states
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

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.senderId == _currentUserId;

        // Date separator
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
            // Seller bubble (left) — white soft background
            // Customer bubble (right) — blue primary background
            _buildChatBubble(message, isMe),
          ],
        );
      },
    );
  }

  /// Custom chat bubble with specific styling per spec
  Widget _buildChatBubble(MessageModel message, bool isMe) {
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final margin = isMe
        ? const EdgeInsets.only(left: 60, right: 12, top: 2, bottom: 2)
        : const EdgeInsets.only(left: 12, right: 60, top: 2, bottom: 2);

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF1D4ED8) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.messageContent,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: isMe ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                // Timestamp
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.createdAt),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: isMe
                            ? Colors.white70
                            : AppTheme.textHint,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.status == 'read'
                            ? Icons.done_all
                            : message.status == 'delivered'
                                ? Icons.done_all
                                : Icons.done,
                        size: 14,
                        color: message.status == 'read'
                            ? const Color(0xFF60A5FA)
                            : Colors.white70,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Footer input bar with image, file, emoji, text field, send button
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
            left: 8,
            right: 8,
            bottom: MediaQuery.viewInsetsOf(context).bottom > 0 ? 12 : 8,
            top: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Image attachment icon
              _iconButton(Icons.image_outlined, () {}),
              // File attachment icon
              _iconButton(Icons.attach_file_outlined, () {}),
              // Emoji icon
              _iconButton(Icons.emoji_emotions_outlined, () {}),
              const SizedBox(width: 4),
              // Text field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: AppTheme.bg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: SingleChildScrollView(
                    controller: ScrollController(),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan untuk Bu Sari...',
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
              // Send button
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

  Widget _iconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 22, color: AppTheme.textHint),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }
}