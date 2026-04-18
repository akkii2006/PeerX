import 'package:drift/drift.dart';
import '../database.dart';

part 'messages_dao.g.dart';

@DriftAccessor(tables: [Messages])
class MessagesDao extends DatabaseAccessor<AppDatabase> with _$MessagesDaoMixin {
  MessagesDao(super.db);

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<List<Message>> getMessages(String conversationId) =>
      (select(messages)
        ..where((m) => m.conversationId.equals(conversationId))
        ..orderBy([(m) => OrderingTerm.asc(m.sentAt)]))
          .get();

  Stream<List<Message>> watchMessages(String conversationId) =>
      (select(messages)
        ..where((m) => m.conversationId.equals(conversationId))
        ..orderBy([(m) => OrderingTerm.asc(m.sentAt)]))
          .watch();

  // Last message per conversation for home screen preview
  Future<Message?> getLastMessage(String conversationId) =>
      (select(messages)
        ..where((m) => m.conversationId.equals(conversationId))
        ..orderBy([(m) => OrderingTerm.desc(m.sentAt)])
        ..limit(1))
          .getSingleOrNull();

  Future<int> getUnreadCount(String conversationId) async {
    final count = countAll(
      filter: messages.conversationId.equals(conversationId) &
      messages.read.equals(false) &
      messages.fromId.isNotValue('me'),
    );
    final query = selectOnly(messages)..addColumns([count]);
    final row   = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<bool> messageExists(String messageId) async {
    final result = await (select(messages)
      ..where((m) => m.messageId.equals(messageId)))
        .getSingleOrNull();
    return result != null;
  }

  // ── Insert ─────────────────────────────────────────────────────────────────

  Future<int> insertMessage(MessagesCompanion message) =>
      into(messages).insert(message);

  // ── Update ─────────────────────────────────────────────────────────────────

  Future<void> markDelivered(String messageId) =>
      (update(messages)..where((m) => m.messageId.equals(messageId)))
          .write(const MessagesCompanion(
        delivered: Value(true),
        isQueued:  Value(false),
      ));

  Future<void> markUndelivered(String messageId) =>
      (update(messages)..where((m) => m.messageId.equals(messageId)))
          .write(const MessagesCompanion(
        delivered: Value(false),
        isQueued:  Value(true),
      ));

  Future<void> markRead(String conversationId) =>
      (update(messages)..where((m) =>
      m.conversationId.equals(conversationId) &
      m.read.equals(false)))
          .write(const MessagesCompanion(read: Value(true)));

  Future<void> savePlaintext(String messageId, String plaintext) =>
      (update(messages)..where((m) => m.messageId.equals(messageId)))
          .write(MessagesCompanion(plaintext: Value(plaintext)));

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deleteConversation(String conversationId) =>
      (delete(messages)
        ..where((m) => m.conversationId.equals(conversationId)))
          .go();
}