import 'package:flutter/material.dart';
// 다음 할 일 화면으로 이동하기 위해 import
import '../timer/todo_screen.dart'; 

// 🌟 성공/실패 상태를 명확히 구분하는 ENUM (개인/그룹 공용)
enum TimerResultType { success, failure }

class TimerResultScreen extends StatelessWidget {
  // 🌟 생성자를 통해 결과 유형 및 통계 데이터를 받습니다.
  final TimerResultType resultType;
  final String taskName;
  final Duration timeDifference; // 마감 시간 대비 시간 차이
  final int questReward; // 획득한 번개(Lightning Points)

  const TimerResultScreen({
    super.key,
    required this.resultType,
    required this.taskName,
    required this.timeDifference,
    required this.questReward,
  });

  // 디자인에서 추출한 색상 상수
  static const Color _successPrimary = Color(0xFFFE4B80);    // 성공 상단 주 색상 (핑크)
  static const Color _failPrimary = Color(0xFF243379);       // 실패 상단 주 색상 (남색)
  static const Color _failStartColor = Color(0xFF1A233F);    // 실패 카드 시작 색상 (진한 남색)
  static const Color _successHighlight = Color(0xFFFFF5BC);  // 성공 카드 시작 색상 (노랑)
  static const Color _borderColor = Color(0xFFBCBCBC);       // 카드 테두리 색상

  // Duration을 포맷하는 함수
  String _formatDifference(Duration difference) {
    final absDifference = difference.abs();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    
    String hours = twoDigits(absDifference.inHours);
    String minutes = twoDigits(absDifference.inMinutes.remainder(60));
    String seconds = twoDigits(absDifference.inSeconds.remainder(60));
    
    return '${hours}시간 ${minutes}분 ${seconds}초';
  }

  @override
  Widget build(BuildContext context) {
    // 결과 유형에 따른 동적 속성 설정
    final bool isSuccess = resultType == TimerResultType.success;
    final Color appBarColor = isSuccess ? _successPrimary : _failPrimary;
    final Color taskNameColor = isSuccess ? Colors.black : Colors.white;
    final Color titleColor = isSuccess ? Colors.black : Colors.white;

    final String mainTitle = isSuccess ? '과제 완료!' : '과제 실패...';
    final String description = isSuccess 
        ? '마감시간보다 ${_formatDifference(timeDifference)} 빨리했어요!' 
        : '오늘 다른 할 일이 많았나요? 그랬어야 해요...';
    final String rewardText = isSuccess 
        ? '⚡$questReward 획득!' 
        : '괜찮아요. 다음엔 성공할거에요!';
    final Color rewardTextColor = isSuccess ? Colors.black : Colors.white;


    return Scaffold(
      backgroundColor: Colors.white,
      
      body: CustomScrollView(
        slivers: [
          // 1. 상단 AppBar (디자인의 Rectangle 115 - Gradient 포함)
          SliverAppBar(
            pinned: true,
            expandedHeight: 307.0,
            backgroundColor: appBarColor, 
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text('타이머', style: TextStyle(color: Colors.white, fontSize: 20)),
              background: Container(
                decoration: BoxDecoration(
                  // 🌟 성공/실패에 따른 그라데이션 적용
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isSuccess 
                        ? [appBarColor, Colors.white] 
                        : [_failStartColor, Colors.white], 
                  ),
                ),
                // TODO: 상단 아트워크 이미지 배치 위치
              ),
            ),
            // 좌측 뒤로 가기 버튼 (개인 타이머 화면으로 돌아감)
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(), 
            ),
          ),
          
          // 2. 결과 카드 영역 (Group 104 / 105)
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
                  child: Container(
                    height: 356,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      border: Border.all(color: _borderColor, width: 2),
                      borderRadius: BorderRadius.circular(30),
                      // 🌟🌟🌟 성공/실패에 따른 카드 내부 그라데이션 적용 🌟🌟🌟
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isSuccess
                            ? [_successHighlight, Colors.white] // 성공: 노란색 -> 흰색
                            : [_failStartColor, _failPrimary], // 실패: 진남색 -> 남색
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2-A. 메인 타이틀
                        Text(
                          mainTitle,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // 2-B. 과제 이름
                        Text(
                          taskName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: taskNameColor,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // 2-C. 상세 설명
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: isSuccess ? Colors.black : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // 2-D. 보상/피드백 텍스트
                        Center(
                          child: Text(
                            rewardText,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: rewardTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 3. 🌟 '다음 벼락 치러 가기' 버튼 🌟
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 28.0, right: 28.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // 다음 할 일 설정 화면으로 이동 (todo_screen.dart)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TodoScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _successPrimary, 
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '다음 벼락 치러 가기',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // 4. 하단 공간 확보
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}