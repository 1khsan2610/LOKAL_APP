import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';

/// Reusable widget untuk menampilkan bubble chat.
/// 
/// Menggunakan design system:
/// - Navy #151B26 untuk bubble milik sendiri
/// - Surface putih untuk bubble lawan bicara
/// - Background #F8FAFC
class MessageBubble extends StatelessWidget {
  final String message;
  final DateTime timestamp;
  final bool isMe; // true = pesan dari user sendiri
  final String status; // sent, delivered, read
  final String? senderName; // nama pengirim (untuk bubble lawan)
  final String? senderAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.status = 'sent',
    this.senderName,
    this.senderAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 60 : 12,
        right: isMe ? 12 : 60,
        top: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Nama sender (untuk bubble lawan)
          if (!isMe && senderName != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                senderName!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          // Bubble utama
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar lawan bicara
              if (!isMe) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.surface2,
                  backgroundImage: senderAvatar != null
                      ? NetworkImage(senderAvatar!)
                      : null,
                  child: senderAvatar == null
                      ? Text(
                          (senderName ?? '?')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 6),
              ],
              // Bubble chat
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(
                        isMe ? 18 : 4,
                      ),
                      bottomRight: Radius.circular(
                        isMe ? 4 : 18,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Teks pesan
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: isMe ? Colors.white : AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Timestamp + status
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: isMe
                                    ? Colors.white.withValues(alpha: 0.7)
                                  : AppTheme.textHint,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            // Ikon status (centang)
                            _buildStatusIcon(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Ikon status pesan (centang 1 = sent, centang 2 = delivered, centang 2 biru = read)
  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (status) {
      case 'read':
        icon = Icons.done_all;
        color = const Color(0xFF4FC3F7); // Biru terang = sudah dibaca
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = Colors.white.withValues(alpha: 0.7);
        break;
      default: // sent
        icon = Icons.done;
        color = Colors.white.withValues(alpha: 0.7);
        break;
    }

    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }
}