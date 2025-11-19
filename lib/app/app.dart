// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:frontend/screens/auth/login_choice_screen.dart';
import 'package:frontend/screens/social/friends_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user != null && user.emailVerified) {
          return const FriendsScreen(); // 자동 로그인
        }

        return const LoginChoiceScreen(); // 로그인/회원가입 화면
      },
    );
  }
}
