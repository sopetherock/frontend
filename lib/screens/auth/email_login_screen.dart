// lib/screens/auth/email_login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/screens/social/friends_screen.dart';
import 'password_reset_screen.dart';

const pink = Color(0xFFFE4B80);

class EmailLoginScreen extends StatelessWidget {
  const EmailLoginScreen({super.key});

  Future<void> _handleLogin(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController) async {
    final email = emailController.text.trim();
    final pw = passwordController.text.trim();

    if (email.isEmpty || pw.isEmpty) {
      _showSnack(context, "이메일과 비밀번호를 입력해주세요.");
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pw,
      );

      final user = cred.user;
      if (user == null) {
        _showSnack(context, "로그인 실패: 사용자 정보가 없습니다.");
        return;
      }

      await user.reload();
      if (!user.emailVerified) {
        _showSnack(context, "이메일 인증이 완료되지 않았습니다. 메일을 확인해주세요.");
        await user.sendEmailVerification();
        return;
      }

      // ✅ 로그인 성공 → 친구 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const FriendsScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showSnack(context, "로그인 실패: ${e.message}");
    } catch (e) {
      _showSnack(context, "로그인 실패: $e");
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                iconSize: 20,
                color: Colors.black,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 100),
              const Text(
                '이메일 입력',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                ),
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 8, bottom: 4),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: pink),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '비밀번호 입력',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                ),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 8, bottom: 4),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: pink),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: () => _handleLogin(
                      context, emailController, passwordController),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PasswordResetScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '비밀번호 재설정',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
