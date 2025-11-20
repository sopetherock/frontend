import 'package:flutter/material.dart';
import '../../widgets/CustomBottomNavigationBar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Center(child: Text("홈 화면입니다")), // 여기에 홈 화면 내용 구현
          
          // 하단 네비게이션 바 (홈 = 0번)
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: CustomBottomNavigationBar(currentIndex: 0),
          ),
        ],
      ),
    );
  }
}