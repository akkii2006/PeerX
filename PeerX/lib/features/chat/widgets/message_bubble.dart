import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/db/database.dart';
import '../../../shared/theme/app_theme.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool    isMe;
  final bool    showTime;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showTime,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double>   _scale;
  late final Animation<double>   _opacity;
  bool _showTimestamp = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = CurvedAnimation(parent: _anim, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child:   ScaleTransition(
        scale:     _scale,
        alignment: widget.isMe
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => setState(() => _showTimestamp = !_showTimestamp),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child:   Column(
              crossAxisAlignment: widget.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: widget.isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!widget.isMe) const SizedBox(width: 4),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72,
                        ),
                        padding:    const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical:   10,
                        ),
                        decoration: BoxDecoration(
                          color:        widget.isMe
                              ? AppTheme.primary
                              : AppTheme.received,
                          borderRadius: BorderRadius.only(
                            topLeft:     const Radius.circular(18),
                            topRight:    const Radius.circular(18),
                            bottomLeft:  Radius.circular(widget.isMe ? 18 : 4),
                            bottomRight: Radius.circular(widget.isMe ? 4 : 18),
                          ),
                        ),
                        child: Text(
                          widget.message.plaintext ?? '···',
                          style: TextStyle(
                            fontSize:   15,
                            color:      widget.isMe
                                ? Colors.white
                                : Colors.white,
                            height:     1.35,
                          ),
                        ),
                      ),
                    ),
                    if (widget.isMe) ...[
                      const SizedBox(width: 4),
                      _DeliveryIcon(
                        delivered: widget.message.delivered,
                        isQueued:    widget.message.isQueued,
                      ),
                    ],
                  ],
                ),

                // Timestamp — shown on tap
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child:    _showTimestamp || widget.showTime
                      ? Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    child:   Text(
                      DateFormat('HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(widget.message.sentAt),
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color:    AppTheme.textMuted,
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Delivery Icon ─────────────────────────────────────────────────────────────

class _DeliveryIcon extends StatelessWidget {
  final bool delivered;
  final bool isQueued;

  const _DeliveryIcon({
    required this.delivered,
    required this.isQueued,
  });

  @override
  Widget build(BuildContext context) {
    if (isQueued) {
      return const Icon(Icons.access_time_rounded, size: 12, color: AppTheme.textMuted);
    }
    if (delivered) {
      return const Icon(Icons.done_all_rounded, size: 12, color: AppTheme.primary);
    }
    return const Icon(Icons.done_rounded, size: 12, color: AppTheme.textMuted);
  }
}