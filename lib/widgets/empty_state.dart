import 'package:flutter/material.dart';

/// Widget modular untuk menampilkan tampilan saat daftar catatan masih kosong.
class EmptyState extends StatelessWidget {
  /// Judul informasi keadaan kosong.
  final String title;

  /// Deskripsi petunjuk bagi pengguna.
  final String subtitle;

  /// Ikon ilustrasi keadaan kosong.
  final IconData icon;

  /// Konstruktor [EmptyState].
  const EmptyState({
    super.key,
    this.title = 'Belum Ada Catatan Kuliah',
    this.subtitle =
        'Tekan tombol Catatan Baru di pojok kanan bawah untuk membuat catatan terenkripsi.',
    this.icon = Icons.note_alt_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}