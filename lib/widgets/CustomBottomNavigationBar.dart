import 'package:flutter/material.dart';

// 이동할 화면들 임포트 (경로 확인 필수)
import '../screens/home/home_screen.dart';
import '../screens/social/friends_screen.dart';
import '../screens/timer/personal_timer_screen.dart';
import '../screens/mypage/mypage_screen.dart';

const pink = Color(0xFFFE4B80);

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  // 탭 클릭 시 이동 로직
  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // 현재 탭이면 이동 안 함

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = HomeDashboardScreen();
        break;
      case 1:
        nextScreen = FriendsScreen();
        break;
      case 2:
        nextScreen = PersonalTimerScreen();
        break;
      case 3:
        nextScreen = MyPageScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => nextScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE)),
        ),
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

  // 개별 네비게이션 아이템
  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, int index) {
    final bool isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      behavior: HitTestBehavior.opaque,
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

