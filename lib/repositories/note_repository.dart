import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import '../models/student.dart';
import '../services/secure_storage_service.dart';

/// Alias tipe daftar catatan kuliah.
typedef NoteList = List<Note>;

/// Repository untuk mengelola persistensi metadata catatan di [SharedPreferences]
/// dan isi catatan terenkripsi di [SecureStorageService].
class NoteRepository {
  static const String _notesMetadataKey = 'notes_metadata_list';
  static const String _studentProfileKey = 'student_profile_data';

  final SecureStorageService _secureStorage;

  /// Konstruktor [NoteRepository] dengan injeksi [SecureStorageService].
  NoteRepository({SecureStorageService? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorageService();

  /// Mengambil seluruh daftar catatan beserta isi yang telah didekripsi.
  Future<NoteList> getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_notesMetadataKey) ?? [];

    final List<Note> notes = [];
    for (final item in rawList) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      final id = map['id'] as String;
      final decryptedContent = await _secureStorage.getContent(id) ?? '';
      notes.add(Note.fromMetadataJson(map, content: decryptedContent));
    }

    debugPrint('[NoteRepository] Memuat ${notes.length} catatan kuliah.');
    return notes;
  }

  /// Menyimpan metadata catatan ke [SharedPreferences] dan isinya ke secure storage.
  Future<void> addNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_notesMetadataKey) ?? [];

    rawList.insert(0, jsonEncode(note.toMetadataJson()));
    await prefs.setStringList(_notesMetadataKey, rawList);
    await _secureStorage.saveContent(note.id, note.content);

    debugPrint('[NoteRepository] Catatan baru ditambahkan (ID: ${note.id}).');
  }

  /// Menghapus metadata catatan dari [SharedPreferences] dan isinya dari secure storage.
  Future<void> deleteNote(String noteId) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_notesMetadataKey) ?? [];

    rawList.removeWhere((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return map['id'] == noteId;
    });

    await prefs.setStringList(_notesMetadataKey, rawList);
    await _secureStorage.deleteContent(noteId);

    debugPrint('[NoteRepository] Catatan dihapus (ID: $noteId).');
  }

  /// Memuat data profil mahasiswa tersimpan jika tersedia.
  Future<Student?> getSavedStudent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_studentProfileKey);
    if (raw == null) return null;
    return Student.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Menyimpan pembaruan data profil mahasiswa ke [SharedPreferences].
  Future<void> saveStudent(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentProfileKey, jsonEncode(student.toJson()));
    debugPrint('[NoteRepository] Profil mahasiswa diperbarui.');
  }
}