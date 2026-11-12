/// Alias tipe map JSON.
typedef JsonMap = Map<String, dynamic>;

/// Model data yang merepresentasikan profil mahasiswa.
class Student {
  /// Nama lengkap mahasiswa.
  final String name;

  /// Nomor Induk Mahasiswa (NIM).
  final String nim;

  /// Program studi mahasiswa.
  final String programStudi;

  /// Alamat email institusi atau pribadi mahasiswa.
  final String email;

  /// URL foto profil mahasiswa (opsional, default kosong untuk memakai inisial).
  final String photoUrl;

  /// Konstruktor untuk membuat instance [Student].
  const Student({
    required this.name,
    required this.nim,
    required this.programStudi,
    required this.email,
    this.photoUrl = '',
  });

  /// Membuat salinan objek [Student] dengan pembaruan pada field tertentu.
  Student copyWith({
    String? name,
    String? nim,
    String? programStudi,
    String? email,
    String? photoUrl,
  }) {
    return Student(
      name: name ?? this.name,
      nim: nim ?? this.nim,
      programStudi: programStudi ?? this.programStudi,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  /// Mengonversi objek [Student] menjadi Map JSON untuk penyimpanan lokal.
  JsonMap toJson() {
    return {
      'name': name,
      'nim': nim,
      'programStudi': programStudi,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  /// Membuat instance [Student] dari Map JSON.
  factory Student.fromJson(JsonMap json) {
    return Student(
      name: json['name'] as String? ?? '',
      nim: json['nim'] as String? ?? '',
      programStudi: json['programStudi'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
    );
  }
}