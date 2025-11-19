// TimerProvider를 통해 받은 deadline을 기반으로 1초마다 남은 시간을 계산하고, 조건에 따라 이미지를 변경

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/timer_provider.dart';
import 'package:frontend/models/todo.dart';


class UrgentTodoWidget extends StatefulWidget {
  const UrgentTodoWidget({Key? key}) : super(key: key);

  @override
  State<UrgentTodoWidget> createState() => _UrgentTodoWidgetState();
}

class _UrgentTodoWidgetState extends State<UrgentTodoWidget> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    // 초기 남은시간을 즉시 계산하고, 1초마다 UI 업데이트를 위한 타이머 시작
    _updateRemainingTime(initial: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 위젯이 사라질 때 타이머 해제
    super.dispose();
  }

  // 남은 시간 계산 및 UI 업데이트
  void _updateRemainingTime({bool initial = false}) {
    // 위젯이 dispose 된 이후에 콜백이 실행되는 것을 방지
    if (!mounted) return;

    final todo = Provider.of<TimerProvider>(context, listen: false).urgentTodo;
    if (todo != null) {
      final now = DateTime.now();
      final newRemainingTime = todo.deadline.difference(now);

      // 1초마다 남은 시간 업데이트 및 rebuild
      if (newRemainingTime != _remainingTime || initial) {
        setState(() {
          _remainingTime = newRemainingTime;
        });
      }
    } else if (_remainingTime != Duration.zero) { // 할 일이 사라지면 타이머 초기화
      setState(() {
        _remainingTime = Duration.zero;
      });
    }
  }

  // 남은 시간에 따라 HEX 코드로 배경 색상 결정
  Color _getBackgroundColor(Duration remaining) {
    if (remaining.isNegative || remaining.inMinutes <= 0) {
      return const Color(0xFF6C757D); // 지남: Grayish Blue (Colors.grey.shade600 대체)
    } else if (remaining.inHours < 1) {
      return const Color(0xFF0D1C5D); // 1시간 미만: Red (Colors.redAccent.shade700 대체)
    } else if (remaining.inHours < 3) {
      return const Color(0xFFFE4B80); // 3시간 미만: Yellow/Orange (Colors.deepOrange 대체)
    } else {
      return const Color(0xFFFFE65B); // 3시간 이상: Purple (Colors.pink.shade400 대체)
    }
  }

  // 남은 시간에 따라 캐릭터 이미지 경로 결정
  String _getImagePath(Duration remaining) {
    if (remaining.isNegative || remaining.inMinutes <= 0) {
      return 'assets/images/push_last.png';      // 기본/마감 지남
    } else if (remaining.inHours < 1) {
      return 'assets/images/push_last.png';       // 1시간 미만 (가장 급함)
    } else if (remaining.inHours < 3) {
      return 'assets/images/push_second.png';          // 3시간 미만
    } else {
      return 'assets/images/push_first.png';        // 3시간 이상
    }
  }


  // 남은 시간 포맷팅 (HH:MM:SS)
  String _formatRemainingTime(Duration remaining) {
    if (remaining.isNegative) return '00:00:00'; // [변경] 텍스트 수정
    
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(remaining.inHours);
    String minutes = twoDigits(remaining.inMinutes.remainder(60));
    String seconds = twoDigits(remaining.inSeconds.remainder(60));
    
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, provider, child) {
        final todo = provider.urgentTodo;
        // 실시간 정확한 현재 시점을 기준으로 남은 시간을 계산 (빌드 시점 기준)
        final remaining = _remainingTime;

        // todo가 변경되었는데 _remainingTime이 아직 갱신되지 않았을 경우를 대비하여 
        // remaining이 음수이지만 todo가 존재하는 상황을 방지
        if (todo != null && remaining.inMinutes > -1 && remaining.inMinutes < 1) {
            // 마감 임박 시 타이머가 정확하도록 한 번 더 계산을 트리거 (선택 사항)
            // _updateRemainingTime();
        }
        // 급한 할 일이 없거나, 24시간 초과했거나, 마감 시간이 지났으면 위젯을 숨김
        final isOverdue = remaining.isNegative;
        final isTooEarly = todo != null && remaining.inHours > 24;

        if (todo == null || isTooEarly || isOverdue) {
          return const SizedBox.shrink();
        }

        // 빌드 시점의 남은 시간을 사용하여 UI 결정
        final backgroundColor = _getBackgroundColor(remaining);
        final characterImagePath = _getImagePath(remaining); // 이미지 경로 가져오기
        final timeText = _formatRemainingTime(remaining);
        
        return Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 💫 왼편 캐릭터 이미지 (남은 시간에 따라 PNG 변경)
              Positioned(
                left: -20,
                bottom: 0,
                child: Image.asset(
                  characterImagePath, // 동적으로 결정된 PNG 파일 사용
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              
              // ⏱️ 오른편 타이머 및 할 일 제목
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeText, // [변경] 마감까지 남은 시간
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700, // 굵게 강조
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 5), // 간격 추가
                    // 남은 시간 밑에 할 일 제목 표시
                    Text(
                      todo.title, // 할 일 이름
                      style: Theme.of(context).textTheme.titleLarge?.copyWith( // [변경] 텍스트 크기 상향
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
