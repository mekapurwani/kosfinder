class Profile {
  const Profile({required this.id, required this.name, required this.role});

  final String id;
  final String name;
  final String role;

  bool get isPemilikKos => role == 'pemilik_kos';

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      role: map['role']?.toString() ?? 'pencari_kos',
    );
  }
}
