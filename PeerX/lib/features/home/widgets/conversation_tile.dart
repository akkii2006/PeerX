import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/db/database.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/relay/relay_service.dart';
import '../../chat/chat_screen.dart';

class ConversationTile extends StatelessWidget {
  final Contact contact;
  const ConversationTile({super.key, required this.contact});

  String get _displayName {
    if (contact.nickname != null && contact.nickname!.isNotEmpty) {
      return contact.nickname!;
    }
    return contact.deviceId.substring(0, 8).toUpperCase();
  }

  String get _avatarInitial {
    return _displayName[0].toUpperCase();
  }

  Color _avatarColor() {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00BCD4),
      const Color(0xFF4CAF50),
      const Color(0xFFFF5722),
      const Color(0xFF9C27B0),
      const Color(0xFFFF9800),
    ];
    final index = contact.deviceId.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Message?>(
      future:  database.messagesDao.getLastMessage(contact.deviceId),
      builder: (context, msgSnap) {
        final lastMsg  = msgSnap.data;
        final preview  = lastMsg?.plaintext ?? 'No messages yet';
        final time     = lastMsg != null
            ? _formatTime(lastMsg.sentAt)
            : '';

        return FutureBuilder<int>(
          future:  database.messagesDao.getUnreadCount(contact.deviceId),
          builder: (context, unreadSnap) {
            final unread = unreadSnap.data ?? 0;

            return Material(
              color:        Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child:        InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap:        () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(contact: contact),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  child:   Row(
                    children: [
                      // Avatar with online indicator
                      Stack(
                        children: [
                          Container(
                            width:      52,
                            height:     52,
                            decoration: BoxDecoration(
                              color:        _avatarColor().withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                _avatarInitial,
                                style: TextStyle(
                                  fontSize:   20,
                                  fontWeight: FontWeight.w700,
                                  color:      _avatarColor(),
                                ),
                              ),
                            ),
                          ),
                          // Online dot
                          StreamBuilder<PresenceEvent>(
                            stream: RelayService().onPresence.where(
                                  (e) => e.peerId == contact.deviceId,
                            ),
                            builder: (context, snap) {
                              final online = snap.data?.online ?? false;
                              if (!online) return const SizedBox.shrink();
                              return Positioned(
                                right:  2,
                                bottom: 2,
                                child:  Container(
                                  width:      10,
                                  height:     10,
                                  decoration: BoxDecoration(
                                    color:        AppTheme.online,
                                    shape:        BoxShape.circle,
                                    border:       Border.all(color: Colors.black, width: 2),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(width: 14),

                      // Name + preview
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _displayName,
                                    style: const TextStyle(
                                      fontSize:   16,
                                      fontWeight: FontWeight.w600,
                                      color:      Colors.white,
                                    ),
                                    maxLines:  1,
                                    overflow:  TextOverflow.ellipsis,
                                  ),
                                ),
                                if (time.isNotEmpty)
                                  Text(
                                    time,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color:    AppTheme.textMuted,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    preview,
                                    style: TextStyle(
                                      fontSize:   13,
                                      color:      unread > 0
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      fontWeight: unread > 0
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                    maxLines:  1,
                                    overflow:  TextOverflow.ellipsis,
                                  ),
                                ),
                                if (unread > 0)
                                  Container(
                                    padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:        AppTheme.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      unread > 99 ? '99+' : '$unread',
                                      style: const TextStyle(
                                        fontSize:   11,
                                        fontWeight: FontWeight.w700,
                                        color:      Colors.white,
                                      ),
                                    ),
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
            );
          },
        );
      },
    );
  }

  String _formatTime(int timestamp) {
    final dt  = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return DateFormat('HH:mm').format(dt);
    }
    if (now.difference(dt).inDays < 7) {
      return DateFormat('EEE').format(dt);
    }
    return DateFormat('dd/MM').format(dt);
  }
}