/// Alias tipe map JSON.
typedef NoteJsonMap = Map<String, dynamic>;

/// Model data untuk catatan kuliah yang memisahkan metadata dan isi terenkripsi.
class Note {
  /// Pengenal unik catatan (berbasis timestamp).
  final String id;

  /// Judul catatan kuliah.
  final String title;

  /// Waktu pembuatan catatan.
  final DateTime createdAt;

  /// Isi catatan kuliah (disimpan terpisah di secure storage).
  final String content;

  /// Konstruktor untuk membuat instance [Note].
  const Note({
    required this.id,
    required this.title,
    required this.createdAt,
    this.content = '',
  });

  /// Mengonversi hanya metadata catatan (tanpa [content]) ke Map JSON.
  NoteJsonMap toMetadataJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Membuat instance [Note] dari metadata JSON dan isi catatan terenkripsi.
  factory Note.fromMetadataJson(
    NoteJsonMap json, {
    String content = '',
  }) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      content: content,
    );
  }
}