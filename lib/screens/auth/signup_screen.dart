// lib/screens/auth/signup_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/screens/social/friends_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/dialog.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Timer? _verifyTimer;

  @override
  void dispose() {
    _verifyTimer?.cancel();
    super.dispose();
  }

  // -----------------------------------------------------
  // 1) 회원가입 + 인증 메일 발송
  // -----------------------------------------------------
  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 인증 메일 발송
      await userCred.user?.sendEmailVerification();

      // 인증 안내 다이얼로그 (UI는 동일)
      showVerificationDialog(context);

      // 인증 여부 자동 체크 시작
      _startVerificationPolling();
    } catch (e) {
      print("회원가입 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입 실패: $e")),
      );
    }
  }

  // -----------------------------------------------------
  // 2) 이메일 인증 완료 자동 체크
  // -----------------------------------------------------
  void _startVerificationPolling() {
    _verifyTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await user.reload();
      if (user.emailVerified) {
        timer.cancel();
        _registerToDb();
      }
    });
  }

  // -----------------------------------------------------
  // 3) 인증 완료 → 백엔드 DB 자동 등록
  // -----------------------------------------------------
  Future<void> _registerToDb() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final body = {
      "firebaseUid": user.uid,
      "email": user.email,
      "username": user.email!.split("@")[0], // 기본 아이디: 이메일 앞부분
      "nickname": "user_${user.uid.substring(0, 6)}", // 기본 닉네임
    };

    try {
      await ApiService.dio.post("/auth/register-db", data: body);

      // 등록 완료 → 친구 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const FriendsScreen()),
        (route) => false,
      );
    } catch (e) {
      print("DB 등록 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("DB 등록 실패: $e")),
      );
    }
  }

  // -----------------------------------------------------
  // UI (절대 변경 없음)
  // -----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _emailController),
            TextField(controller: _passwordController, obscureText: true),
            ElevatedButton(
              onPressed: _handleSignUp,
              child: Text("회원가입"),
            ),
          ],
        ),
      ),
    );
  }
}
