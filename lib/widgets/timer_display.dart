//widgets/timer_display.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/timer/timer_result_screen.dart'; 
// 토큰 저장을 위한 패키지 (예: flutter_secure_storage 또는 shared_preferences)
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TimerDisplayScreen extends StatefulWidget {
  final int todoId;
  final String todo;
  final int? duration; // 개인 타이머용 (초 단위)
  final DateTime? deadline; // 그룹 타이머용
  final bool isGroup; // 그룹 여부 판별

  const TimerDisplayScreen({
    super.key,
    required this.todoId,
    required this.todo,
    this.duration,
    this.deadline,
    this.isGroup = false,
  });

  @override
  State<TimerDisplayScreen> createState() => _TimerDisplayScreenState();
}

class _TimerDisplayScreenState extends State<TimerDisplayScreen> {
  late Timer _timer;
  late int _remainingSeconds;
  late int _totalSeconds;
  final storage = FlutterSecureStorage();

  // 디자인 컬러 상수
  final Color _primaryPink = const Color(0xFFFE4B80);
  final Color _bgPink = const Color(0xFFFFEDED);

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    _startTimer();
  }

  void _initializeTimer() {
    if (widget.deadline != null) {
      // 마감일이 있는 경우 (그룹 타이머)
      final now = DateTime.now();
      final difference = widget.deadline!.difference(now).inSeconds;
      _remainingSeconds = difference > 0 ? difference : 0;
      // 시각적 진행률을 위해, 들어온 순간을 전체로 잡거나 별도 startTime이 필요하지만
      // 여기서는 현재 남은 시간을 전체 기준(100%)으로 시작한다고 가정합니다.
      _totalSeconds = _remainingSeconds; 
    } else {
      // 기간이 있는 경우 (개인 타이머)
      _remainingSeconds = widget.duration ?? 0;
      _totalSeconds = widget.duration ?? 0;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        _handleFail(); // 시간 초과 시 실패 처리
      }
    });
  }

  // 시간 포맷팅 (HH:MM:SS)
  String _formatTime(int seconds) {
    final int h = seconds ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;
    final int s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // API 호출: 완료
  Future<void> _handleComplete() async {
    _timer.cancel();
    
    final type = widget.isGroup ? 'group' : 'personal';
    final url = Uri.parse('http://localhost:3000/api/timers/$type/${widget.todoId}/complete');
    
    try {
      final token = await storage.read(key: 'accessToken'); // 저장된 토큰 가져오기
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _navigateToResult(isSuccess: true);
      } else {
        print('완료 처리 실패: ${response.body}');
        // 에러 처리 로직 (스낵바 등)
      }
    } catch (e) {
      print('API Error: $e');
    }
  }

  // API 호출: 실패
  Future<void> _handleFail() async {
    _timer.cancel();

    final type = widget.isGroup ? 'group' : 'personal';
    final url = Uri.parse('http://localhost:3000/api/timers/$type/${widget.todoId}/fail');

    try {
      final token = await storage.read(key: 'accessToken');
      
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      // 실패 API는 성공 여부와 상관없이 결과 화면으로 이동 (혹은 알림)
      _navigateToResult(isSuccess: false);
    } catch (e) {
      print('API Error: $e');
      _navigateToResult(isSuccess: false);
    }
  }

  void _navigateToResult({required bool isSuccess}) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TimerResultScreen(
          isSuccess: isSuccess,
          todo: widget.todo,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 진행률 계산 (1.0 -> 0.0 으로 줄어듦)
    double progress = _totalSeconds == 0 ? 0 : _remainingSeconds / _totalSeconds;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. 상단 헤더 배경 (Rectangle 144)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100, // 높이 조금 조정
            child: Container(color: _primaryPink),
          ),
          
          // 2. 상단 타이틀 "타이머"
          Positioned(
            top: 61,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '타이머',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 3. 뒤로가기 아이콘 (keyboard_arrow_down 회전)
          Positioned(
            top: 61,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new, // 아이콘 대체
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // 메인 컨텐츠 (타이머 원 + 텍스트 + 버튼)
          Positioned(
            top: 136, // Ellipse 36 top
            left: 0,
            right: 0,
            child: Column(
              children: [
                // 4. 원형 타이머 (Stack으로 겹침)
                SizedBox(
                  width: 279,
                  height: 279,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 배경 원 (테두리 효과)
                      CircularProgressIndicator(
                        value: 1.0, // 꽉 찬 상태
                        strokeWidth: 12,
                        valueColor: AlwaysStoppedAnimation<Color>(_bgPink), // #FFEDED
                      ),
                      // 진행 원 (줄어드는 효과)
                      CircularProgressIndicator(
                        value: progress, 
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(_primaryPink), // #FE4B80
                      ),
                      // 가운데 시간 텍스트
                      Center(
                        child: Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 48,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30), // 간격

                // 5. Todo 텍스트
                Text(
                  widget.todo,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 26), // 간격

                // 6. 완료 버튼 (Group 103)
                GestureDetector(
                  onTap: _handleComplete,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _primaryPink,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '완료',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18, // 21px은 조금 커서 조정
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 7. 하단 네비게이션 바 (디자인 시안 반영)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80, // Rectangle 100 + Home indicator
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavIcon(Icons.roofing, false), // Home
                  _buildNavIcon(Icons.group, false),   // Group
                  _buildNavIcon(Icons.timer, true),    // Timer (Active)
                  _buildNavIcon(Icons.account_box, false), // Profile
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isActive) {
    return Icon(
      icon,
      size: 28,
      color: isActive ? _primaryPink : Colors.grey[400],
    );
  }
}