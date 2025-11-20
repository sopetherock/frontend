import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/CustomBottomNavigationBar.dart';
import '../auth/login_choice_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  // 로그아웃 처리 함수
  Future<void> _handleLogout(BuildContext context) async {
    try {
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'accessToken');
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginChoiceScreen()),
        (route) => false,
      );
    } catch (e) {
      print("로그아웃 에러: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color _primaryPink = const Color(0xFFFE4B80);

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ 헤더 고정
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: PinkHeader(title: '마이페이지'),
      ),

      // ✅ 네비 바 고정
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // 프로필 영역
                Center(
                  child: Column(
                    children: [
                      // 노란 원 + 아이콘
                      Container(
                        width: 107,
                        height: 107,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: lightYellow,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_outline,
                            size: 58,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '유준희',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'junheelove',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB6B6B6),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 번개 모으기 카드
                Center(
                  child: Container(
                    width: 89,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color.fromARGB(255, 232, 232, 232),
                          width: 1.2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/_lighting.png',
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '번개 모으기',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 회색 구분선 1
                _GreyDivider(color: dividerColor),

                // 알림 섹션
                const _SectionTitle(title: '알림'),
                const _SettingRow(title: '앱 알림 설정'),

                _GreyDivider(color: dividerColor),

                // 계정 섹션
                const _SectionTitle(title: '계정'),
                const _SettingRow(title: '내 정보'),
                const _LogoutRow(title: '로그아웃'),

                _GreyDivider(color: dividerColor),

                // 정보 섹션
                const _SectionTitle(title: '정보'),
                const _SettingRow(title: '이용 약관'),

                // 하단 네비게이션 영역과 높이 맞추려고 약간 여백
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------- 커스텀 위젯들 --------------- //

/// 회색 가로 바 (Rectangle 128, 129, 145)
class _GreyDivider extends StatelessWidget {
  final Color color;
  const _GreyDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7,
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: const Color(0xFFB6B6B6), width: 0.2),
      ),
    );
  }
}
