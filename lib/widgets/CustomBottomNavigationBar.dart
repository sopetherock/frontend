import 'package:flutter/material.dart';

// 1. 이동할 화면들 임포트 (경로가 맞는지 확인해주세요)
import '../screens/home/home_screen.dart';           // 홈 (0번)
import '../screens/social/friends_screen.dart';       // 친구 (1번)
import '../screens/timer/personal_timer_screen.dart'; // 타이머 (2번)
import '../screens/mypage/mypage_screen.dart';       // 마이 (3번)

const pink = Color(0xFFFE4B80);

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex, // 현재 몇 번째 탭인지 입력받음
  });

  // [핵심] 탭 클릭 시 이동 로직
  void _onItemTapped(BuildContext context, int index) {
    // 현재 탭을 또 누르면 아무 일도 안 함
    if (index == currentIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomeScreen();
        break;
      case 1:
        nextScreen = const FriendsScreen();
        break;
      case 2:
        nextScreen = const PersonalTimerScreen();
        break;
      case 3:
        nextScreen = const MyPageScreen();
        break;
      default:
        return;
    }

    // 깜빡임 없이 즉시 이동 (PageRouteBuilder 사용)
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => nextScreen,
        transitionDuration: Duration.zero, // 애니메이션 시간 0
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // 디자인 스펙 높이
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))), // 상단 회색 테두리
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.roofing, '홈', 0),
          _buildNavItem(context, Icons.group, '친구', 1),
          _buildNavItem(context, Icons.timer, '타이머', 2),
          _buildNavItem(context, Icons.account_box, '마이', 3),
        ],
      ),
    );
  }

  // 개별 아이콘 생성 위젯
  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final bool isActive = index == currentIndex;
    
    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      behavior: HitTestBehavior.opaque, // 터치 영역 확보
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: isActive ? pink : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? pink : Colors.grey,
              fontFamily: 'Inter',
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
