import 'package:drift/drift.dart';
import '../database.dart';

part 'requests_dao.g.dart';

@DriftAccessor(tables: [PeerRequests])
class RequestsDao extends DatabaseAccessor<AppDatabase> with _$RequestsDaoMixin {
  RequestsDao(super.db);

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<List<PeerRequest>> getPendingRequests() =>
      (select(peerRequests)
        ..where((r) => r.status.equals('pending'))
        ..orderBy([(r) => OrderingTerm.desc(r.receivedAt)]))
      .get();

  Stream<List<PeerRequest>> watchPendingRequests() =>
      (select(peerRequests)
        ..where((r) => r.status.equals('pending'))
        ..orderBy([(r) => OrderingTerm.desc(r.receivedAt)]))
      .watch();

  Future<PeerRequest?> getRequest(String id) =>
      (select(peerRequests)..where((r) => r.id.equals(id)))
      .getSingleOrNull();

  Future<bool> isBlocked(String fromDeviceId) async {
    final result = await (select(peerRequests)
      ..where((r) =>
        r.fromDeviceId.equals(fromDeviceId) &
        r.status.equals('blocked')))
      .getSingleOrNull();
    return result != null;
  }


  // ── Insert ─────────────────────────────────────────────────────────────────

  Future<void> insertRequest(PeerRequestsCompanion request) =>
      into(peerRequests).insertOnConflictUpdate(request);

  // ── Update ─────────────────────────────────────────────────────────────────

  Future<void> updateStatus(String id, String status) =>
      (update(peerRequests)..where((r) => r.id.equals(id)))
      .write(PeerRequestsCompanion(status: Value(status)));

  Future<void> blockDevice(String fromDeviceId) =>
      (update(peerRequests)..where((r) => r.fromDeviceId.equals(fromDeviceId)))
      .write(const PeerRequestsCompanion(status: Value('blocked')));
}