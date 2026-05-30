import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class GoogleBtn extends StatelessWidget {
  final VoidCallback onpressed;

  const GoogleBtn({super.key,required this.onpressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: 5,
        padding: const EdgeInsets.all(14.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      icon: const Icon(Ionicons.logo_google, color: Colors.red),
      label: const Text(
        "Sign with Google",
        style: TextStyle(color: Colors.black),
      ),
      onPressed: onpressed,
    );
  }
}
