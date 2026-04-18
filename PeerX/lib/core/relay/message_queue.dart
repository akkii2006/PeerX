import 'dart:collection';

class PendingMessage {
  final String messageId;
  final String to;
  final Map<String, dynamic> envelope;
  final DateTime queuedAt;
  int retries;

  PendingMessage({
    required this.messageId,
    required this.to,
    required this.envelope,
    required this.retries,
  }) : queuedAt = DateTime.now();
}

class MessageQueue {
  static final MessageQueue _instance = MessageQueue._internal();
  factory MessageQueue() => _instance;
  MessageQueue._internal();

  final _queue = Queue<PendingMessage>();

  void enqueue(PendingMessage message) {
    _queue.add(message);
  }

  PendingMessage? dequeue() {
    if (_queue.isEmpty) return null;
    return _queue.removeFirst();
  }

  void remove(String messageId) {
    _queue.removeWhere((m) => m.messageId == messageId);
  }

  bool get isEmpty => _queue.isEmpty;
  int  get length  => _queue.length;

  List<PendingMessage> get all => _queue.toList();
}