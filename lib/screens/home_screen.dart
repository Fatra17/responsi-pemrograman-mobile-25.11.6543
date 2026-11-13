import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../models/note.dart';
import '../providers/app_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import 'note_form_screen.dart';
import 'profile_screen.dart';

/// Alias tipe data JSON untuk item respons API.
typedef PostItem = Map<String, dynamic>;

/// Layar utama aplikasi yang menampilkan ringkasan profil, daftar catatan kuliah,
/// serta data referensi dari HTTP API publik dengan navigasi bawah.
class HomeScreen extends StatefulWidget {
  /// Konstruktor [HomeScreen].
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<PostItem> _apiPosts = [];
  bool _isApiLoading = true;
  String? _apiErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPublicPosts();
  }

  /// Mengambil daftar artikel referensi dari API publik menggunakan HTTP GET.
  Future<void> _fetchPublicPosts() async {
    setState(() {
      _isApiLoading = true;
      _apiErrorMessage = null;
    });

    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/posts?_limit=8');
      debugPrint('[HTTP] Mengirim permintaan GET ke endpoint: ${uri.path}');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-Api-Key': AppConfig.apiKey,
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('[HTTP] Status respons diterima: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
        if (!mounted) return;
        setState(() {
          _apiPosts = decoded.cast<PostItem>();
          _isApiLoading = false;
        });
      } else {
        throw HttpException('Server mengembalikan kode ${response.statusCode}');
      }
    } on SocketException {
      debugPrint('[HTTP Error] Tidak ada koneksi internet.');
      if (!mounted) return;
      setState(() {
        _apiErrorMessage = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
        _isApiLoading = false;
      });
    } on TimeoutException {
      debugPrint('[HTTP Error] Permintaan melebihi batas waktu.');
      if (!mounted) return;
      setState(() {
        _apiErrorMessage = 'Koneksi timeout. Server terlalu lama merespons.';
        _isApiLoading = false;
      });
    } catch (e) {
      debugPrint('[HTTP Error] Gagal memuat data API.');
      if (!mounted) return;
      setState(() {
        _apiErrorMessage = 'Terjadi kesalahan saat mengambil data referensi.';
        _isApiLoading = false;
      });
    }
  }

  Future<void> _navigateToAddNote() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NoteFormScreen()),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan kuliah berhasil disimpan secara terenkripsi!'),
        ),
      );
    }
  }

  void _showNoteDetailDialog(Note note) {
    final formattedDate =
        DateFormat('dd MMMM yyyy, HH:mm').format(note.createdAt);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dibuat: $formattedDate',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Divider(height: 20),
              Text(note.content),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showApiPostDetailDialog(PostItem post) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          post['title'] as String? ?? 'Detail Referensi',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ID Artikel: #${post['id']} | Author ID: ${post['userId'] ?? '-'}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              const Divider(height: 20),
              Text(
                post['body'] as String? ?? 'Tidak ada konten.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteNote(Note note, AppProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan "${note.title}"? Data terenkripsi akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteNote(note.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = AppProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.account_balance,
                size: 30,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'Catatan Kuliah',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: provider.themeMode == ThemeMode.dark
                ? 'Mode Terang'
                : 'Mode Gelap',
            icon: Icon(
              provider.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: provider.toggleTheme,
          ),
          IconButton(
            tooltip: 'Profil Mahasiswa',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: colorScheme.primaryContainer.withValues(alpha: 0.45),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.primary,
                  backgroundImage: const AssetImage('assets/images/profil.jpg'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.student.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'NIM: ${provider.student.nim} | ${provider.student.programStudi}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedIndex == 0
                ? _buildNotesTab(provider)
                : _buildApiReferenceTab(colorScheme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddNote,
        icon: const Icon(Icons.add),
        label: const Text('Catatan Baru'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Catatan Saya',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'Referensi API',
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab(AppProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.notes.isEmpty) {
      return const EmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: provider.notes.length,
      itemBuilder: (context, index) {
        final note = provider.notes[index];
        return NoteCard(
          note: note,
          onTap: () => _showNoteDetailDialog(note),
          onDelete: () => _confirmDeleteNote(note, provider),
        );
      },
    );
  }

  Widget _buildApiReferenceTab(ColorScheme colorScheme) {
    if (_isApiLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_apiErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(
                _apiErrorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _fetchPublicPosts,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchPublicPosts,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: _apiPosts.length,
        itemBuilder: (context, index) {
          final post = _apiPosts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: ListTile(
              onTap: () => _showApiPostDetailDialog(post),
              leading: CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                child: Text('${post['id']}'),
              ),
              title: Text(
                post['title'] as String? ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                post['body'] as String? ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}