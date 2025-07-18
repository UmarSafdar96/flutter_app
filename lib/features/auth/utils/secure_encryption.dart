import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math';

class SecureEncryptionService {
  static const _keyStorageKey = 'encryption_key';
  final FlutterSecureStorage _secureStorage;
  final IV _iv;

  SecureEncryptionService()
      : _secureStorage = const FlutterSecureStorage(),
        _iv = IV.fromLength(16); // In production, use random IVs and store them with ciphertext

  /// Generates a new AES-256 key, stores it securely, and returns it as a base64 string.
  Future<String> _generateAndStoreKey() async {
    final key = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    final base64Key = base64UrlEncode(key);
    await _secureStorage.write(key: _keyStorageKey, value: base64Key);
    return base64Key;
  }

  /// Retrieves the AES key from secure storage or generates a new one.
  Future<String> _getKey() async {
    return await _secureStorage.read(key: _keyStorageKey) ?? await _generateAndStoreKey();
  }

  /// Encrypts the given [plainText] and returns the encrypted base64 string.
  Future<String> encrypt(String plainText) async {
    final base64Key = await _getKey();
    final key = Key.fromBase64(base64Key);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypts the given base64 [encryptedText] and returns the original plain text.
  Future<String> decrypt(String encryptedText) async {
    final base64Key = await _getKey();
    final key = Key.fromBase64(base64Key);
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }
}
