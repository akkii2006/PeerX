import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:drift/drift.dart' show Value;
import '../identity/identity_service.dart';
import '../crypto/crypto_service.dart';
import '../notifications/push_service.dart';
import '../notifications/notification_service.dart';
import '../../data/db/database.dart';
import 'message_queue.dart';
import 'package:peerx/main.dart' show AppLifecycleObserver;

// ── Event Types ───────────────────────────────────────────────────────────────

class RelayMessage {
  final String from;
  final String messageId;
  final String ciphertext;
  final int    sentAt;
  final bool   queued;

  RelayMessage({
    required this.from,
    required this.messageId,
    required this.ciphertext,
    required this.sentAt,
    required this.queued,
  });
}

class PresenceEvent {
  final String  peerId;
  final bool    online;
  final String? publicKey;

  PresenceEvent({
    required this.peerId,
    required this.online,
    this.publicKey,
  });
}

class KeySyncEvent {
  final String peerId;
  final String publicKey;
  KeySyncEvent({required this.peerId, required this.publicKey});
}

class AddRequestEvent {
  final String fromDeviceId;
  final String requestId;
  AddRequestEvent({required this.fromDeviceId, required this.requestId});
}

class AddResponseEvent {
  final String fromDeviceId;
  final String requestId;
  final bool   accepted;
  AddResponseEvent({
    required this.fromDeviceId,
    required this.requestId,
    required this.accepted,
  });
}

// ── Relay Service ─────────────────────────────────────────────────────────────

class RelayService {
  static final RelayService _instance = RelayService._internal();
  factory RelayService() => _instance;
  RelayService._internal();

  static const _relayUrl    = 'wss://peerx-relay.onrender.com';
  static const _ackTimeout  = Duration(seconds: 5);

  final _identity = IdentityService();
  final _crypto   = CryptoService();
  final _msgQueue = MessageQueue();
  final _uuid     = const Uuid();

  WebSocketChannel? _channel;
  Timer?            _reconnectTimer;
  Timer?            _heartbeatTimer;
  Timer?            _handshakeTimer;

  bool _connected       = false;
  bool _intentionalStop = false;
  int  _reconnectDelay  = 2;

  final _keyCache      = <String, String>{};
  final _keyCompleters = <String, Completer<String>>{};

  // Tracks pending ack timers — messageId → timer
  // If no ack arrives within _ackTimeout, message is re-queued
  final _ackTimers = <String, Timer>{};

  // ── Streams ───────────────────────────────────────────────────────────────

  final _messageController     = StreamController<RelayMessage>.broadcast();
  final _presenceController    = StreamController<PresenceEvent>.broadcast();
  final _keySyncController     = StreamController<KeySyncEvent>.broadcast();
  final _addRequestController  = StreamController<AddRequestEvent>.broadcast();
  final _addResponseController = StreamController<AddResponseEvent>.broadcast();
  final _connectedController   = StreamController<bool>.broadcast();

  Stream<RelayMessage>     get onMessage     => _messageController.stream;
  Stream<PresenceEvent>    get onPresence    => _presenceController.stream;
  Stream<KeySyncEvent>     get onKeySync     => _keySyncController.stream;
  Stream<AddRequestEvent>  get onAddRequest  => _addRequestController.stream;
  Stream<AddResponseEvent> get onAddResponse => _addResponseController.stream;
  Stream<bool>             get onConnected   => _connectedController.stream;
  bool                     get isConnected   => _connected;

  // ── Connect ───────────────────────────────────────────────────────────────

  Future<void> connect() async {
    _intentionalStop = false;
    _tryConnect();
  }

  void _tryConnect() {
    if (_intentionalStop) return;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_relayUrl));
      _channel!.stream.listen(
        _onData,
        onDone:  _onDone,
        onError: (e) => _onDone(),
        cancelOnError: false,
      );
      _sendHandshake();
    } catch (e) {
      _scheduleReconnect();
    }
  }

  // ── Disconnect ────────────────────────────────────────────────────────────

  void disconnect() {
    _intentionalStop = true;
    _cleanup();
  }

  void _cleanup() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _handshakeTimer?.cancel();
    // Cancel all pending ack timers
    for (final t in _ackTimers.values) t.cancel();
    _ackTimers.clear();
    _channel?.sink.close(status.goingAway);
    _channel   = null;
    _connected = false;
  }

  // ── Handshake ─────────────────────────────────────────────────────────────

  Future<void> _sendHandshake() async {
    final contacts   = await database.contactsDao.getAllContacts();
    final contactIds = contacts.map((c) => c.deviceId).toList();
    final fcmToken   = PushService().fcmToken;

    _send({
      'type':      'handshake',
      'from':      _identity.deviceId,
      'messageId': _uuid.v4(),
      'sentAt':    DateTime.now().millisecondsSinceEpoch,
      'publicKey': _identity.publicKey,
      'payload':   jsonEncode(contactIds),
      if (fcmToken != null) 'pushToken': fcmToken,
    });

    _handshakeTimer?.cancel();
    _handshakeTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_connected) _sendHandshake();
    });

    _startHeartbeat();
  }

  // ── Heartbeat ─────────────────────────────────────────────────────────────

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _send({
        'type':      'ping',
        'from':      _identity.deviceId,
        'messageId': _uuid.v4(),
        'sentAt':    DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  // ── Send ──────────────────────────────────────────────────────────────────

  void _send(Map<String, dynamic> data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (_) {}
  }

  // ── Send Message ──────────────────────────────────────────────────────────

  Future<String> sendMessage({
    required String to,
    required String ciphertext,
  }) async {
    final messageId = _uuid.v4();
    final envelope  = {
      'type':      'message',
      'from':      _identity.deviceId,
      'to':        to,
      'messageId': messageId,
      'sentAt':    DateTime.now().millisecondsSinceEpoch,
      'payload':   ciphertext,
    };

    if (_connected) {
      _send(envelope);
      _startAckTimer(
        messageId: messageId,
        to:        to,
        envelope:  envelope,
      );
    } else {
      _msgQueue.enqueue(PendingMessage(
        messageId: messageId,
        to:        to,
        envelope:  envelope,
        retries:   0,
      ));
    }

    return messageId;
  }

  // ── Ack Timeout ───────────────────────────────────────────────────────────
  // If no ack arrives within _ackTimeout, re-queue the message for retry.
  // This handles the gap window where the recipient just went offline but
  // the server hasn't detected the dead connection yet.

  void _startAckTimer({
    required String messageId,
    required String to,
    required Map<String, dynamic> envelope,
  }) {
    _ackTimers[messageId]?.cancel();
    _ackTimers[messageId] = Timer(_ackTimeout, () {
      _ackTimers.remove(messageId);
      // Only re-queue if we haven't gotten a delivered ack
      // and we're still connected (if disconnected, _onDone handles it)
      if (_connected) {
        print('[relay] ack timeout for $messageId — re-queuing');
        _msgQueue.enqueue(PendingMessage(
          messageId: messageId,
          to:        to,
          envelope:  envelope,
          retries:   0,
        ));
        // Mark as undelivered in DB so UI shows correct state
        database.messagesDao.markUndelivered(messageId);
      }
    });
  }

  // ── Send Add Request ──────────────────────────────────────────────────────

  Future<void> sendAddRequest(String toDeviceId) async {
    _send({
      'type':      'add_request',
      'from':      _identity.deviceId,
      'to':        toDeviceId,
      'messageId': _uuid.v4(),
      'requestId': _uuid.v4(),
      'sentAt':    DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ── Send Add Response ─────────────────────────────────────────────────────

  Future<void> sendAddResponse({
    required String toDeviceId,
    required String requestId,
    required bool   accepted,
  }) async {
    _send({
      'type':      'add_response',
      'from':      _identity.deviceId,
      'to':        toDeviceId,
      'messageId': _uuid.v4(),
      'requestId': requestId,
      'accepted':  accepted,
      'sentAt':    DateTime.now().millisecondsSinceEpoch,
      'publicKey': _identity.publicKey,
    });
  }

  // ── Get Public Key ────────────────────────────────────────────────────────

  Future<String> getPublicKey(String peerId) async {
    if (_keyCache.containsKey(peerId)) return _keyCache[peerId]!;

    final contact = await database.contactsDao.getContact(peerId);
    if (contact != null) {
      _keyCache[peerId] = contact.publicKey;
      return contact.publicKey;
    }

    if (_keyCompleters.containsKey(peerId)) {
      return _keyCompleters[peerId]!.future;
    }

    final completer = Completer<String>();
    _keyCompleters[peerId] = completer;

    _send({
      'type':      'key_request',
      'from':      _identity.deviceId,
      'to':        peerId,
      'messageId': _uuid.v4(),
      'sentAt':    DateTime.now().millisecondsSinceEpoch,
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        completer.completeError('Key not found for $peerId');
        _keyCompleters.remove(peerId);
      }
    });

    return completer.future;
  }

  void _cacheKey(String peerId, String publicKey) {
    _keyCache[peerId] = publicKey;

    if (_keyCompleters.containsKey(peerId)) {
      _keyCompleters[peerId]!.complete(publicKey);
      _keyCompleters.remove(peerId);
    }

    database.contactsDao.updatePublicKey(peerId, publicKey);
    _keySyncController.add(KeySyncEvent(peerId: peerId, publicKey: publicKey));
  }

  // ── Incoming Data ─────────────────────────────────────────────────────────

  void _onData(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'ack':          _handleAck(data);
        case 'message':      _handleIncomingMessage(data);
        case 'presence':     _handlePresence(data);
        case 'key_sync':     _handleKeySync(data);
        case 'add_request':  _handleAddRequest(data);
        case 'add_response': _handleAddResponse(data);
        case 'pong':         break;
        case 'error':        break;
        default:             break;
      }
    } catch (_) {}
  }

  void _handleAck(Map<String, dynamic> data) {
    if (!_connected) {
      _connected      = true;
      _reconnectDelay = 2;
      _connectedController.add(true);
      _flushQueue();
    }

    final messageId = data['messageId'] as String?;
    final delivered = data['delivered'] as bool? ?? false;

    if (messageId != null) {
      // Cancel the ack timer — we got a response
      _ackTimers[messageId]?.cancel();
      _ackTimers.remove(messageId);

      if (delivered) {
        _msgQueue.remove(messageId);
        database.messagesDao.markDelivered(messageId);
      }
      // If delivered: false, message was queued on server side —
      // server will deliver it when recipient reconnects, no retry needed
    }
  }

  // Saves every incoming message to DB immediately — works whether chat
  // screen is open or not. Chat screen StreamBuilder picks it up automatically.
  void _handleIncomingMessage(Map<String, dynamic> data) async {
    final from      = data['from']      as String?;
    final messageId = data['messageId'] as String?;
    final payload   = data['payload']   as String?;
    final sentAt    = data['sentAt']    as int?;
    final queued    = data['queued']    as bool? ?? false;

    if (from == null || messageId == null || payload == null || sentAt == null) return;

    // Always emit to stream so open chat screens can scroll
    final relayMsg = RelayMessage(
      from:       from,
      messageId:  messageId,
      ciphertext: payload,
      sentAt:     sentAt,
      queued:     queued,
    );
    _messageController.add(relayMsg);

    // Check duplicate before saving
    final exists = await database.messagesDao.messageExists(messageId);
    if (exists) return;

    // Decrypt using stored contact key
    String plaintext;
    try {
      final contact = await database.contactsDao.getContact(from);
      final peerKey = contact?.publicKey ?? _keyCache[from];
      if (peerKey == null) {
        plaintext = '[key not available]';
      } else {
        final sharedSecret = await _crypto.deriveSharedSecret(
          _identity.keyPair,
          peerKey,
        );
        plaintext = await _crypto.decrypt(payload, sharedSecret);
      }
    } catch (_) {
      plaintext = '[could not decrypt]';
    }

    // Save to DB
    try {
      await database.messagesDao.insertMessage(MessagesCompanion(
        conversationId: Value(from),
        fromId:         Value(from),
        ciphertext:     Value(payload),
        plaintext:      Value(plaintext),
        sentAt:         Value(sentAt),
        delivered:      Value(true),
        read:           Value(false),
        messageId:      Value(messageId),
        isQueued:       Value(queued),
      ));
    } catch (_) {
      return;
    }

    // Show local notification only when app is in background
    if (!AppLifecycleObserver.isInForeground) {
      try {
        final contact = await database.contactsDao.getContact(from);
        if (contact != null) {
          final name = (contact.nickname?.isNotEmpty == true)
              ? contact.nickname!
              : from.substring(0, 8).toUpperCase();
          await NotificationService().showMessageNotification(
            conversationId: from,
            senderName:     name,
          );
        }
      } catch (_) {}
    }
  }

  void _handlePresence(Map<String, dynamic> data) {
    final peerId    = data['peerId']    as String?;
    final online    = data['online']    as bool?;
    final publicKey = data['publicKey'] as String?;

    if (peerId == null || online == null) return;
    if (publicKey != null) _cacheKey(peerId, publicKey);

    _presenceController.add(PresenceEvent(
      peerId:    peerId,
      online:    online,
      publicKey: publicKey,
    ));
  }

  void _handleKeySync(Map<String, dynamic> data) {
    final peerId    = data['peerId']    as String?;
    final publicKey = data['publicKey'] as String?;
    if (peerId == null || publicKey == null) return;
    _cacheKey(peerId, publicKey);
  }

  void _handleAddRequest(Map<String, dynamic> data) {
    final from      = data['from']      as String?;
    final requestId = data['requestId'] as String?;
    if (from == null || requestId == null) return;

    _addRequestController.add(AddRequestEvent(
      fromDeviceId: from,
      requestId:    requestId,
    ));
  }

  void _handleAddResponse(Map<String, dynamic> data) {
    final from      = data['from']      as String?;
    final requestId = data['requestId'] as String?;
    final accepted  = data['accepted']  as bool?;
    final publicKey = data['publicKey'] as String?;

    if (from == null || requestId == null || accepted == null) return;
    if (publicKey != null) _cacheKey(from, publicKey);

    _addResponseController.add(AddResponseEvent(
      fromDeviceId: from,
      requestId:    requestId,
      accepted:     accepted,
    ));
  }

  // ── Flush Queue ───────────────────────────────────────────────────────────

  void _flushQueue() {
    for (final msg in _msgQueue.all) {
      _send(msg.envelope);
      // Start ack timer for each flushed message
      _startAckTimer(
        messageId: msg.messageId,
        to:        msg.to,
        envelope:  msg.envelope,
      );
    }
  }

  // ── Reconnect ─────────────────────────────────────────────────────────────

  void _onDone() {
    _connected = false;
    _heartbeatTimer?.cancel();
    _handshakeTimer?.cancel();
    _connectedController.add(false);

    // Cancel all ack timers — messages will be re-queued via _msgQueue
    // on reconnect since they were already added to the queue
    for (final t in _ackTimers.values) t.cancel();
    _ackTimers.clear();

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_intentionalStop) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelay), () {
      _reconnectDelay = min(_reconnectDelay * 2, 30);
      _tryConnect();
    });
  }
}