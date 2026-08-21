import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';

/// Merchant Chat / Pesan Masuk — 2-Pane Layout (Mobile: full screen)
class UmkmChatScreen extends StatefulWidget {
  const UmkmChatScreen({super.key});

  @override
  State<UmkmChatScreen> createState() => _UmkmChatScreenState();
}

class _UmkmChatScreenState extends State<UmkmChatScreen> {
  final _api = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _conversations = [];
  Map<String, dynamic>? _selectedConversation;
  List<Map<String, dynamic>> _messages = [];
  final _messageController = TextEditingController();
  bool _showMobileChat = false;
  bool _isSending = false;

  // Quick reply chips
  final _quickReplies = [
    'Stok ready kak, silakan dipesan 😊',
    'Terima kasih pesanannya! Akan segera kami proses',
    'Akan segera kami proses, ya',
    'Mohon ditunggu update status pesanannya',
    'Untuk informasi lebih lanjut, silakan hubungi kami',
  ];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _api.dio.get('/umkm/chats');
      setState(() {
        _conversations = (resp.data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectConversation(Map<String, dynamic> conv) async {
    setState(() {
      _selectedConversation = conv;
      _showMobileChat = true;
    });
    try {
      final chatId = conv['id'];
      final resp = await _api.dio.get('/umkm/chats/$chatId/messages');
      setState(() {
        _messages = (resp.data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      });
    } catch (_) {
      if (mounted) setState(() => _messages = []);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedConversation == null) return;

    setState(() => _isSending = true);
    try {
      final chatId = _selectedConversation!['id'];
      await _api.dio.post('/umkm/chats/$chatId/messages', data: {'message': text});

      // Reload messages
      final resp = await _api.dio.get('/umkm/chats/$chatId/messages');
      if (mounted) {
        setState(() {
          _messages = (resp.data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          _messageController.clear();
        });
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(context, 'Gagal mengirim pesan', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendQuickReply(String text) async {
    if (_selectedConversation == null) return;
    setState(() => _isSending = true);
    try {
      final chatId = _selectedConversation!['id'];
      await _api.dio.post('/umkm/chats/$chatId/messages', data: {'message': text});

      final resp = await _api.dio.get('/umkm/chats/$chatId/messages');
      if (mounted) {
        setState(() {
          _messages = (resp.data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        });
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(context, 'Gagal mengirim pesan', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _formatTime(dynamic dateStr) {
    try {
      final date = DateTime.parse(dateStr.toString());
      final now = DateTime.now();
      if (date.day == now.day && date.month == now.month && date.year == now.year) {
        return DateFormat('HH:mm').format(date);
      }
      return DateFormat('dd/MM').format(date);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    if (isMobile) {
      return _buildMobileView();
    }
    return _buildDesktopView();
  }

  Widget _buildDesktopView() {
    return Row(
      children: [
        // ── Left Pane: Conversation List ─────────────────────────
        SizedBox(
          width: 320,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: Column(
              children: [
                // Search
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari pelanggan...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppTheme.textHint),
                      filled: true,
                      fillColor: AppTheme.surface2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      const Text('Percakapan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const Spacer(),
                      Text('${_conversations.length}', style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                    ],
                  ),
                ),
                // List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                      : _conversations.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppTheme.textHint),
                                  SizedBox(height: 12),
                                  Text('Belum ada percakapan', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: _conversations.length,
                              itemBuilder: (_, i) => _buildConversationTile(_conversations[i]),
                            ),
                ),
              ],
            ),
          ),
        ),
        // ── Right Pane: Chat Room ────────────────────────────────
        Expanded(
          child: _selectedConversation == null
              ? Container(
                  color: AppTheme.bg,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppTheme.textHint),
                        SizedBox(height: 16),
                        Text('Pilih percakapan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                        SizedBox(height: 8),
                        Text('Pilih pelanggan dari daftar kiri', style: TextStyle(fontSize: 13, color: AppTheme.textHint)),
                      ],
                    ),
                  ),
                )
              : _buildChatRoom(),
        ),
      ],
    );
  }

  Widget _buildMobileView() {
    if (_showMobileChat && _selectedConversation != null) {
      return Column(
        children: [
          // Back button header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => setState(() => _showMobileChat = false),
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    (_selectedConversation!['user']?['name']?.toString() ?? '?').substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedConversation!['user']?['name'] ?? 'Pelanggan',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      Text('Online', style: TextStyle(fontSize: 10, color: AppTheme.success)),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.receipt_long_outlined, size: 16),
                  label: const Text('Detail Pesanan', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          Expanded(child: _buildChatRoom()),
        ],
      );
    }

    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari pelanggan...',
              hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textHint),
              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppTheme.textHint),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.cardBorder),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _conversations.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppTheme.textHint),
                          SizedBox(height: 12),
                          Text('Belum ada percakapan', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _conversations.length,
                      itemBuilder: (_, i) => _buildConversationTile(_conversations[i]),
                    ),
        ),
      ],
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conv) {
    final user = conv['user'] as Map<String, dynamic>?;
    final name = user?['name'] ?? 'Pelanggan';
    final lastMsg = conv['last_message']?.toString() ?? '';
    final unread = conv['unread_count'] as int? ?? 0;
    final timestamp = _formatTime(conv['last_message_at']);
    final isSelected = _selectedConversation?['id'] == conv['id'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected ? AppTheme.primary.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectConversation(conv),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                          ),
                          if (timestamp.isNotEmpty)
                            Text(timestamp, style: const TextStyle(fontSize: 10, color: AppTheme.textHint)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: unread > 0 ? AppTheme.textPrimary : AppTheme.textHint)),
                          ),
                          if (unread > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.danger,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('$unread', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatRoom() {
    final user = _selectedConversation!['user'] as Map<String, dynamic>?;
    final name = user?['name'] ?? 'Pelanggan';

    return Column(
      children: [
        // ── Chat Header ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        Container(width: 6, height: 6,
                          decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        const Text('Online', style: TextStyle(fontSize: 10, color: AppTheme.success)),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigate to order detail if available
                  final orderId = _selectedConversation!['order_id'];
                  if (orderId != null) {
                    context.push('/orders/detail/$orderId');
                  }
                },
                icon: const Icon(Icons.receipt_long_outlined, size: 16),
                label: const Text('Lihat Detail Pesanan', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.surface2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ],
          ),
        ),
        // ── Messages ─────────────────────────────────────────────
        Expanded(
          child: Container(
            color: AppTheme.bg,
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_outlined, size: 48, color: AppTheme.textHint),
                        SizedBox(height: 12),
                        Text('Belum ada pesan', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _buildMessageBubble(_messages[i]),
                  ),
          ),
        ),
        // ── Quick Reply Chips ────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickReplies.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ActionChip(
                    label: Text(_quickReplies[i], maxLines: 1,
                      style: const TextStyle(fontSize: 11, color: AppTheme.primary)),
                    onPressed: () => _sendQuickReply(_quickReplies[i]),
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.08),
                    side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2)),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Input Footer ─────────────────────────────────────────
        Container(
          padding: EdgeInsets.only(
            left: 12, right: 12, top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.cardBorder)),
          ),
          child: Row(
            children: [
              // Attachment button
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 22, color: AppTheme.textHint),
                onPressed: () {},
              ),
              // Text input
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textHint),
                    filled: true,
                    fillColor: AppTheme.surface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 13),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 4),
              // Emoji button
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined, size: 22, color: AppTheme.textHint),
                onPressed: () {},
              ),
              // Send button
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: _isSending
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                  onPressed: _isSending ? null : _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMerchant = msg['is_merchant'] == true || msg['sender_type'] == 'merchant';
    final text = msg['message']?.toString() ?? '';
    final timestamp = _formatTime(msg['created_at']);
    final attachment = msg['attachment'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isMerchant ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Attachment card product
          if (attachment != null && attachment['type'] == 'product')
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.surface2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image_outlined, size: 24, color: AppTheme.textHint),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(attachment['name'] ?? 'Produk', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      Text(attachment['price']?.toString() ?? 'Rp 0', style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w700)),
                      Text('Stok: ${attachment['stock'] ?? 0}', style: const TextStyle(fontSize: 10, color: AppTheme.textHint)),
                    ],
                  ),
                ],
              ),
            ),

          // Attachment order summary card
          if (attachment != null && attachment['type'] == 'order_summary')
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      const Text('Ringkasan Pesanan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (attachment['items'] != null)
                    ...(attachment['items'] as List).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item['name'] ?? 'Item', style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 8),
                          Text('x${item['qty'] ?? 1}', style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                          const Spacer(),
                          Text(item['price']?.toString() ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                  const Divider(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(attachment['total']?.toString() ?? 'Rp 0', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Kirim Tagihan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),

          // Text bubble
          if (text.isNotEmpty)
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMerchant ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMerchant ? 16 : 4),
                  bottomRight: Radius.circular(isMerchant ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(text, style: TextStyle(fontSize: 13, color: isMerchant ? Colors.white : AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(timestamp, style: TextStyle(fontSize: 9, color: isMerchant ? Colors.white70 : AppTheme.textHint)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}