import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/student.dart';
import '../repositories/note_repository.dart';

/// [InheritedWidget] untuk mendistribusikan state profil, catatan, dan tema aplikasi.
class AppProvider extends InheritedWidget {
  /// Data profil mahasiswa aktif.
  final Student student;

  /// Daftar catatan kuliah aktif.
  final List<Note> notes;

  /// Status pemuatan awal data dari penyimpanan lokal.
  final bool isLoading;

  /// Mode tema aktif ([ThemeMode.light] atau [ThemeMode.dark]).
  final ThemeMode themeMode;

  /// Fungsi callback untuk memperbarui data profil mahasiswa.
  final Function(Student) updateStudent;

  /// Fungsi callback untuk menambahkan catatan kuliah baru.
  final Function(Note) addNote;

  /// Fungsi callback untuk menghapus catatan kuliah berdasarkan ID.
  final Function(String) deleteNote;

  /// Fungsi callback untuk beralih antara mode terang dan mode gelap.
  final VoidCallback toggleTheme;

  /// Konstruktor [AppProvider].
  const AppProvider({
    super.key,
    required this.student,
    required this.notes,
    required this.isLoading,
    required this.themeMode,
    required this.updateStudent,
    required this.addNote,
    required this.deleteNote,
    required this.toggleTheme,
    required super.child,
  });

  /// Mengambil instance [AppProvider] terdekat dari pohon widget.
  static AppProvider of(BuildContext context) {
    final AppProvider? result =
        context.dependOnInheritedWidgetOfExactType<AppProvider>();
    assert(result != null, 'AppProvider tidak ditemukan dalam context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppProvider oldWidget) {
    return student != oldWidget.student ||
        notes != oldWidget.notes ||
        isLoading != oldWidget.isLoading ||
        themeMode != oldWidget.themeMode;
  }
}

/// Widget pengelola state ([StatefulWidget]) yang membungkus subtree dengan [AppProvider].
class AppProviderWrapper extends StatefulWidget {
  /// Widget anak yang akan menerima akses ke [AppProvider].
  final Widget child;

  /// Konstruktor [AppProviderWrapper].
  const AppProviderWrapper({super.key, required this.child});

  @override
  State<AppProviderWrapper> createState() => _AppProviderWrapperState();
}

class _AppProviderWrapperState extends State<AppProviderWrapper> {
  final NoteRepository _repository = NoteRepository();

  Student _student = const Student(
    name: 'Fatra Abby Nur Alwizza',
    nim: '25.11.6543',
    programStudi: 'S1 Informatika',
    email: 'fatra.6543@students.amikom.ac.id',
  );

  List<Note> _notes = [];
  bool _isLoading = true;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final savedStudent = await _repository.getSavedStudent();
    final loadedNotes = await _repository.getAllNotes();
    if (!mounted) return;
    setState(() {
      if (savedStudent != null) {
        _student = savedStudent;
      }
      _notes = loadedNotes;
      _isLoading = false;
    });
  }

  Future<void> _updateStudent(Student updatedStudent) async {
    await _repository.saveStudent(updatedStudent);
    if (!mounted) return;
    setState(() {
      _student = updatedStudent;
    });
  }

  Future<void> _addNote(Note newNote) async {
    await _repository.addNote(newNote);
    final refreshedNotes = await _repository.getAllNotes();
    if (!mounted) return;
    setState(() {
      _notes = refreshedNotes;
    });
  }

  Future<void> _deleteNote(String noteId) async {
    await _repository.deleteNote(noteId);
    if (!mounted) return;
    setState(() {
      _notes = _notes.where((note) => note.id != noteId).toList();
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppProvider(
      student: _student,
      notes: _notes,
      isLoading: _isLoading,
      themeMode: _themeMode,
      updateStudent: _updateStudent,
      addNote: _addNote,
      deleteNote: _deleteNote,
      toggleTheme: _toggleTheme,
      child: widget.child,
    );
  }
}