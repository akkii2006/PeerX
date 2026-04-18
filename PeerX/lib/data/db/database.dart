import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'daos/contacts_dao.dart';
import 'daos/messages_dao.dart';
import 'daos/requests_dao.dart';

part 'database.g.dart';

// ── Tables ───────────────────────────────────────────────────────────────────

class Contacts extends Table {
  TextColumn get deviceId   => text()();
  TextColumn get nickname   => text().nullable()();
  TextColumn get publicKey  => text()();
  TextColumn get status     => text().withDefault(const Constant('active'))(); // active | blocked
  IntColumn  get createdAt  => integer()();

  @override
  Set<Column> get primaryKey => {deviceId};
}

class Messages extends Table {
  IntColumn  get id             => integer().autoIncrement()();
  TextColumn get conversationId => text()(); // the other peer's deviceId
  TextColumn get fromId         => text()();
  TextColumn get ciphertext     => text()();
  TextColumn get plaintext      => text().nullable()(); // decrypted locally
  IntColumn  get sentAt         => integer()();
  BoolColumn get delivered      => boolean().withDefault(const Constant(false))();
  BoolColumn get read           => boolean().withDefault(const Constant(false))();
  TextColumn get messageId      => text().unique()(); // relay message ID
  BoolColumn get isQueued       => boolean().withDefault(const Constant(false))();
}

class PeerRequests extends Table {
  TextColumn get id           => text()();
  TextColumn get fromDeviceId => text()();
  IntColumn  get receivedAt   => integer()();
  TextColumn get status       => text().withDefault(const Constant('pending'))(); // pending | accepted | rejected | blocked

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [Contacts, Messages, PeerRequests],
  daos:   [ContactsDao, MessagesDao, RequestsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'peerx_db');
  }
}

// Singleton
AppDatabase? _db;
AppDatabase get database => _db ??= AppDatabase();