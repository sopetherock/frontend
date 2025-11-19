// lib/widgets/timer_display.dart (개인 타이머 최종 버전)

import 'package:flutter/material.dart';
import 'dart:async'; 
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'package:firebase_auth/firebase_auth.dart'; 

// [Model Placeholder]
class TimerTodo {
  final String id;
  final String title;
  final String deadlineTime;
  final bool isCompleted;

  const TimerTodo(this.id, this.title, this.deadlineTime, this.isCompleted);
}

class TimerDisplay extends StatefulWidget {
  // 🌟 1. 유저가 설정한 전체 시간 (진행률 계산의 기준)
  final Duration initialDuration; 
  // 🌟 2. 할 일 목록
  final List<TimerTodo> todoList; // 이미 Screen에서 가져와서 넘겨준다고 가정
  final VoidCallback onCompletion; // ✅ 완료 시 호출할 콜백

  const TimerDisplay({
    super.key,
    required this.initialDuration, 
    required this.todoList,
    required this.onCompletion, 
  });

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  late Duration _remainingDuration;
  Timer? _timer;
  bool _isRunning = false;
  double _progressValue = 1.0; // 🌟 진행률 (1.0 = 100%)
  
  // ❌ 누락된 변수 정의 수정
  // _isPaused 변수는 일시정지/재개 버튼 로직에 필요하여 추가합니다.
  // bool _isFetchingTodos = false; 

  // 디자인 색상 (유지)
  static const Color _primaryColor = Color(0xFFFE4B80); 
  static const Color _borderColor = Color(0xFFFFEDED);

  // [TODO] 백엔드 주소: 실제 주소로 변경 필요
  static const String BACKEND_BASE_URL = 'http://localhost:3000'; 

  @override
  void initState() {
    super.initState();
    // 🌟 1. 초기 남은 시간을 initialDuration으로 설정합니다.
    _remainingDuration = widget.initialDuration; 
    
    if (_remainingDuration.inSeconds > 0) {
      _calculateProgress(); // 초기 진행률 계산
      _startTimer();
    }
  }
  
  // =======================================================
  // 🌟 [추가된 기능] 진행률 계산 🌟
  // =======================================================
  void _calculateProgress() {
    final totalSeconds = widget.initialDuration.inSeconds;
    final remainingSeconds = _remainingDuration.inSeconds;

    if (totalSeconds > 0) {
      // 남은 시간 / 총 시간 -> 1.0(시작)에서 0.0(종료)로 감소
      _progressValue = remainingSeconds / totalSeconds;
    } else {
      _progressValue = 0.0;
    }
  }


  // =======================================================
  // 🌟 [기능 1] 완료 버튼 API 호출 로직 🌟
  // =======================================================
  void _completeTimer() async {
    _pauseTimer(); // 타이머 정지

    final user = FirebaseAuth.instance.currentUser;
    final String? idToken = await user?.getIdToken(); 

    if (idToken == null) {
      print('오류: 로그인 토큰이 없어 완료 처리를 할 수 없습니다.');
      // 🚨 API 호출 실패 시에도 결과 화면으로 이동할지 여부는 정책에 따라 결정
      // 현재는 오류 발생 시 이동하지 않고 콘솔에만 출력합니다.
      return; 
    }

    // 🌟🌟🌟 1. todoId 추출 (할 일 목록 중 첫 번째 항목의 ID 사용) 🌟🌟🌟
    if (widget.todoList.isEmpty) {
      print('경고: 현재 진행 중이거나 완료할 할 일이 없습니다. API 호출을 건너뜁니다.');
      // 할 일 없이 완료 버튼을 누른 경우, API 호출 없이 바로 결과 화면으로 이동합니다.
      widget.onCompletion(); 
      return;
    }

    // 목록의 첫 번째 할 일 ID를 사용합니다.
    final String todoId = widget.todoList.first.id;
    final int timeSpentSeconds = widget.initialDuration.inSeconds - _remainingDuration.inSeconds;

    // API 경로: 개인 타이머 완료 API 호출
    final url = Uri.parse('$BACKEND_BASE_URL/api/timers/personal/$todoId/complete');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          // 사용된 시간 (총 시간 - 남은 시간)을 서버에 전달
          'timeSpentSeconds': timeSpentSeconds,
        }),
      );

      if (response.statusCode == 200) {
        print('개인 할 일 ($todoId) 타이머 완료 API 호출 성공! 경과 시간: $timeSpentSeconds초');
        // ✅ API 성공 후 콜백 호출: 획득한 번개 값을 전달합니다.
      widget.onCompletion(
        type: TimerResultType.success,
        timeDiff: widget.initialDuration - _remainingDuration, // 경과 시간
        taskName: widget.todoList.first.title, // 과제 이름
        questReward: lightningPoints, // 🌟 추출한 번개 값 전달 🌟
      ); 
    } else {
      print('API 호출 실패: ${response.statusCode}, 응답: ${response.body}');
      // 실패 처리 시에도 0의 보상을 전달하며 결과 화면으로 이동할 수 있습니다.
      widget.onCompletion(
        type: TimerResultType.failure, 
        timeDiff: Duration.zero, 
        taskName: widget.todoList.first.title,
        questReward: 0,
      );
    }
  } catch (e) {
    print('타이머 완료 네트워크 오류: $e');
    // 네트워크 오류 시에도 실패 처리하며 결과 화면으로 이동
    widget.onCompletion(
        type: TimerResultType.failure, 
        timeDiff: Duration.zero, 
        taskName: widget.todoList.first.title,
        questReward: 0,);
    }
  }


  // 3. 타이머 시작/재개 로직
  void _startTimer() {
    if (_isRunning) return; 

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel(); 
        return;
      }
      
      setState(() {
        if (_remainingDuration.inSeconds > 0) {
          _remainingDuration = _remainingDuration - const Duration(seconds: 1);
          _calculateProgress(); // 🌟 매 초 진행률 업데이트
        } else {
          // 🌟🌟🌟 시간이 끝났을 때 🌟🌟🌟
          _isRunning = false;
          _timer?.cancel();
          print('타이머 종료! (시간 만료)');

          // 1. 상태 업데이트 (UI 갱신)
          _remainingDuration = Duration.zero;
          _progressValue = 0.0;
          
          // 2. 완료 콜백 호출
          widget.onCompletion(); // ✅ personal_timer_screen으로 완료를 알림
        }
      });
    });
  }
    
  // 4. 타이머 일시 정지/취소
  void _pauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  // 5. 시간을 'HH:MM:SS' 포맷으로 변환
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeText = _formatDuration(_remainingDuration);
    
    return Column(
      children: [
        // 🌟🌟🌟 원형 타이머 진행률 표시 영역 🌟🌟🌟
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. 바깥쪽 원 (진행률의 배경)
              SizedBox(
                width: 279,
                height: 279,
                child: CircularProgressIndicator(
                  value: 1.0, 
                  strokeWidth: 12,
                  valueColor: const AlwaysStoppedAnimation<Color>(_borderColor), 
                  backgroundColor: Colors.transparent,
                ),
              ),
              
              // 2. 진행률을 나타내는 원
              SizedBox(
                width: 279,
                height: 279,
                child: CircularProgressIndicator(
                  value: _progressValue, // 🌟 시간 경과에 따라 감소
                  strokeWidth: 12,
                  valueColor: const AlwaysStoppedAnimation<Color>(_primaryColor), 
                  backgroundColor: Colors.transparent,
                  strokeCap: StrokeCap.round, // 원형 캡 추가 (선택 사항)
                ),
              ),

              // 3. 시간 표시
              Text(
                timeText,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        
        // 일시정지/재개 버튼
        ElevatedButton(
          // 시간이 0이면 버튼 비활성화, 아니면 _isRunning 상태에 따라 시작/재개/일시정지 토글
          onPressed: _remainingDuration.inSeconds == 0 ? null : (_isRunning ? _pauseTimer : _startTimer),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            _remainingDuration.inSeconds == 0 ? '완료됨' : (_isRunning ? '일시정지' : '시작/재개'),
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        
        // 완료 버튼
        Container(
          width: 72,
          height: 72,
          margin: const EdgeInsets.only(top: 20),
          child: FloatingActionButton(
            heroTag: "finish_btn",
            // 시간이 0이 아니거나, 이미 완료된 상태가 아닐 때만 완료 가능
            onPressed: _remainingDuration.inSeconds == 0 ? null : _completeTimer, 
            backgroundColor: _primaryColor,
            child: const Text('완료', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // 🌟 할 일 목록 표시 🌟
        Expanded(
          child: widget.todoList.isEmpty
              ? const Center(child: Text("현재 진행 중인 할 일이 없습니다."))
              : ListView.builder(
                  itemCount: widget.todoList.length,
                  itemBuilder: (context, index) {
                    final todo = widget.todoList[index];
                    // [디자인 반영] 할 일 목록 UI
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: todo.isCompleted ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(todo.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(todo.deadlineTime, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}