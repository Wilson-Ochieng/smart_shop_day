
class UserModel {
  final String uid;
  final String username;
  final String email;

  final String role;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,

    required this.role,
  });

  factory UserModel.fromDocument(String uid, Map<String, dynamic> doc) {
    return UserModel(
      uid: uid,
      username: doc['username'] ?? '',
      email: doc['email'] ?? '',
      role: doc['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'username': username, 'email': email, 'role': role};
  }
}
