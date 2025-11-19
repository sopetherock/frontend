import 'package:flutter/material.dart';
import '../auth/terms_aggreement_screens.dart';
import 'email_login_screen.dart';

const pink = Color(0xFFFE4B80);

class LoginChoiceScreen extends StatelessWidget {
  const LoginChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ← 뒤로가기
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                iconSize: 20,
                color: Colors.black,
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 60),

            // 제목: zeus on 로그인 하기
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
                        color: pink,
                      ),
                    ),
                    Text(
                      '로그인',
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

            // 이메일 / 카카오 로그인 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EmailLoginScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD3D3D3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text(
                        '이메일로 로그인하기',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: 카카오톡 로그인 플로우
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD3D3D3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text(
                        '카카오톡으로 로그인하기',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 개인정보 처리방침 / 이용약관
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '개인정보 처리방침',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '·',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '이용약관',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            Center(
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TermsAgreementScreen()));
                    },
                    child: const Text(
                      '처음이신가요? 회원가입 하기',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 104, 104, 104),
                      ),
                    )))
          ],
        ),
      ),
    );
  }
}
