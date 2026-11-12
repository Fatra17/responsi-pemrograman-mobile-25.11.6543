/// Kelas utilitas untuk validasi dan sanitasi input pengguna.
class Validators {
  /// Membersihkan karakter berbahaya (`<`, `>`, `"`, `'`) dari string input.
  static String sanitize(String input) {
    return input.replaceAll(RegExp(r'[<>"\x27]'), '');
  }

  /// Memvalidasi judul catatan (wajib diisi, minimal 3 karakter, maksimal 50 karakter).
  static String? validateTitle(String? value) {
    final cleaned = sanitize(value ?? '').trim();
    if (cleaned.isEmpty) {
      return 'Judul catatan wajib diisi';
    }
    if (cleaned.length < 3) {
      return 'Judul catatan minimal 3 karakter';
    }
    if (cleaned.length > 50) {
      return 'Judul catatan maksimal 50 karakter';
    }
    return null;
  }

  /// Memvalidasi isi catatan (wajib diisi, minimal 10 karakter, maksimal 1000 karakter).
  static String? validateContent(String? value) {
    final cleaned = sanitize(value ?? '').trim();
    if (cleaned.isEmpty) {
      return 'Isi catatan wajib diisi';
    }
    if (cleaned.length < 10) {
      return 'Isi catatan minimal 10 karakter';
    }
    if (cleaned.length > 1000) {
      return 'Isi catatan maksimal 1000 karakter';
    }
    return null;
  }

  /// Memvalidasi input teks umum pada profil agar tidak kosong.
  static String? validateRequired(String? value, String fieldName) {
    final cleaned = sanitize(value ?? '').trim();
    if (cleaned.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Memvalidasi format alamat email mahasiswa.
  static String? validateEmail(String? value) {
    final cleaned = sanitize(value ?? '').trim();
    if (cleaned.isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(cleaned)) {
      return 'Format email tidak valid';
    }
    return null;
  }
}