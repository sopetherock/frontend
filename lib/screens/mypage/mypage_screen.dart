import 'package:flutter/material.dart';
import '../splash/splash_screen.dart';
import '../../widgets/CustomBottomNavigationBar.dart';
import '../../widgets/header.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFFE4B80);
    const lightYellow = Color(0xFFFFED86);
    const dividerColor = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 핑크 헤더
            PinkHeader(title: '마이페이지'),
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

            const Spacer(),

            // 하단 네비게이션 영역과 높이 맞추려고 약간 여백
            const SizedBox(height: 8),

            const CustomBottomNavigationBar(),
          ],
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

/// 섹션 소제목 (알림 / 계정 / 정보)
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF858585),
        ),
      ),
    );
  }
}

/// 설정 항목 한 줄 (텍스트 + 오른쪽 화살표)
class _SettingRow extends StatelessWidget {
  final String title;
  const _SettingRow({required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      trailing: Container(
        child: const Icon(
          Icons.arrow_forward_ios,
          size: 13,
          color: Colors.black,
        ),
      ),
      onTap: () {
        // TODO: 각 항목별 네비게이션 연결
      },
    );
  }
}

/// 로그아웃 항목 한 줄 (텍스트)

class _LogoutRow extends StatelessWidget {
  final String title;
  const _LogoutRow({required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('로그아웃'),
                content: const Text('정말 로그아웃 하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // 다이얼로그 닫기
                    },
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                      );
                    },
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            });
      },
    );
  }
}
