import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class CryptoService {
  static final CryptoService _instance = CryptoService._internal();
  factory CryptoService() => _instance;
  CryptoService._internal();

  final _x25519 = X25519();
  final _aesGcm = AesGcm.with256bits();

  // ── Key Generation ──────────────────────────────────────────────────────────

  Future<SimpleKeyPair> generateKeyPair() async {
    return await _x25519.newKeyPair();
  }

  Future<String> exportPublicKey(SimpleKeyPair keyPair) async {
    final publicKey = await keyPair.extractPublicKey();
    return base64Encode(publicKey.bytes);
  }

  Future<String> exportPrivateKey(SimpleKeyPair keyPair) async {
    final bytes = await keyPair.extractPrivateKeyBytes();
    return base64Encode(bytes);
  }

  Future<SimpleKeyPair> importKeyPair(String privateKeyB64) async {
    final privateBytes = base64Decode(privateKeyB64);
    return await _x25519.newKeyPairFromSeed(privateBytes);
  }

  SimplePublicKey importPublicKey(String publicKeyB64) {
    final bytes = base64Decode(publicKeyB64);
    return SimplePublicKey(bytes, type: KeyPairType.x25519);
  }

  // ── Shared Secret ───────────────────────────────────────────────────────────

  Future<SecretKey> deriveSharedSecret(
    SimpleKeyPair ourKeyPair,
    String theirPublicKeyB64,
  ) async {
    final theirPublicKey = importPublicKey(theirPublicKeyB64);
    final sharedSecret = await _x25519.sharedSecretKey(
      keyPair: ourKeyPair,
      remotePublicKey: theirPublicKey,
    );
    // Derive a 256-bit AES key from the shared secret
    final sharedBytes = await sharedSecret.extractBytes();
    return SecretKey(sharedBytes);
  }

  // ── Encrypt ─────────────────────────────────────────────────────────────────

  Future<String> encrypt(String plaintext, SecretKey key) async {
    final nonce = _aesGcm.newNonce();
    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
    );
    // Pack nonce + ciphertext + mac into one base64 blob
    final combined = Uint8List.fromList([
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
    return base64Encode(combined);
  }

  // ── Decrypt ─────────────────────────────────────────────────────────────────

  Future<String> decrypt(String ciphertextB64, SecretKey key) async {
    final combined = base64Decode(ciphertextB64);

    // Unpack: 12 bytes nonce + N bytes ciphertext + 16 bytes mac
    const nonceLen = 12;
    const macLen   = 16;

    final nonce      = combined.sublist(0, nonceLen);
    final cipherText = combined.sublist(nonceLen, combined.length - macLen);
    final mac        = combined.sublist(combined.length - macLen);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(mac),
    );

    final plainBytes = await _aesGcm.decrypt(secretBox, secretKey: key);
    return utf8.decode(plainBytes);
  }
}