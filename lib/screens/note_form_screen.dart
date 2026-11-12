import 'package:flutter/material.dart';
import '../models/note.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';

/// Layar formulir untuk menambahkan catatan kuliah baru dengan validasi dan sanitasi.
class NoteFormScreen extends StatefulWidget {
  /// Konstruktor [NoteFormScreen].
  const NoteFormScreen({super.key});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final sanitizedTitle = Validators.sanitize(_titleController.text).trim();
    final sanitizedContent =
        Validators.sanitize(_contentController.text).trim();

    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: sanitizedTitle,
      createdAt: DateTime.now(),
      content: sanitizedContent,
    );

    await AppProvider.of(context).addNote(newNote);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Catatan Kuliah'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Judul Catatan',
                  hintText: 'Contoh: Pertemuan 4 - State Management',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: Validators.validateTitle,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 6,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan Kuliah',
                  hintText:
                      'Tuliskan ringkasan materi kuliah (minimal 10 karakter)...',
                  alignLabelWithHint: true,
                ),
                validator: Validators.validateContent,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Isi catatan akan disanitasi dan disimpan terenkripsi menggunakan Flutter Secure Storage.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _submitForm,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Catatan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}