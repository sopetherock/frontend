import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/CustomBottomNavigationBar.dart';
import '../auth/login_choice_screen.dart';

// [상수 정의]
// Build 함수 외부에서 const가 아닌 값을 참조하면 에러가 납니다.
// 모든 색상 상수를 명시적으로 정의하거나 MyPageScreen 내부에 static const로 정의합니다.
const Color kPink = Color(0xFFFE4B80);
const Color kLightYellow = Color(0xFFFFED86);
const Color kGreyDividerColor = Color(0xFFEFEFEF); // 임의의 회색 구분선 색상 정의

/// 커스텀 헤더 위젯 (AppBar 대체용)
class PinkHeader extends StatelessWidget {
  final String title;
  // [필수] const 생성자 정의
  const PinkHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(title, style: const TextStyle(color: Colors.black, fontSize: 18)),
      // 여기에 뒤로가기 버튼 로직 등을 추가할 수 있습니다.
    );
  }
}

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  // [수정 핵심 1] Build 외부에서 참조되는 모든 변수는 static const로 선언
  static const Color dividerColor = kGreyDividerColor;
  static const Color lightYellow = kLightYellow; 

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
    // [수정] 이 위젯들은 const가 아니므로, build 내부에서는 const 없이 호출합니다.
    return Scaffold(
      backgroundColor: Colors.white,

      // [수정 1] PinkHeader 호출 시 const 제거 (StatelessWidget이지만, AppBar를 반환하기에 const로 만들기 어려움)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: PinkHeader(title: '마이페이지'),
      ),

      // bottomNavigationBar는 const 가능 (CustomBottomNavigationBar는 const 생성자임)
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
                        decoration: BoxDecoration( // [수정 2] const 제거 (lightYellow가 build 내부에서 정의된 변수라면)
                          shape: BoxShape.circle,
                          color: lightYellow, // [수정] static const 필드 lightYellow 사용
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
                      // ... (프로필 텍스트 유지) ...
                      const Text('유준희', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: Colors.black)),
                      const SizedBox(height: 4),
                      const Text('junheelove', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFB6B6B6))),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 번개 모으기 카드 (const 사용 가능)
                const Center(
                  child: SizedBox(
                    width: 89,
                    height: 70,
                    child: _LightingCard(),
                  ),
                ),

                const SizedBox(height: 24),

                // --- 설정 영역 ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 회색 구분선 1 (const 가능)
                      const _GreyDivider(color: dividerColor), // [수정 3] static const 필드 dividerColor 사용

                      // 알림 섹션
                      const _SectionTitle(title: '알림'),
                      const _SettingRow(title: '앱 알림 설정'),

                      const _GreyDivider(color: dividerColor),

                      // 계정 섹션
                      const _SectionTitle(title: '계정'),
                      const _SettingRow(title: '내 정보'),
                      
                      // [수정 4] LogoutRow에 _handleLogout 함수를 연결
                      _LogoutRow(title: '로그아웃', onTap: () => _handleLogout(context)), 

                      const _GreyDivider(color: dividerColor),

                      // 정보 섹션
                      const _SectionTitle(title: '정보'),
                      const _SettingRow(title: '이용 약관'),
                    ],
                  ),
                ),
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

class _LightingCard extends StatelessWidget {
  const _LightingCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromARGB(255, 232, 232, 232), width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/_lighting.png', width: 24, height: 24),
          const SizedBox(height: 4),
          const Text('번개 모으기', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.black)),
        ],
      ),
    );
  }
}


class _SectionTitle extends StatelessWidget {
  final String title;
  // [필수] const 생성자 추가
  const _SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String title;
  // [필수] const 생성자 추가
  const _SettingRow({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: () { /* 이동 로직 */ },
    );
  }
}

class _LogoutRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap; // 로그아웃 함수를 받기 위한 콜백
  // [필수] const 생성자 추가
  const _LogoutRow({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 14, color: kPink)),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}


/// 회색 가로 바 (Rectangle 128, 129, 145)
class _GreyDivider extends StatelessWidget {
  final Color color;
  // [필수] const 생성자 추가
  const _GreyDivider({super.key, required this.color});

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
