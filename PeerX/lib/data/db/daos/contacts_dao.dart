import 'package:drift/drift.dart';
import '../database.dart';

part 'contacts_dao.g.dart';

@DriftAccessor(tables: [Contacts])
class ContactsDao extends DatabaseAccessor<AppDatabase> with _$ContactsDaoMixin {
  ContactsDao(super.db);

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<List<Contact>> getAllContacts() =>
      (select(contacts)
        ..where((c) => c.status.equals('active'))
        ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
      .get();

  Future<Contact?> getContact(String deviceId) =>
      (select(contacts)..where((c) => c.deviceId.equals(deviceId)))
      .getSingleOrNull();

  Stream<List<Contact>> watchAllContacts() =>
      (select(contacts)
        ..where((c) => c.status.equals('active'))
        ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
      .watch();

  // ── Insert ─────────────────────────────────────────────────────────────────

  Future<void> upsertContact(ContactsCompanion contact) =>
      into(contacts).insertOnConflictUpdate(contact);

  // ── Update ─────────────────────────────────────────────────────────────────

  Future<void> updateNickname(String deviceId, String nickname) =>
      (update(contacts)..where((c) => c.deviceId.equals(deviceId)))
      .write(ContactsCompanion(nickname: Value(nickname)));

  Future<void> updatePublicKey(String deviceId, String publicKey) =>
      (update(contacts)..where((c) => c.deviceId.equals(deviceId)))
      .write(ContactsCompanion(publicKey: Value(publicKey)));

  Future<void> blockContact(String deviceId) =>
      (update(contacts)..where((c) => c.deviceId.equals(deviceId)))
      .write(const ContactsCompanion(status: Value('blocked')));

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deleteContact(String deviceId) =>
      (delete(contacts)..where((c) => c.deviceId.equals(deviceId))).go();
}