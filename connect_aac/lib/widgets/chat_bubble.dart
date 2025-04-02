// lib/widgets/chat_bubble.dart
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../utils/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onTapDelete;

  const ChatBubble({
    super.key,
    required this.message,
    this.onTapDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bubbleColor = isUser
        ? AppTheme.primaryColor
        : Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).cardColor
            : Colors.white;
    final textColor =
        isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color;

    final bubbleBorderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 5),
      bottomRight: Radius.circular(isUser ? 5 : 18),
    );

    final timeString = _formatTime(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI 아바타 (사용자 메시지에는 표시 안 함)
          if (!isUser) _buildAvatar(),

          const SizedBox(width: 8),

          // 메시지 본문
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 메시지 내용
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: bubbleBorderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 시간 및 액션
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isUser && onTapDelete != null)
                        GestureDetector(
                          onTap: onTapDelete,
                          child: Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      if (isUser && onTapDelete != null)
                        const SizedBox(width: 8),
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 사용자 아바타 (AI 메시지에는 표시 안 함)
          if (isUser) _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  // 아바타 위젯
  Widget _buildAvatar({bool isUser = false}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isUser
            ? AppTheme.accentColor.withOpacity(0.2)
            : AppTheme.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
        size: 20,
        color: isUser ? AppTheme.accentColor : AppTheme.primaryColor,
      ),
    );
  }

  // 시간 포맷팅
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String prefix = '';
    if (messageDate == today) {
      prefix = '오늘 ';
    } else if (messageDate == yesterday) {
      prefix = '어제 ';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$prefix$hour:$minute';
  }
}
