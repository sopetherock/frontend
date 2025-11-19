import 'package:flutter/material.dart';
import 'login_choice_screen.dart';

const Color kPink = Color(0xFFFE4B80);

class SignUpScreen_input_email extends StatefulWidget {
  const SignUpScreen_input_email({super.key});

  @override
  State<SignUpScreen_input_email> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen_input_email> {
  int _step = 1; // 1단계 / 2단계

  // 1단계 입력값
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwCheckController = TextEditingController();

  // 2단계 입력값
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    _pwCheckController.dispose();
    _idController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

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

              // 뒤로가기
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                iconSize: 20,
                color: Colors.black,
                onPressed: () {
                  if (_step == 1) {
                    Navigator.pop(context); // 제일 처음이면 이전 화면으로
                  } else {
                    setState(() {
                      _step = 1; // 2단계에서 뒤로 누르면 1단계로 돌아가기
                    });
                  }
                },
              ),

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
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: () {
                    if (_step == 1) {
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

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// 1단계: 이메일 + 비밀번호
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
      ],
    );
  }

  /// 2단계: 아이디 + 닉네임
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 아이디 입력 + 중복확인
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
              onPressed: () {
                // TODO: 중복확인
              },
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

        const Text(
          '닉네임 입력',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
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
}
