import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';

/// Titik masuk utama aplikasi Profil Mahasiswa dengan Catatan Kuliah.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

/// Widget root aplikasi yang mengatur [ThemeData] terang/gelap dan [AppProviderWrapper].
class MyApp extends StatelessWidget {
  /// Konstruktor [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF4A148C);

    return AppProviderWrapper(
      child: Builder(
        builder: (context) {
          final provider = AppProvider.of(context);

          return MaterialApp(
            title: 'Profil Mahasiswa & Catatan Kuliah',
            debugShowCheckedModeBanner: false,
            themeMode: provider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: seedColor,
                brightness: Brightness.light,
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: seedColor,
                brightness: Brightness.dark,
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}