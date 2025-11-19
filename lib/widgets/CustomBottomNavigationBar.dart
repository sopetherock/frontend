import 'package:flutter/material.dart';

const pink = Color(0xFFFE4B80);

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: pink,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
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
