<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'password_reset_screen.dart';
import '../mypage/mypage_screen.dart';
=======
// lib/screens/auth/email_login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/screens/social/friends_screen.dart';
import 'password_reset_screen.dart';
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264

const pink = Color(0xFFFE4B80);

class EmailLoginScreen extends StatelessWidget {
  const EmailLoginScreen({super.key});

<<<<<<< HEAD
=======
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

>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
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
<<<<<<< HEAD

              // ← 뒤로가기
=======
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                iconSize: 20,
                color: Colors.black,
                onPressed: () => Navigator.pop(context),
              ),
<<<<<<< HEAD

              const SizedBox(height: 100),

              // 이메일 입력
=======
              const SizedBox(height: 100),
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
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
<<<<<<< HEAD

              const SizedBox(height: 24),

              // 비밀번호 입력
=======
              const SizedBox(height: 24),
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
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
<<<<<<< HEAD

              const SizedBox(height: 80),

              // 로그인 버튼
=======
              const SizedBox(height: 80),
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
<<<<<<< HEAD
                  onPressed: () {
                    // TODO: 실제 로그인 처리 (API 호출 등)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyPageScreen(),
                      ),
                    );
                  },
=======
                  onPressed: () => _handleLogin(
                      context, emailController, passwordController),
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
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
<<<<<<< HEAD

              const SizedBox(height: 16),

              // 비밀번호 재설정
=======
              const SizedBox(height: 16),
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
<<<<<<< HEAD
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PasswordResetScreen()));
=======
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PasswordResetScreen(),
                        ),
                      );
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
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
<<<<<<< HEAD

              const Spacer(),

              const SizedBox(height: 8), // 하단 여백 (home indicator 느낌)
=======
              const Spacer(),
              const SizedBox(height: 8),
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
            ],
          ),
        ),
      ),
    );
  }
}
