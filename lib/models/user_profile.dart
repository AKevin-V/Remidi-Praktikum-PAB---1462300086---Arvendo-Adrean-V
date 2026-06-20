class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String instagram;
  final String photoUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.instagram,
    required this.photoUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String docId) {
    return UserProfile(
      uid: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      instagram: map['instagram'] ?? '',
      photoUrl: map['photoUrl'] ?? r'C:\Users\User\Downloads\Foto Formal Santai 2.png',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'instagram': instagram,
      'photoUrl': photoUrl,
    };
  }
}
