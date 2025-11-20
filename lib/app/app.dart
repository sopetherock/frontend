import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/screens/timer/personal_timer_screen.dart';
import 'package:frontend/screens/auth/login_choice_screen.dart';
import 'package:frontend/screens/social/friends_screen.dart';
import '../screens/home/home_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        if (user != null && user.emailVerified) {
          return HomeDashboardScreen(); 
        }

        return const LoginChoiceScreen();
      },
    );
  }
}

