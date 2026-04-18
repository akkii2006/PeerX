// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requests_dao.dart';

// ignore_for_file: type=lint
mixin _$RequestsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PeerRequestsTable get peerRequests => attachedDatabase.peerRequests;
  RequestsDaoManager get managers => RequestsDaoManager(this);
}

class RequestsDaoManager {
  final _$RequestsDaoMixin _db;
  RequestsDaoManager(this._db);
  $$PeerRequestsTableTableManager get peerRequests =>
      $$PeerRequestsTableTableManager(_db.attachedDatabase, _db.peerRequests);
}
