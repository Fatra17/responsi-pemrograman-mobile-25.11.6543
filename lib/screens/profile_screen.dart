import 'package:flutter/material.dart';
import '../models/student.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';
import '../widgets/profile_card.dart';

/// Layar untuk menampilkan dan mengubah informasi profil mahasiswa.
class ProfileScreen extends StatelessWidget {
  /// Konstruktor [ProfileScreen].
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, AppProvider provider) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: provider.student.name);
    final nimController = TextEditingController(text: provider.student.nim);
    final prodiController =
        TextEditingController(text: provider.student.programStudi);
    final emailController = TextEditingController(text: provider.student.email);
    final photoController =
        TextEditingController(text: provider.student.photoUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Profil Mahasiswa',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (val) =>
                        Validators.validateRequired(val, 'Nama lengkap'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nimController,
                    decoration: const InputDecoration(
                      labelText: 'NIM',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (val) => Validators.validateRequired(val, 'NIM'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: prodiController,
                    decoration: const InputDecoration(
                      labelText: 'Program Studi',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    validator: (val) =>
                        Validators.validateRequired(val, 'Program studi'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: photoController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'URL Foto Profil (Opsional)',
                      hintText: 'Kosongkan untuk memakai inisial nama',
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final updated = Student(
                                name: Validators.sanitize(
                                    nameController.text.trim()),
                                nim: Validators.sanitize(
                                    nimController.text.trim()),
                                programStudi: Validators.sanitize(
                                    prodiController.text.trim()),
                                email: Validators.sanitize(
                                    emailController.text.trim()),
                                photoUrl: Validators.sanitize(
                                    photoController.text.trim()),
                              );
                              provider.updateStudent(updated);
                              Navigator.pop(sheetContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profil mahasiswa diperbarui'),
                                ),
                              );
                            }
                          },
                          child: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = AppProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ProfileCard(
          student: provider.student,
          onEditPressed: () => _showEditProfileDialog(context, provider),
        ),
      ),
    );
  }
}