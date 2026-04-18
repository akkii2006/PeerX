import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/db/database.dart';
import '../../core/relay/relay_service.dart';
import '../../core/crypto/crypto_service.dart';
import '../../core/identity/identity_service.dart';
import '../../shared/theme/app_theme.dart';
import 'widgets/message_bubble.dart';
import 'package:drift/drift.dart' show Value;

class ChatScreen extends StatefulWidget {
  final Contact contact;
  const ChatScreen({super.key, required this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _relay      = RelayService();
  final _crypto     = CryptoService();
  final _identity   = IdentityService();
  final _focusNode  = FocusNode();

  bool _sending = false;

  String get _displayName {
    if (widget.contact.nickname != null && widget.contact.nickname!.isNotEmpty) {
      return widget.contact.nickname!;
    }
    return widget.contact.deviceId.substring(0, 8).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _markRead();
    _listenForMessages();
  }

  void _markRead() {
    database.messagesDao.markRead(widget.contact.deviceId);
  }

  // Just scroll when a new message arrives from this contact.
  // Saving to DB is handled by RelayService so it works even when
  // the chat screen is closed (e.g. queued messages delivered on reconnect).
  void _listenForMessages() {
    _relay.onMessage.listen((msg) {
      if (msg.from != widget.contact.deviceId) return;
      _markRead();
      _scrollToBottom();
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _controller.clear();

    try {
      // Get peer key — waits if not yet available
      final peerKey = await _relay.getPublicKey(widget.contact.deviceId);

      // Encrypt
      final sharedSecret = await _crypto.deriveSharedSecret(
        _identity.keyPair,
        peerKey,
      );
      final ciphertext = await _crypto.encrypt(text, sharedSecret);

      // Send via relay
      final messageId = await _relay.sendMessage(
        to:         widget.contact.deviceId,
        ciphertext: ciphertext,
      );

      // Save locally
      try {
        await database.messagesDao.insertMessage(MessagesCompanion(
          conversationId: Value(widget.contact.deviceId),
          fromId:         Value(_identity.deviceId),
          ciphertext:     Value(ciphertext),
          plaintext:      Value(text),
          sentAt:         Value(DateTime.now().millisecondsSinceEpoch),
          delivered:      Value(false),
          read:           Value(true),
          messageId:      Value(messageId),
          isQueued:       Value(false),
        ));
      } catch (_) {}

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         Text('Could not send: $e'),
            backgroundColor: const Color(0xFF1A1A1A),
            behavior:        SnackBarBehavior.floating,
            shape:           RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve:    Curves.easeOut,
        );
      }
    });
  }

  void _showRenameDialog() {
    final ctrl = TextEditingController(text: widget.contact.nickname ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title:           const Text('Rename contact'),
        content:         TextField(
          controller: ctrl,
          autofocus:  true,
          style:      const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Enter nickname'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:     const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await database.contactsDao.updateNickname(
                widget.contact.deviceId,
                ctrl.text.trim(),
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPeerInfo() {
    showModalBottomSheet(
      context:         context,
      backgroundColor: const Color(0xFF0D0D0D),
      shape:           const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child:   Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width:      40,
                height:     4,
                decoration: BoxDecoration(
                  color:        AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Peer ID',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.contact.deviceId,
                    style: const TextStyle(
                      fontSize:   13,
                      color:      Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  icon:      const Icon(Icons.copy_rounded, size: 18),
                  color:     AppTheme.textSecondary,
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.contact.deviceId),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:         const Text('Copied to clipboard'),
                        backgroundColor: const Color(0xFF1A1A1A),
                        behavior:        SnackBarBehavior.floating,
                        shape:           RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Rename
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showRenameDialog,
                icon:      const Icon(Icons.edit_rounded, size: 18),
                label:     const Text('Rename'),
                style:     OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side:            const BorderSide(color: AppTheme.border),
                  padding:         const EdgeInsets.symmetric(vertical: 14),
                  shape:           RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Clear chat
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A1A),
                      title:           const Text('Clear chat'),
                      content:         const Text(
                        'All messages in this conversation will be deleted '
                            'from this device. This cannot be undone.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child:     const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style:     FilledButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                          ),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await database.messagesDao.deleteConversation(
                      widget.contact.deviceId,
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon:  const Icon(Icons.delete_sweep_rounded, size: 18),
                label: const Text('Clear chat'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orangeAccent,
                  side:            const BorderSide(color: Colors.orangeAccent),
                  padding:         const EdgeInsets.symmetric(vertical: 14),
                  shape:           RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading:         IconButton(
          icon:      const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _displayName,
              style: const TextStyle(
                fontSize:   17,
                fontWeight: FontWeight.w600,
                color:      Colors.white,
              ),
            ),
            StreamBuilder<PresenceEvent>(
              stream: _relay.onPresence.where(
                    (e) => e.peerId == widget.contact.deviceId,
              ),
              builder: (context, snap) {
                final online = snap.data?.online ?? false;
                return Text(
                  online ? 'online' : 'offline',
                  style: TextStyle(
                    fontSize: 12,
                    color:    online ? AppTheme.online : AppTheme.textMuted,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon:      const Icon(Icons.more_vert_rounded),
            onPressed: _showPeerInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream:  database.messagesDao.watchMessages(
                widget.contact.deviceId,
              ),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snap.data!;

                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          color: AppTheme.textMuted,
                          size:  32,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'End-to-end encrypted',
                          style: TextStyle(
                            color:    AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _scrollToBottom(),
                );

                return ListView.builder(
                  controller:  _scrollCtrl,
                  padding:     const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical:   8,
                  ),
                  itemCount:   messages.length,
                  itemBuilder: (context, i) {
                    final msg      = messages[i];
                    final isMe     = msg.fromId == _identity.deviceId;
                    final showTime = i == messages.length - 1 ||
                        messages[i + 1].sentAt - msg.sentAt > 60000;
                    return MessageBubble(
                      message:  msg,
                      isMe:     isMe,
                      showTime: showTime,
                    );
                  },
                );
              },
            ),
          ),
          _InputBar(
            controller: _controller,
            focusNode:  _focusNode,
            sending:    _sending,
            onSend:     _send,
          ),
        ],
      ),
    );
  }
}

// ── Input Bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode             focusNode;
  final bool                  sending;
  final VoidCallback          onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 8, 16,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color:  Colors.black,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller:         controller,
              focusNode:          focusNode,
              style:              const TextStyle(color: Colors.white, fontSize: 15),
              maxLines:           5,
              minLines:           1,
              textCapitalization: TextCapitalization.sentences,
              decoration:         const InputDecoration(
                hintText:      'Message',
                filled:        true,
                fillColor:     Color(0xFF1A1A1A),
                border:        OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide:   BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical:   10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          sending
              ? const SizedBox(
            width:  44,
            height: 44,
            child:  Padding(
              padding: EdgeInsets.all(10),
              child:   CircularProgressIndicator(strokeWidth: 2),
            ),
          )
              : FilledButton(
            onPressed: onSend,
            style:     FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize:     const Size(44, 44),
              padding:         EdgeInsets.zero,
              shape:           const CircleBorder(),
            ),
            child: const Icon(Icons.arrow_upward_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}