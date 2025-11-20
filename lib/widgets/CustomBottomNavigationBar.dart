import 'package:flutter/material.dart';
import '../screens/mypage/mypage_screen.dart'; // ← MyPageScreen 경로 맞게 수정!
import '../screens/social/friends_screen.dart'; // ← FriendsScreen 경로 맞게 수정!
import '../screens/home/home_screen.dart'; // ← HomeDashboardScreen 경로 맞게 수정!
import '../screens/timer/personal_timer_screen.dart'; // ← PersonalTimerScreen 경로 맞게 수정!

const pink = Color(0xFFFE4B80);

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex, // 현재 선택된 탭 표시
      selectedItemColor: pink,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,

      onTap: (index) {
        switch (index) {
          case 0: // 홈
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
            );

          case 1: // 친구
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FriendsScreen()),
            );
            break;

          // case 2: // 타이머
          /* Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PersonalTimerScreen()),
            );
            break; */

          case 3: // 마이페이지
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MyPageScreen()),
            );
            break;
        }
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.roofing),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: '친구',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timer),
          label: '타이머',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box),
          label: '마이',
        ),
      ],
    );
  }
}
