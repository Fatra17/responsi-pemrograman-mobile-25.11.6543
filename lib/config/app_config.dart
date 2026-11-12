import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Kelas konfigurasi aplikasi yang memuat variabel lingkungan dari file `.env`.
class AppConfig {
  /// Mengambil URL dasar API publik dari environment variable `BASE_URL`.
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://jsonplaceholder.typicode.com';

  /// Mengambil kunci API dummy dari environment variable `API_KEY`.
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
}