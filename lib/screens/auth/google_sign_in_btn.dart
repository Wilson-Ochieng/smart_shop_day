import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smartshop/models/user_model.dart';
import 'package:smartshop/wigets/google_btn.dart';

class GoogleButtonScreen extends StatelessWidget {
  const GoogleButtonScreen({super.key});

  Future<void> _googleSignIn({required BuildContext context}) async {
    try {
      UserCredential authResults;
      if (kIsWeb) {
        final GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
        authResults = await FirebaseAuth.instance.signInWithPopup(
          googleAuthProvider,
        );
      } else {
        final googleSignIn = GoogleSignIn();

        final googleAccount = await googleSignIn.signIn();
        if (googleAccount == null) return;
        final googleAuth = await googleAccount.authentication;
        if (googleAuth.idToken == null) {
          throw FirebaseAuthException(
            code: "ERROR_NO_ID_TOKEN",
            message: "Missing Google ID Token",
          );
        }
        authResults = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          ),
        );
      }



            final isNewUser =
          authResults.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        final user = authResults.user!;
        final newUser = UserModel(
          uid: user.uid,
          username: user.displayName ?? '',
          email: user.email ?? '',
          role: 'user',
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(newUser.toMap());
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return  GoogleBtn(onpressed: () { _googleSignIn(context: context); },
      
    );
  }
}
