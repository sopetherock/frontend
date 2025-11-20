import 'package:flutter/material.dart';

class ThunderTimerBar extends StatelessWidget {
  final String title;
  final String timeText;

  const ThunderTimerBar({
    required this.title,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    // 위에 있던 Rectangle 94 스타일 기준 (FE4B80 → FFA46B 그라디언트)
    const Gradient gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFFFE4B80),
        Color(0xFFFFA46B),
      ],
    );

    return Stack(
      children: [
        Container(
          width: 361,
          height: 106,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        // 시간 텍스트
        Positioned(
          left: 45,
          top: 32,
          child: Text(
            timeText,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 40,
              height: 48 / 40,
              color: Colors.black,
            ),
          ),
        ),
        // 할 일 제목
        Positioned(
          left: 33,
          top: 20,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 15 / 12,
              color: Colors.black,
            ),
          ),
        ),
        // 오른쪽 체크박스
        Positioned(
          right: 16,
          top: 30,
          child: Container(
            width: 27,
            height: 33,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF1E1E1E),
                width: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
