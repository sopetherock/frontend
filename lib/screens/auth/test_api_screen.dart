import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/services/api_service.dart'; // Dio wrapper

class ApiTestScreen extends StatefulWidget {
  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();

  Timer? _verifyTimer;
  bool _emailSent = false;
  bool _isVerified = false;

  @override
  void dispose() {
    _verifyTimer?.cancel();
    super.dispose();
  }

  /// 1️⃣ Firebase 회원가입 + 인증 메일 발송
  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final pw = _passwordController.text.trim();

    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pw,
      );

      await userCred.user?.sendEmailVerification();

      setState(() => _emailSent = true);

      _startVerificationPolling();
    } catch (e) {
      print("🔥 Firebase 회원가입 오류: $e");
      _showDialog("오류", "Firebase 회원가입 실패: $e");
    }
  }

  /// 2️⃣ 이메일 인증 여부 자동 감지
  void _startVerificationPolling() {
    _verifyTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = _auth.currentUser;
      if (user == null) return;

      await user.reload();
      if (user.emailVerified) {
        timer.cancel();
        setState(() => _isVerified = true);
        _registerToDb();
      }
    });
  }

  /// 3️⃣ 인증 성공 → DB 자동 등록
  Future<void> _registerToDb() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final body = {
      "firebaseUid": user.uid,
      "email": user.email,
      "username": _usernameController.text.trim(),
      "nickname": _nicknameController.text.trim(),
    };

    try {
      final res = await ApiService.dio.post("/auth/register-db", data: body);

      print("🎉 DB 등록 성공: ${res.data}");
      _showDialog("DB 등록 완료", "회원가입이 모두 완료되었습니다!");
    } catch (e) {
      if (e is DioException) {
        print("🔥 Dio Error Status: ${e.response?.statusCode}");
        print("🔥 Dio Error Body: ${e.response?.data}");

        _showDialog(
          "오류",
          "DB 등록 실패:\n${e.response?.data}",
        );
      } else {
        _showDialog("오류", "알 수 없는 오류: $e");
      }
    }
  }

  /// 📌 Dialog UI
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content.toString()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("확인")),
        ],
      ),
    );
  }

  /// 📌 가입 화면
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입 테스트")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true),
            TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username")),
            TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: "Nickname")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text("회원가입 + 이메일 인증"),
            ),
            const SizedBox(height: 20),
            if (_emailSent)
              Column(
                children: [
                  const Text("📨 인증 이메일을 확인하세요!"),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      await _auth.currentUser?.sendEmailVerification();
                    },
                    child: const Text("인증 이메일 다시 보내기"),
                  )
                ],
              ),
            if (_isVerified) const Text("✅ 이메일 인증 완료! DB 등록 중..."),
          ],
        ),
      ),
    );
  }
}
/*// lib/screens/auth/signup_screen.dart (일부)

import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // 2번에서 만든 서비스
import '../../utils/dialog.dart'; // 팝업 함수

final _authService = AuthService();

void _handleSignUp() async {
  // ... 이메일, 비밀번호 입력값 가져오기 ...
  
  try {
    await _authService.signUpAndSendVerification(email: email, password: password);
    
    // 🌟 성공 시 UI 로직: 팝업 띄우기 🌟
    showVerificationDialog(context); 

  } catch (e) {
    // ... 에러 처리
  }
}*/