import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartshop/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get getUser => _user;

  bool get isLoggedIn => _user != null;

  String get role => _user?.role ?? 'guest';

  bool get isAdmin => _user?.role == 'admin';

  bool get isRegularUser => _user?.role == 'user';

  Future<String?> register({
    required String username,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      final userCredentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      final newUser = UserModel(
        uid: userCredentials.user!.uid,
        username: username.trim(),
        email: email.trim(),
        role: role,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      await userCredentials.user!.sendEmailVerification();

      _user = newUser;
      notifyListeners();

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Registration failed";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> fetchUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _user = null;
      notifyListeners();
      return;
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        _user = UserModel.fromDocument(
          currentUser.uid,
          docSnapshot.data() as Map<String, dynamic>,
        );
      } else {
        _user = UserModel(
          uid: currentUser.uid,
          username: currentUser.displayName ?? '',
          email: currentUser.email ?? '',
          role: 'user',
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching user: $e");
      rethrow;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await fetchUser();

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Login failed";
    } catch (e) {
      return e.toString();
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
