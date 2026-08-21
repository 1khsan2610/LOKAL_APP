import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _showSidebar = true;

  // Daftar chat sidebar
  final List<Map<String, dynamic>> _recentChats = [
    {'title': 'Status pesanan Bakso Aci', 'preview': 'Pesanan sedang dalam perjalanan...', 'time': '10 menit'},
    {'title': 'Rekomendasi oleh-oleh', 'preview': 'Coba Tahu Susu Lembang...', 'time': '1 jam'},
    {'title': 'Cara pakai Lokal Coin', 'preview': 'Lokal Coin bisa digunakan...', 'time': '3 jam'},
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(sender: 'user', text: text));
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final response = await _apiService.aiChat(text);
      final data = response.data;

      if (data['success'] == true && data['response'] != null) {
        setState(() {
          _messages.add(ChatMessage(sender: 'ai', text: data['response']));
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(
            sender: 'ai',
            text: 'Maaf, saya sedang sibuk. Coba tanya lagi nanti ya! 😊',
            isError: true,
          ));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          sender: 'ai',
          text: 'Maaf, koneksi terputus. Silakan coba lagi.',
          isError: true,
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asisten Lokal AI',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Online',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (isDesktop)
            IconButton(
              icon: Icon(
                _showSidebar ? Icons.pan_tool_alt_outlined : Icons.chat_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _showSidebar = !_showSidebar),
              tooltip: 'Toggle Sidebar',
            ),
        ],
      ),
      body: isDesktop && _showSidebar
          ? Row(
              children: [
                // ── SIDEBAR ─────────────────────────────────────────
                SizedBox(
                  width: 280,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(color: AppTheme.border),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header sidebar
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface2,
                            border: Border(
                              bottom: BorderSide(color: AppTheme.border),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Percakapan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _messages.clear();
                                    });
                                  },
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  tooltip: 'Chat Baru',
                                ),
                              ),
                            ],
                          ),
                        ),
                        // List chat
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _recentChats.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                            itemBuilder: (_, i) {
                              final chat = _recentChats[i];
                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                                  child: const Icon(Icons.chat_outlined, size: 16, color: AppTheme.primary),
                                ),
                                title: Text(
                                  chat['title'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  chat['preview'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                                ),
                                trailing: Text(
                                  chat['time'],
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textHint),
                                ),
                                onTap: () {},
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── VERTICAL DIVIDER ────────────────────────────────
                const VerticalDivider(width: 1),
                // ── MAIN CHAT AREA ──────────────────────────────────
                Expanded(child: _buildChatArea()),
              ],
            )
          : _buildChatArea(),
    );
  }

  Widget _buildChatArea() {
    return Column(
      children: [
        // ── Chat Messages ─────────────────────────────────────────
        Expanded(
          child: _messages.isEmpty && !_isLoading
              ? _buildWelcomeWithSuggestions()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoading && index == _messages.length) {
                      return _buildTypingIndicator();
                    }

                    final msg = _messages[index];
                    return _buildChatBubble(msg);
                  },
                ),
        ),

        // ── Quick Suggestion Pills ─────────────────────────────────
        if (_messages.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _suggestionChip('📦 Tanya status pesanan', () {
                    _textController.text = 'Tanya status pesanan';
                    _sendMessage();
                  }),
                  const SizedBox(width: 8),
                  _suggestionChip('📍 Rekomendasi UMKM terdekat', () {
                    _textController.text = 'Rekomendasi UMKM terdekat';
                    _sendMessage();
                  }),
                  const SizedBox(width: 8),
                  _suggestionChip('🪙 Cara pakai Lokal Coin', () {
                    _textController.text = 'Cara pakai Lokal Coin';
                    _sendMessage();
                  }),
                  const SizedBox(width: 8),
                  _suggestionChip('💬 Bantuan Lainnya', () {
                    _textController.text = 'Bantuan Lainnya';
                    _sendMessage();
                  }),
                ],
              ),
            ),
          ),

        // ── Input Bar ─────────────────────────────────────────────
        _buildInputBar(),
      ],
    );
  }

  Widget _suggestionChip(String label, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

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
            children: [
              // Lampiran icon
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface2,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: IconButton(
                  icon: const Icon(Icons.attach_file_rounded, size: 20, color: AppTheme.textHint),
                  onPressed: () {},
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 6),
              // Text field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: AppTheme.bg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
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
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: _isLoading
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

  // ── Chat Bubble Modern ──────────────────────────────────────────
  Widget _buildChatBubble(ChatMessage msg) {
    final isUser = msg.sender == 'user';
    final isError = msg.isError;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar('L', AppTheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.primary
                    : (isError ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (isError ? AppTheme.danger : AppTheme.textPrimary),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    softWrap: true,
                  ),
                  // Order integration card (contoh untuk AI response)
                  if (!isUser && msg.text.contains('pesanan'))
                    const SizedBox(height: 12),
                  if (!isUser && msg.text.contains('pesanan'))
                    _buildOrderStatusCard(),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  // ── Order Status Card (Integrasi di dalam Chat) ─────────────────
  Widget _buildOrderStatusCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surface2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/bakso-aci.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 24, color: AppTheme.textHint),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bakso Aci Spesial',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Bu Sari - Bakso Aci Spesial',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Rp 25.000',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Lacak button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Lacak Pesanan',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String letter, Color bgColor) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: bgColor,
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Welcome Screen ──────────────────────────────────────────────
  Widget _buildWelcomeWithSuggestions() {
    final suggestions = [
      'Tanya status pesanan',
      'Rekomendasi UMKM terdekat',
      'Cara pakai Lokal Coin',
      'Bantuan Lainnya',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primary,
            child: const Text(
              'L',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Halo! Ada yang bisa saya bantu?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Saya LOKAL AI Assistant, asisten ramah untuk\nmembantu belanja & bisnis UMKM lokal kamu!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Coba tanyakan:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...suggestions.map((text) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                _textController.text = text;
                _sendMessage();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Text('💬', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textHint),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ── Typing Indicator ────────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar('L', AppTheme.primary),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(AppTheme.textHint),
                const SizedBox(width: 4),
                _dot(AppTheme.textHint),
                const SizedBox(width: 4),
                _dot(AppTheme.textHint),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String text;
  final bool isError;

  ChatMessage({
    required this.sender,
    required this.text,
    this.isError = false,
  });
}