import 'package:flutter/material.dart';
import '../../widgets/header.dart';
import '../../widgets/CustomBottomNavigationBar.dart';
import '../../widgets/_ThunderTimerCard.dart';

const pink = Color(0xFFFE4B80);

// 임의
class ThunderTask {
  final String title; // 할 일 제목
  final String timeText; // 남은 시간 텍스트

  ThunderTask({
    required this.title,
    required this.timeText,
  });
}

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 여기서 null이면 "할 일 없음" 상태
    //    실제로는 상태/DB에서 값 받아오면 됨
    ThunderTask? task;
    // 예시로 테스트하고 싶으면 아래 주석 풀어봐
    task = ThunderTask(title: '와이어프레임 제작', timeText: '00:58:23');

    final hasTask = task != null;

    final screenHeight = MediaQuery.of(context).size.height;
    const headerHeight = 90.0;
    const bottomNavHeight = kBottomNavigationBarHeight;
    const designContentHeight = 900.0;
    final minContentHeight = screenHeight - headerHeight - bottomNavHeight;
    final contentHeight = designContentHeight > minContentHeight
        ? designContentHeight
        : minContentHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ZeusHeader(),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 393,
              height: contentHeight,
              child: Stack(
                children: [
                  // 배경
                  Container(color: Colors.white),

                  // 배경 이미지 (Figma 값 그대로)
                  Positioned(
                    left: -126,
                    top: 125,
                    child: Image.asset(
                      'assets/images/home_background.png',
                      width: 615,
                      height: 436,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 이미지 위 그라디언트 (Rectangle 117)
                  Positioned(
                    left: 0,
                    top: 125,
                    child: Container(
                      width: 393,
                      height: 436,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(0, 255, 255, 255),
                            Color.fromARGB(108, 29, 29, 29),
                            Color.fromARGB(122, 0, 0, 0),
                          ],
                          stops: [0.26, 0.67, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // ───────── To-Do 타이틀 영역 ─────────
                  const Positioned(
                    left: 16,
                    top: 380,
                    child: Text(
                      'To-Do',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                        height: 36 / 30,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 4),
                            blurRadius: 4.8,
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Positioned(
                    left: 19,
                    top: 421,
                    child: SizedBox(
                      width: 247,
                      child: Text(
                        '앞으로 주어진 벼락치기는?⚡️',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 21,
                          height: 25 / 21,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 0),
                              blurRadius: 1.2,
                              color: Color.fromRGBO(255, 255, 255, 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 19,
                    top: 361,
                    child: Text(
                      '바쁜 오늘도 화이팅 !',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 18 / 15,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // ───────── Thunder Timer 타이틀 ─────────
                  const Positioned(
                    left: 16,
                    top: 615,
                    child: Text(
                      'ToDay’s Thunder Timer',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 23,
                        height: 28 / 23,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // 🔹 아래 안내 문구: 할 일 유무에 따라 변경
                  if (!hasTask)
                    const Positioned(
                      left: 16,
                      top: 648,
                      child: Text(
                        '오늘 해낼 벼락치기가 없어요! ⚡️',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          height: 16 / 13,
                          color: Colors.black,
                        ),
                      ),
                    )
                  else
                    const Positioned(
                      left: 16,
                      top: 648,
                      child: Text(
                        '시간이 얼마 남지 않았어요! 벼락치기로 ㄱ ⚡️',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          height: 16 / 13,
                          color: Colors.black,
                        ),
                      ),
                    ),

                  // 🔹 타이머 바: 할 일 있을 때만 1개 보여줌
                  if (hasTask)
                    Positioned(
                      left: 16,
                      top: 684,
                      child: ThunderTimerBar(
                        title: task!.title,
                        timeText: task.timeText,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────── Zeus Header ─────────────────

class ZeusHeader extends StatelessWidget implements PreferredSizeWidget {
  const ZeusHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(90); // 헤더 높이 조절

  @override
  Widget build(BuildContext context) {
    return Container(
      color: pink,
      child: SafeArea(
        bottom: false,
        child: Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.fromLTRB(16, 30, 16, 25),
          child: const Text(
            'zeus on',
            style: TextStyle(
              fontFamily: 'Modulus',
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFE65B),
            ),
          ),
        ),
      ),
    );
  }
}
