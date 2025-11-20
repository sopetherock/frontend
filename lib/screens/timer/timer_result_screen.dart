import 'package:flutter/material.dart';
import 'todo_screen.dart';
import 'personal_timer_screen.dart';

class TimerResultScreen extends StatelessWidget {
  final bool isSuccess;
  final String todo;

  const TimerResultScreen({
    super.key,
    required this.isSuccess,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. 배경 그라데이션
          _buildBackground(),

          // 2. 상단 헤더 (뒤로가기 & 타이틀)
          _buildHeader(context),

          // 3. 결과 카드 (메인 콘텐츠)
          _buildResultCard(),

          // 4. 하단 텍스트 및 버튼
          _buildBottomSection(context),
        ],
      ),
    );
  }

  // --- UI 위젯 분리 메서드들 ---

  // 1. 배경 그라데이션 위젯
  Widget _buildBackground() {
    return Positioned(
      top: 0, left: 0, right: 0, height: 307,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSuccess
                ? [const Color(0xFFFE4B80), Colors.white] // 성공: 핑크 -> 화이트
                : [const Color(0xFF243379), Colors.white], // 실패: 블루 -> 화이트
          ),
        ),
      ),
    );
  }

  // 2. 헤더 위젯
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // 타이틀
        Positioned(
          top: 61, left: 0, right: 0,
          child: const Center(
            child: Text(
              '타이머',
              style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white),
            ),
          ),
        ),
        // 뒤로가기 버튼
        Positioned(
          top: 61, left: 16,
          child: GestureDetector(
            onTap: () {
              // 메인 목록(PersonalTimerScreen)으로 스택을 비우며 이동
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const PersonalTimerScreen()),
                (route) => false,
              );
            },
            child: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                border: Border.all(color: isSuccess ? Colors.white : Colors.black, width: 1),
                shape: BoxShape.rectangle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  // 3. 결과 카드 위젯
  Widget _buildResultCard() {
    return Positioned(
      top: 154, left: 16, right: 16, height: 356,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: isSuccess ? Border.all(color: const Color(0xFFBCBCBC), width: 2) : null,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSuccess
                ? [const Color(0xFFFFF5BC), Colors.white]
                : [const Color(0xFF1A233F), const Color(0xFF243379)],
            stops: isSuccess ? [0.0, 1.0] : [0.31, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 텍스트 내용
            Padding(
              padding: const EdgeInsets.only(left: 34, top: 31),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSuccess ? '과제 완료!' : '과제 실패...',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 30, fontWeight: FontWeight.w600,
                      color: isSuccess ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    todo,
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w400,
                      color: isSuccess ? Colors.black : Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    isSuccess
                        ? '마감시간보다 10분 30초 빨리했어요!' // 추후 동적 데이터로 변경 가능
                        : '오늘 다른 할 일이 많았나요? 그랬어야 해요...',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w400,
                      color: isSuccess ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // 일러스트 이미지 (에셋 사용)
            _buildResultImage(),
          ],
        ),
      ),
    );
  }

  // 카드 내부 이미지 위젯
  Widget _buildResultImage() {
    if (isSuccess) {
      return Positioned(
        left: -67, top: 63, width: 419, height: 292,
        child: Image.asset(
          'assets/images/timer_success.png',
          fit: BoxFit.contain,
          errorBuilder: (c, o, s) => Container(), // 이미지 없으면 빈 공간
        ),
      );
    } else {
      return Positioned(
        left: 97, top: 134, width: 320, height: 222,
        child: Image.asset(
          'assets/images/zeus_sad.png',
          fit: BoxFit.contain,
          errorBuilder: (c, o, s) => Container(), // 이미지 없으면 빈 공간
        ),
      );
    }
  }

  // 4. 하단 섹션 (보상 텍스트 + 버튼)
  Widget _buildBottomSection(BuildContext context) {
    return Stack(
      children: [
        // 보상 텍스트 (성공 시에만 표시)
        if (isSuccess)
          const Positioned(
            top: 456, left: 0, right: 0,
            child: Center(
              child: Text(
                '⚡1 획득!',
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black,
                ),
              ),
            ),
          ),

        // 하단 버튼 "다른 벼락 치러 가기!"
        Positioned(
          top: 716, left: 16, right: 16, height: 55,
          child: GestureDetector(
            onTap: () {
              // 할 일 추가 화면(TodoScreen)으로 이동 (스택 교체)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TodoScreen()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 204, 204, 0.51),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  '다른 벼락 치러 가기!',
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}