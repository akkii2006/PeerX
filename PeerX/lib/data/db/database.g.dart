// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    nickname,
    publicKey,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Contact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final String deviceId;
  final String? nickname;
  final String publicKey;
  final String status;
  final int createdAt;
  const Contact({
    required this.deviceId,
    this.nickname,
    required this.publicKey,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    map['public_key'] = Variable<String>(publicKey);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      deviceId: Value(deviceId),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      publicKey: Value(publicKey),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Contact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      publicKey: serializer.fromJson<String>(json['publicKey']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'nickname': serializer.toJson<String?>(nickname),
      'publicKey': serializer.toJson<String>(publicKey),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Contact copyWith({
    String? deviceId,
    Value<String?> nickname = const Value.absent(),
    String? publicKey,
    String? status,
    int? createdAt,
  }) => Contact(
    deviceId: deviceId ?? this.deviceId,
    nickname: nickname.present ? nickname.value : this.nickname,
    publicKey: publicKey ?? this.publicKey,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('deviceId: $deviceId, ')
          ..write('nickname: $nickname, ')
          ..write('publicKey: $publicKey, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(deviceId, nickname, publicKey, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.deviceId == this.deviceId &&
          other.nickname == this.nickname &&
          other.publicKey == this.publicKey &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> deviceId;
  final Value<String?> nickname;
  final Value<String> publicKey;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ContactsCompanion({
    this.deviceId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    required String deviceId,
    this.nickname = const Value.absent(),
    required String publicKey,
    this.status = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       publicKey = Value(publicKey),
       createdAt = Value(createdAt);
  static Insertable<Contact> custom({
    Expression<String>? deviceId,
    Expression<String>? nickname,
    Expression<String>? publicKey,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (nickname != null) 'nickname': nickname,
      if (publicKey != null) 'public_key': publicKey,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith({
    Value<String>? deviceId,
    Value<String?>? nickname,
    Value<String>? publicKey,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ContactsCompanion(
      deviceId: deviceId ?? this.deviceId,
      nickname: nickname ?? this.nickname,
      publicKey: publicKey ?? this.publicKey,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('nickname: $nickname, ')
          ..write('publicKey: $publicKey, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromIdMeta = const VerificationMeta('fromId');
  @override
  late final GeneratedColumn<String> fromId = GeneratedColumn<String>(
    'from_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ciphertextMeta = const VerificationMeta(
    'ciphertext',
  );
  @override
  late final GeneratedColumn<String> ciphertext = GeneratedColumn<String>(
    'ciphertext',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plaintextMeta = const VerificationMeta(
    'plaintext',
  );
  @override
  late final GeneratedColumn<String> plaintext = GeneratedColumn<String>(
    'plaintext',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<int> sentAt = GeneratedColumn<int>(
    'sent_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveredMeta = const VerificationMeta(
    'delivered',
  );
  @override
  late final GeneratedColumn<bool> delivered = GeneratedColumn<bool>(
    'delivered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("delivered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
    'read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isQueuedMeta = const VerificationMeta(
    'isQueued',
  );
  @override
  late final GeneratedColumn<bool> isQueued = GeneratedColumn<bool>(
    'is_queued',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_queued" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    fromId,
    ciphertext,
    plaintext,
    sentAt,
    delivered,
    read,
    messageId,
    isQueued,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('from_id')) {
      context.handle(
        _fromIdMeta,
        fromId.isAcceptableOrUnknown(data['from_id']!, _fromIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fromIdMeta);
    }
    if (data.containsKey('ciphertext')) {
      context.handle(
        _ciphertextMeta,
        ciphertext.isAcceptableOrUnknown(data['ciphertext']!, _ciphertextMeta),
      );
    } else if (isInserting) {
      context.missing(_ciphertextMeta);
    }
    if (data.containsKey('plaintext')) {
      context.handle(
        _plaintextMeta,
        plaintext.isAcceptableOrUnknown(data['plaintext']!, _plaintextMeta),
      );
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    } else if (isInserting) {
      context.missing(_sentAtMeta);
    }
    if (data.containsKey('delivered')) {
      context.handle(
        _deliveredMeta,
        delivered.isAcceptableOrUnknown(data['delivered']!, _deliveredMeta),
      );
    }
    if (data.containsKey('read')) {
      context.handle(
        _readMeta,
        read.isAcceptableOrUnknown(data['read']!, _readMeta),
      );
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('is_queued')) {
      context.handle(
        _isQueuedMeta,
        isQueued.isAcceptableOrUnknown(data['is_queued']!, _isQueuedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      fromId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_id'],
      )!,
      ciphertext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ciphertext'],
      )!,
      plaintext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plaintext'],
      ),
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sent_at'],
      )!,
      delivered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}delivered'],
      )!,
      read: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}read'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      isQueued: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_queued'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;
  final String conversationId;
  final String fromId;
  final String ciphertext;
  final String? plaintext;
  final int sentAt;
  final bool delivered;
  final bool read;
  final String messageId;
  final bool isQueued;
  const Message({
    required this.id,
    required this.conversationId,
    required this.fromId,
    required this.ciphertext,
    this.plaintext,
    required this.sentAt,
    required this.delivered,
    required this.read,
    required this.messageId,
    required this.isQueued,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['from_id'] = Variable<String>(fromId);
    map['ciphertext'] = Variable<String>(ciphertext);
    if (!nullToAbsent || plaintext != null) {
      map['plaintext'] = Variable<String>(plaintext);
    }
    map['sent_at'] = Variable<int>(sentAt);
    map['delivered'] = Variable<bool>(delivered);
    map['read'] = Variable<bool>(read);
    map['message_id'] = Variable<String>(messageId);
    map['is_queued'] = Variable<bool>(isQueued);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      fromId: Value(fromId),
      ciphertext: Value(ciphertext),
      plaintext: plaintext == null && nullToAbsent
          ? const Value.absent()
          : Value(plaintext),
      sentAt: Value(sentAt),
      delivered: Value(delivered),
      read: Value(read),
      messageId: Value(messageId),
      isQueued: Value(isQueued),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      fromId: serializer.fromJson<String>(json['fromId']),
      ciphertext: serializer.fromJson<String>(json['ciphertext']),
      plaintext: serializer.fromJson<String?>(json['plaintext']),
      sentAt: serializer.fromJson<int>(json['sentAt']),
      delivered: serializer.fromJson<bool>(json['delivered']),
      read: serializer.fromJson<bool>(json['read']),
      messageId: serializer.fromJson<String>(json['messageId']),
      isQueued: serializer.fromJson<bool>(json['isQueued']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'fromId': serializer.toJson<String>(fromId),
      'ciphertext': serializer.toJson<String>(ciphertext),
      'plaintext': serializer.toJson<String?>(plaintext),
      'sentAt': serializer.toJson<int>(sentAt),
      'delivered': serializer.toJson<bool>(delivered),
      'read': serializer.toJson<bool>(read),
      'messageId': serializer.toJson<String>(messageId),
      'isQueued': serializer.toJson<bool>(isQueued),
    };
  }

  Message copyWith({
    int? id,
    String? conversationId,
    String? fromId,
    String? ciphertext,
    Value<String?> plaintext = const Value.absent(),
    int? sentAt,
    bool? delivered,
    bool? read,
    String? messageId,
    bool? isQueued,
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    fromId: fromId ?? this.fromId,
    ciphertext: ciphertext ?? this.ciphertext,
    plaintext: plaintext.present ? plaintext.value : this.plaintext,
    sentAt: sentAt ?? this.sentAt,
    delivered: delivered ?? this.delivered,
    read: read ?? this.read,
    messageId: messageId ?? this.messageId,
    isQueued: isQueued ?? this.isQueued,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      fromId: data.fromId.present ? data.fromId.value : this.fromId,
      ciphertext: data.ciphertext.present
          ? data.ciphertext.value
          : this.ciphertext,
      plaintext: data.plaintext.present ? data.plaintext.value : this.plaintext,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      delivered: data.delivered.present ? data.delivered.value : this.delivered,
      read: data.read.present ? data.read.value : this.read,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      isQueued: data.isQueued.present ? data.isQueued.value : this.isQueued,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('fromId: $fromId, ')
          ..write('ciphertext: $ciphertext, ')
          ..write('plaintext: $plaintext, ')
          ..write('sentAt: $sentAt, ')
          ..write('delivered: $delivered, ')
          ..write('read: $read, ')
          ..write('messageId: $messageId, ')
          ..write('isQueued: $isQueued')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    fromId,
    ciphertext,
    plaintext,
    sentAt,
    delivered,
    read,
    messageId,
    isQueued,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.fromId == this.fromId &&
          other.ciphertext == this.ciphertext &&
          other.plaintext == this.plaintext &&
          other.sentAt == this.sentAt &&
          other.delivered == this.delivered &&
          other.read == this.read &&
          other.messageId == this.messageId &&
          other.isQueued == this.isQueued);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<String> conversationId;
  final Value<String> fromId;
  final Value<String> ciphertext;
  final Value<String?> plaintext;
  final Value<int> sentAt;
  final Value<bool> delivered;
  final Value<bool> read;
  final Value<String> messageId;
  final Value<bool> isQueued;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.fromId = const Value.absent(),
    this.ciphertext = const Value.absent(),
    this.plaintext = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.delivered = const Value.absent(),
    this.read = const Value.absent(),
    this.messageId = const Value.absent(),
    this.isQueued = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required String conversationId,
    required String fromId,
    required String ciphertext,
    this.plaintext = const Value.absent(),
    required int sentAt,
    this.delivered = const Value.absent(),
    this.read = const Value.absent(),
    required String messageId,
    this.isQueued = const Value.absent(),
  }) : conversationId = Value(conversationId),
       fromId = Value(fromId),
       ciphertext = Value(ciphertext),
       sentAt = Value(sentAt),
       messageId = Value(messageId);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<String>? conversationId,
    Expression<String>? fromId,
    Expression<String>? ciphertext,
    Expression<String>? plaintext,
    Expression<int>? sentAt,
    Expression<bool>? delivered,
    Expression<bool>? read,
    Expression<String>? messageId,
    Expression<bool>? isQueued,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (fromId != null) 'from_id': fromId,
      if (ciphertext != null) 'ciphertext': ciphertext,
      if (plaintext != null) 'plaintext': plaintext,
      if (sentAt != null) 'sent_at': sentAt,
      if (delivered != null) 'delivered': delivered,
      if (read != null) 'read': read,
      if (messageId != null) 'message_id': messageId,
      if (isQueued != null) 'is_queued': isQueued,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? conversationId,
    Value<String>? fromId,
    Value<String>? ciphertext,
    Value<String?>? plaintext,
    Value<int>? sentAt,
    Value<bool>? delivered,
    Value<bool>? read,
    Value<String>? messageId,
    Value<bool>? isQueued,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      fromId: fromId ?? this.fromId,
      ciphertext: ciphertext ?? this.ciphertext,
      plaintext: plaintext ?? this.plaintext,
      sentAt: sentAt ?? this.sentAt,
      delivered: delivered ?? this.delivered,
      read: read ?? this.read,
      messageId: messageId ?? this.messageId,
      isQueued: isQueued ?? this.isQueued,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (fromId.present) {
      map['from_id'] = Variable<String>(fromId.value);
    }
    if (ciphertext.present) {
      map['ciphertext'] = Variable<String>(ciphertext.value);
    }
    if (plaintext.present) {
      map['plaintext'] = Variable<String>(plaintext.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<int>(sentAt.value);
    }
    if (delivered.present) {
      map['delivered'] = Variable<bool>(delivered.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (isQueued.present) {
      map['is_queued'] = Variable<bool>(isQueued.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('fromId: $fromId, ')
          ..write('ciphertext: $ciphertext, ')
          ..write('plaintext: $plaintext, ')
          ..write('sentAt: $sentAt, ')
          ..write('delivered: $delivered, ')
          ..write('read: $read, ')
          ..write('messageId: $messageId, ')
          ..write('isQueued: $isQueued')
          ..write(')'))
        .toString();
  }
}

class $PeerRequestsTable extends PeerRequests
    with TableInfo<$PeerRequestsTable, PeerRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeerRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromDeviceIdMeta = const VerificationMeta(
    'fromDeviceId',
  );
  @override
  late final GeneratedColumn<String> fromDeviceId = GeneratedColumn<String>(
    'from_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<int> receivedAt = GeneratedColumn<int>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, fromDeviceId, receivedAt, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'peer_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeerRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_device_id')) {
      context.handle(
        _fromDeviceIdMeta,
        fromDeviceId.isAcceptableOrUnknown(
          data['from_device_id']!,
          _fromDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromDeviceIdMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeerRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeerRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fromDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_device_id'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $PeerRequestsTable createAlias(String alias) {
    return $PeerRequestsTable(attachedDatabase, alias);
  }
}

class PeerRequest extends DataClass implements Insertable<PeerRequest> {
  final String id;
  final String fromDeviceId;
  final int receivedAt;
  final String status;
  const PeerRequest({
    required this.id,
    required this.fromDeviceId,
    required this.receivedAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_device_id'] = Variable<String>(fromDeviceId);
    map['received_at'] = Variable<int>(receivedAt);
    map['status'] = Variable<String>(status);
    return map;
  }

  PeerRequestsCompanion toCompanion(bool nullToAbsent) {
    return PeerRequestsCompanion(
      id: Value(id),
      fromDeviceId: Value(fromDeviceId),
      receivedAt: Value(receivedAt),
      status: Value(status),
    );
  }

  factory PeerRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeerRequest(
      id: serializer.fromJson<String>(json['id']),
      fromDeviceId: serializer.fromJson<String>(json['fromDeviceId']),
      receivedAt: serializer.fromJson<int>(json['receivedAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromDeviceId': serializer.toJson<String>(fromDeviceId),
      'receivedAt': serializer.toJson<int>(receivedAt),
      'status': serializer.toJson<String>(status),
    };
  }

  PeerRequest copyWith({
    String? id,
    String? fromDeviceId,
    int? receivedAt,
    String? status,
  }) => PeerRequest(
    id: id ?? this.id,
    fromDeviceId: fromDeviceId ?? this.fromDeviceId,
    receivedAt: receivedAt ?? this.receivedAt,
    status: status ?? this.status,
  );
  PeerRequest copyWithCompanion(PeerRequestsCompanion data) {
    return PeerRequest(
      id: data.id.present ? data.id.value : this.id,
      fromDeviceId: data.fromDeviceId.present
          ? data.fromDeviceId.value
          : this.fromDeviceId,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeerRequest(')
          ..write('id: $id, ')
          ..write('fromDeviceId: $fromDeviceId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fromDeviceId, receivedAt, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeerRequest &&
          other.id == this.id &&
          other.fromDeviceId == this.fromDeviceId &&
          other.receivedAt == this.receivedAt &&
          other.status == this.status);
}

class PeerRequestsCompanion extends UpdateCompanion<PeerRequest> {
  final Value<String> id;
  final Value<String> fromDeviceId;
  final Value<int> receivedAt;
  final Value<String> status;
  final Value<int> rowid;
  const PeerRequestsCompanion({
    this.id = const Value.absent(),
    this.fromDeviceId = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeerRequestsCompanion.insert({
    required String id,
    required String fromDeviceId,
    required int receivedAt,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromDeviceId = Value(fromDeviceId),
       receivedAt = Value(receivedAt);
  static Insertable<PeerRequest> custom({
    Expression<String>? id,
    Expression<String>? fromDeviceId,
    Expression<int>? receivedAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromDeviceId != null) 'from_device_id': fromDeviceId,
      if (receivedAt != null) 'received_at': receivedAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeerRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? fromDeviceId,
    Value<int>? receivedAt,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return PeerRequestsCompanion(
      id: id ?? this.id,
      fromDeviceId: fromDeviceId ?? this.fromDeviceId,
      receivedAt: receivedAt ?? this.receivedAt,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromDeviceId.present) {
      map['from_device_id'] = Variable<String>(fromDeviceId.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<int>(receivedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeerRequestsCompanion(')
          ..write('id: $id, ')
          ..write('fromDeviceId: $fromDeviceId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $PeerRequestsTable peerRequests = $PeerRequestsTable(this);
  late final ContactsDao contactsDao = ContactsDao(this as AppDatabase);
  late final MessagesDao messagesDao = MessagesDao(this as AppDatabase);
  late final RequestsDao requestsDao = RequestsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contacts,
    messages,
    peerRequests,
  ];
}

typedef $$ContactsTableCreateCompanionBuilder =
    ContactsCompanion Function({
      required String deviceId,
      Value<String?> nickname,
      required String publicKey,
      Value<String> status,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$ContactsTableUpdateCompanionBuilder =
    ContactsCompanion Function({
      Value<String> deviceId,
      Value<String?> nickname,
      Value<String> publicKey,
      Value<String> status,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsTable,
          Contact,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (Contact, BaseReferences<_$AppDatabase, $ContactsTable, Contact>),
          Contact,
          PrefetchHooks Function()
        > {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String> publicKey = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion(
                deviceId: deviceId,
                nickname: nickname,
                publicKey: publicKey,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                Value<String?> nickname = const Value.absent(),
                required String publicKey,
                Value<String> status = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion.insert(
                deviceId: deviceId,
                nickname: nickname,
                publicKey: publicKey,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsTable,
      Contact,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (Contact, BaseReferences<_$AppDatabase, $ContactsTable, Contact>),
      Contact,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      required String conversationId,
      required String fromId,
      required String ciphertext,
      Value<String?> plaintext,
      required int sentAt,
      Value<bool> delivered,
      Value<bool> read,
      required String messageId,
      Value<bool> isQueued,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      Value<String> conversationId,
      Value<String> fromId,
      Value<String> ciphertext,
      Value<String?> plaintext,
      Value<int> sentAt,
      Value<bool> delivered,
      Value<bool> read,
      Value<String> messageId,
      Value<bool> isQueued,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromId => $composableBuilder(
    column: $table.fromId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ciphertext => $composableBuilder(
    column: $table.ciphertext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plaintext => $composableBuilder(
    column: $table.plaintext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get delivered => $composableBuilder(
    column: $table.delivered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isQueued => $composableBuilder(
    column: $table.isQueued,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromId => $composableBuilder(
    column: $table.fromId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ciphertext => $composableBuilder(
    column: $table.ciphertext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plaintext => $composableBuilder(
    column: $table.plaintext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get delivered => $composableBuilder(
    column: $table.delivered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isQueued => $composableBuilder(
    column: $table.isQueued,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromId =>
      $composableBuilder(column: $table.fromId, builder: (column) => column);

  GeneratedColumn<String> get ciphertext => $composableBuilder(
    column: $table.ciphertext,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plaintext =>
      $composableBuilder(column: $table.plaintext, builder: (column) => column);

  GeneratedColumn<int> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<bool> get delivered =>
      $composableBuilder(column: $table.delivered, builder: (column) => column);

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<bool> get isQueued =>
      $composableBuilder(column: $table.isQueued, builder: (column) => column);
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> fromId = const Value.absent(),
                Value<String> ciphertext = const Value.absent(),
                Value<String?> plaintext = const Value.absent(),
                Value<int> sentAt = const Value.absent(),
                Value<bool> delivered = const Value.absent(),
                Value<bool> read = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<bool> isQueued = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                conversationId: conversationId,
                fromId: fromId,
                ciphertext: ciphertext,
                plaintext: plaintext,
                sentAt: sentAt,
                delivered: delivered,
                read: read,
                messageId: messageId,
                isQueued: isQueued,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String conversationId,
                required String fromId,
                required String ciphertext,
                Value<String?> plaintext = const Value.absent(),
                required int sentAt,
                Value<bool> delivered = const Value.absent(),
                Value<bool> read = const Value.absent(),
                required String messageId,
                Value<bool> isQueued = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                fromId: fromId,
                ciphertext: ciphertext,
                plaintext: plaintext,
                sentAt: sentAt,
                delivered: delivered,
                read: read,
                messageId: messageId,
                isQueued: isQueued,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;
typedef $$PeerRequestsTableCreateCompanionBuilder =
    PeerRequestsCompanion Function({
      required String id,
      required String fromDeviceId,
      required int receivedAt,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$PeerRequestsTableUpdateCompanionBuilder =
    PeerRequestsCompanion Function({
      Value<String> id,
      Value<String> fromDeviceId,
      Value<int> receivedAt,
      Value<String> status,
      Value<int> rowid,
    });

class $$PeerRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $PeerRequestsTable> {
  $$PeerRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromDeviceId => $composableBuilder(
    column: $table.fromDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeerRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $PeerRequestsTable> {
  $$PeerRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromDeviceId => $composableBuilder(
    column: $table.fromDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeerRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeerRequestsTable> {
  $$PeerRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromDeviceId => $composableBuilder(
    column: $table.fromDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$PeerRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeerRequestsTable,
          PeerRequest,
          $$PeerRequestsTableFilterComposer,
          $$PeerRequestsTableOrderingComposer,
          $$PeerRequestsTableAnnotationComposer,
          $$PeerRequestsTableCreateCompanionBuilder,
          $$PeerRequestsTableUpdateCompanionBuilder,
          (
            PeerRequest,
            BaseReferences<_$AppDatabase, $PeerRequestsTable, PeerRequest>,
          ),
          PeerRequest,
          PrefetchHooks Function()
        > {
  $$PeerRequestsTableTableManager(_$AppDatabase db, $PeerRequestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeerRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeerRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeerRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromDeviceId = const Value.absent(),
                Value<int> receivedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeerRequestsCompanion(
                id: id,
                fromDeviceId: fromDeviceId,
                receivedAt: receivedAt,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromDeviceId,
                required int receivedAt,
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeerRequestsCompanion.insert(
                id: id,
                fromDeviceId: fromDeviceId,
                receivedAt: receivedAt,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeerRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeerRequestsTable,
      PeerRequest,
      $$PeerRequestsTableFilterComposer,
      $$PeerRequestsTableOrderingComposer,
      $$PeerRequestsTableAnnotationComposer,
      $$PeerRequestsTableCreateCompanionBuilder,
      $$PeerRequestsTableUpdateCompanionBuilder,
      (
        PeerRequest,
        BaseReferences<_$AppDatabase, $PeerRequestsTable, PeerRequest>,
      ),
      PeerRequest,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$PeerRequestsTableTableManager get peerRequests =>
      $$PeerRequestsTableTableManager(_db, _db.peerRequests);
}
