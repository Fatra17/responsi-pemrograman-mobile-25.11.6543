import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Layanan penyimpanan terenkripsi menggunakan [FlutterSecureStorage].
class SecureStorageService {
  final FlutterSecureStorage _storage;

  /// Konstruktor [SecureStorageService] dengan opsi enkripsi Android aktif.
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  String _buildKey(String noteId) => 'note_content_$noteId';

  /// Menyimpan isi catatan secara terenkripsi berdasarkan [noteId].
  Future<void> saveContent(String noteId, String content) async {
    await _storage.write(key: _buildKey(noteId), value: content);
    debugPrint('[SecureStorage] Isi catatan disimpan untuk ID: $noteId');
  }

  /// Membaca isi catatan terenkripsi berdasarkan [noteId].
  Future<String?> getContent(String noteId) async {
    return await _storage.read(key: _buildKey(noteId));
  }

  /// Menghapus isi catatan terenkripsi berdasarkan [noteId].
  Future<void> deleteContent(String noteId) async {
    await _storage.delete(key: _buildKey(noteId));
    debugPrint('[SecureStorage] Isi catatan dihapus untuk ID: $noteId');
  }
}
