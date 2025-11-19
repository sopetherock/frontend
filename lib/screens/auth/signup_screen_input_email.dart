<<<<<<< HEAD
import 'package:flutter/material.dart';
=======
// lib/screens/auth/signup_screen_input_email.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/services/api_service.dart';
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
import 'login_choice_screen.dart';

const Color kPink = Color(0xFFFE4B80);

class SignUpScreen_input_email extends StatefulWidget {
  const SignUpScreen_input_email({super.key});

  @override
  State<SignUpScreen_input_email> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen_input_email> {
  int _step = 1; // 1단계 / 2단계
<<<<<<< HEAD
=======
  Timer? _verifyTimer;

  final FirebaseAuth _auth = FirebaseAuth.instance;
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264

  // 1단계 입력값
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwCheckController = TextEditingController();

  // 2단계 입력값
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

<<<<<<< HEAD
=======
  // username 중복 확인 상태
  bool _usernameChecked = false;
  bool _usernameAvailable = false;

>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    _pwCheckController.dispose();
    _idController.dispose();
    _nicknameController.dispose();
<<<<<<< HEAD
    super.dispose();
  }

=======
    _verifyTimer?.cancel();
    super.dispose();
  }

  // ----------------------------------------------------
  // 1단계: Firebase 계정 생성 + 인증 메일 발송
  // ----------------------------------------------------
  Future<void> _createFirebaseAccount() async {
    final email = _emailController.text.trim();
    final pw = _pwController.text.trim();
    final pwCheck = _pwCheckController.text.trim();

    if (email.isEmpty || pw.isEmpty || pwCheck.isEmpty) {
      _showDialog("오류", "모든 칸을 입력해주세요.");
      return;
    }

    if (pw != pwCheck) {
      _showDialog("오류", "비밀번호가 일치하지 않습니다.");
      return;
    }

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pw,
      );

      await cred.user?.sendEmailVerification();

      _showDialog(
        "인증 메일 발송",
        "입력하신 이메일로 인증 메일을 보냈습니다.\n메일을 확인하고 인증을 완료해주세요.",
      );

      _startVerifyPolling();
    } on FirebaseAuthException catch (e) {
      _showDialog("오류", "회원가입 실패: ${e.message}");
    } catch (e) {
      _showDialog("오류", "회원가입 실패: $e");
    }
  }

  // 이메일 인증 완료 여부 폴링
  void _startVerifyPolling() {
    _verifyTimer?.cancel();

    _verifyTimer =
        Timer.periodic(const Duration(seconds: 3), (Timer timer) async {
      final user = _auth.currentUser;
      if (user == null) return;
      await user.reload();

      if (user.emailVerified) {
        timer.cancel();
        setState(() {
          _step = 2;
        });
        _showDialog("이메일 인증 완료", "아이디와 닉네임을 입력해주세요.");
      }
    });
  }

  // ----------------------------------------------------
  // username 중복 확인: /api/auth/check-username/:username
  // ----------------------------------------------------
  Future<void> _checkUsernameDuplicate() async {
    final username = _idController.text.trim();

    if (username.length < 4) {
      _showDialog("오류", "아이디는 최소 4자 이상이어야 합니다.");
      return;
    }

    try {
      final res = await ApiService.dio.get("/auth/check-username/$username");
      final available = res.data["available"] == true;

      setState(() {
        _usernameChecked = true;
        _usernameAvailable = available;
      });

      if (available) {
        _showDialog("사용 가능", "사용할 수 있는 아이디입니다.");
      } else {
        _showDialog("사용 불가", "이미 사용 중인 아이디입니다.");
      }
    } catch (e) {
      _showDialog("오류", "중복 확인 실패: $e");
    }
  }

  // ----------------------------------------------------
  // 2단계: 백엔드 DB 등록 (/auth/register-db)
  // ----------------------------------------------------
  Future<void> _registerToBackend() async {
    final user = _auth.currentUser;

    if (user == null) {
      _showDialog("오류", "로그인 정보가 없습니다. 다시 시도해주세요.");
      return;
    }

    if (!user.emailVerified) {
      _showDialog("오류", "이메일 인증이 완료되지 않았습니다.");
      return;
    }

    final username = _idController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (username.isEmpty || nickname.isEmpty) {
      _showDialog("오류", "아이디와 닉네임을 모두 입력해주세요.");
      return;
    }

    if (!_usernameChecked || !_usernameAvailable) {
      _showDialog("오류", "아이디 중복확인을 먼저 진행해주세요.");
      return;
    }

    final body = {
      "firebaseUid": user.uid,
      "email": user.email,
      "username": username,
      "nickname": nickname,
    };

    try {
      final res = await ApiService.dio.post("/auth/register-db", data: body);

      _showDialog("가입 완료", "회원가입이 완료되었습니다.");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginChoiceScreen()),
      );
    } catch (e) {
      _showDialog("오류", "DB 등록 실패: $e");
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text("확인"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // UI
  // ----------------------------------------------------
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
  @override
  Widget build(BuildContext context) {
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

              // 뒤로가기
=======
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                iconSize: 20,
                color: Colors.black,
                onPressed: () {
                  if (_step == 1) {
<<<<<<< HEAD
                    Navigator.pop(context); // 제일 처음이면 이전 화면으로
                  } else {
                    setState(() {
                      _step = 1; // 2단계에서 뒤로 누르면 1단계로 돌아가기
=======
                    Navigator.pop(context);
                  } else {
                    setState(() {
                      _step = 1;
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
                    });
                  }
                },
              ),
<<<<<<< HEAD

              const SizedBox(height: 60),

              // 제목: zeus on 가입하기
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'zeus on',
                        style: TextStyle(
                          fontFamily: 'Modulus', // pubspec에 등록된 폰트 기준
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.04,
                          height: 37 / 36,
                          color: kPink,
                        ),
                      ),
                      Text(
                        '회원가입',
                        style: TextStyle(
                          fontFamily: 'Modulus', // pubspec에 등록된 폰트 기준
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.04,
                          height: 37 / 36,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  )),

              const SizedBox(height: 100),

              // 🔥 여기에서 step에 따라 다른 입력 폼 보여주기
              if (_step == 1) _buildStep1() else _buildStep2(),

              const SizedBox(height: 80),

              // 버튼도 step에 따라 텍스트/동작 변경
=======
              const SizedBox(height: 60),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'zeus on',
                      style: TextStyle(
                        fontFamily: 'Modulus',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.04,
                        height: 37 / 36,
                        color: kPink,
                      ),
                    ),
                    Text(
                      '회원가입',
                      style: TextStyle(
                        fontFamily: 'Modulus',
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.04,
                        height: 37 / 36,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
              if (_step == 1) _buildStep1() else _buildStep2(),
              const SizedBox(height: 80),
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: () {
                    if (_step == 1) {
<<<<<<< HEAD
                      // TODO: 이메일/비번 검증 넣어도 됨
                      setState(() {
                        _step = 2;
                      });
                    } else {
                      // TODO: 여기서 최종 회원가입 처리
                      // 예시로 팝업만 띄움
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('회원가입 완료'),
                            content: const Text('회원가입이 완료되었습니다.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // 팝업 닫기
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const LoginChoiceScreen())); // 회원가입 화면 닫기
                                },
                                child: const Text('확인'),
                              ),
                            ],
                          );
                        },
                      );
=======
                      _createFirebaseAccount();
                    } else {
                      _registerToBackend();
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _step == 1 ? '다음' : '회원가입',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
<<<<<<< HEAD

=======
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  /// 1단계: 이메일 + 비밀번호
=======
  /// 1단계 UI
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이메일 입력',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
<<<<<<< HEAD
        TextField(
          controller: _emailController,
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
              borderSide: BorderSide(color: kPink),
            ),
          ),
        ),
=======
        _underlineTextField(_emailController),
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
        const SizedBox(height: 30),
        const Text(
          '비밀번호 입력',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
<<<<<<< HEAD
        TextField(
          controller: _pwController,
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
              borderSide: BorderSide(color: kPink),
            ),
          ),
        ),
=======
        _underlineTextField(_pwController, obscure: true),
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
        const SizedBox(height: 30),
        const Text(
          '비밀번호 확인',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
<<<<<<< HEAD
        TextField(
          controller: _pwCheckController,
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
              borderSide: BorderSide(color: kPink),
            ),
          ),
        ),
=======
        _underlineTextField(_pwCheckController, obscure: true),
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
      ],
    );
  }

<<<<<<< HEAD
  /// 2단계: 아이디 + 닉네임
=======
  /// 2단계 UI
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
<<<<<<< HEAD
        // 아이디 입력 + 중복확인
=======
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
        Row(
          children: [
            const Text(
              '아이디 입력',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
              ),
            ),
            const Spacer(),
            TextButton(
<<<<<<< HEAD
              onPressed: () {
                // TODO: 중복확인
              },
=======
              onPressed: _checkUsernameDuplicate,
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '중복확인',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                ),
              ),
            ),
          ],
        ),
<<<<<<< HEAD
        TextField(
          controller: _idController,
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
              borderSide: BorderSide(color: kPink),
            ),
          ),
        ),

        const SizedBox(height: 32),

=======
        _underlineTextField(_idController),
        const SizedBox(height: 32),
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
        const Text(
          '닉네임 입력',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
<<<<<<< HEAD
        TextField(
          controller: _nicknameController,
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
              borderSide: BorderSide(color: kPink),
            ),
          ),
        ),
      ],
    );
  }
=======
        _underlineTextField(_nicknameController),
      ],
    );
  }

  Widget _underlineTextField(TextEditingController c, {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
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
          borderSide: BorderSide(color: kPink),
        ),
      ),
    );
  }
>>>>>>> 88b4e47a19aa3edd21cfa882f093bb8d78a70264
}
