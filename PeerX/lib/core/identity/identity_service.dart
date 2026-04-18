import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:cryptography/cryptography.dart';
import '../crypto/crypto_service.dart';

class IdentityService {
  static final IdentityService _instance = IdentityService._internal();
  factory IdentityService() => _instance;
  IdentityService._internal();

  static const _keyDeviceId   = 'peerx_device_id';
  static const _keyPrivateKey = 'peerx_private_key';
  static const _keyPublicKey  = 'peerx_public_key';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  final _crypto     = CryptoService();
  final _deviceInfo = DeviceInfoPlugin();

  String?        _deviceId;
  String?        _publicKey;
  SimpleKeyPair? _keyPair;

  // ── Init ────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    _deviceId  = await _storage.read(key: _keyDeviceId);
    _publicKey = await _storage.read(key: _keyPublicKey);

    if (_deviceId == null || _publicKey == null) {
      await _generateIdentity();
    } else {
      final privateKeyB64 = await _storage.read(key: _keyPrivateKey);
      if (privateKeyB64 != null) {
        _keyPair = await _crypto.importKeyPair(privateKeyB64);
      } else {
        await _generateIdentity();
      }
    }
  }

  // ── Getters ─────────────────────────────────────────────────────────────────

  String get deviceId {
    assert(_deviceId != null, 'IdentityService not initialized');
    return _deviceId!;
  }

  String get publicKey {
    assert(_publicKey != null, 'IdentityService not initialized');
    return _publicKey!;
  }

  SimpleKeyPair get keyPair {
    assert(_keyPair != null, 'IdentityService not initialized');
    return _keyPair!;
  }

  // ── Private ─────────────────────────────────────────────────────────────────

  Future<void> _generateIdentity() async {
    // 1. Generate keypair
    _keyPair            = await _crypto.generateKeyPair();
    _publicKey          = await _crypto.exportPublicKey(_keyPair!);
    final privateKeyB64 = await _crypto.exportPrivateKey(_keyPair!);

    // 2. Derive stable device ID from hardware salt + random UUID
    final salt     = await _getHardwareSalt();
    final uuid     = const Uuid().v4();
    final combined = '$salt:$uuid';
    final hash     = sha256.convert(utf8.encode(combined));
    _deviceId      = hash.toString().substring(0, 32);

    // 3. Persist to keychain
    await _storage.write(key: _keyDeviceId,   value: _deviceId);
    await _storage.write(key: _keyPublicKey,  value: _publicKey);
    await _storage.write(key: _keyPrivateKey, value: privateKeyB64);
  }

  Future<String> _getHardwareSalt() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return '${info.brand}:${info.model}:${info.id}';
      } else {
        final info = await _deviceInfo.iosInfo;
        return '${info.model}:${info.systemVersion}:${info.identifierForVendor}';
      }
    } catch (_) {
      return 'fallback-salt';
    }
  }
}