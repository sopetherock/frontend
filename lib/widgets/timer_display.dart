import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/timer/timer_result_screen.dart';
import '../services/timer_service.dart'; // [New] 서비스 임포트

class TimerDisplayScreen extends StatefulWidget {
  final int todoId;
  final String todo;
  final int? duration;
  final DateTime? deadline;
  final bool isGroup;

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
  // [New] 서비스 인스턴스
  final TimerService _timerService = TimerService();

  late Timer _timer;
  late int _remainingSeconds;
  late int _totalSeconds;

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
      final now = DateTime.now();
      final difference = widget.deadline!.difference(now).inSeconds;
      _remainingSeconds = difference > 0 ? difference : 0;
      _totalSeconds = _remainingSeconds > 0 ? _remainingSeconds : 1;
    } else {
      _remainingSeconds = widget.duration ?? 0;
      _totalSeconds = widget.duration ?? 0;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _timer.cancel();
          _handleFail();
        }
      }
    });
  }

  String _formatTime(int seconds) {
    final int h = seconds ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;
    final int s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // [수정] 서비스 사용하여 완료 처리
  Future<void> _handleComplete() async {
    _timer.cancel();
    try {
      // ApiService -> Token 자동 주입
      await _timerService.completeTimer(widget.todoId, widget.isGroup);
      _navigateToResult(isSuccess: true);
    } catch (e) {
      print('완료 처리 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('완료 처리에 실패했습니다.')),
      );
    }
  }

  // [수정] 서비스 사용하여 실패 처리
  Future<void> _handleFail() async {
    _timer.cancel();
    try {
      await _timerService.failTimer(widget.todoId, widget.isGroup);
      _navigateToResult(isSuccess: false);
    } catch (e) {
      print('실패 처리 중 에러: $e');
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
    double progress = _totalSeconds == 0 ? 0 : _remainingSeconds / _totalSeconds;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 100,
            child: Container(color: _primaryPink),
          ),
          Positioned(
            top: 61, left: 0, right: 0,
            child: const Center(
              child: Text(
                '타이머',
                style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: 61, left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
            ),
          ),
          Positioned(
            top: 136, left: 0, right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 279, height: 279,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 1.0, strokeWidth: 12,
                        valueColor: AlwaysStoppedAnimation<Color>(_bgPink),
                      ),
                      CircularProgressIndicator(
                        value: progress, strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(_primaryPink),
                      ),
                      Center(
                        child: Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(fontFamily: 'Rubik', fontSize: 48, fontWeight: FontWeight.w400, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  widget.todo,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 25, fontWeight: FontWeight.w500, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
                GestureDetector(
                  onTap: _handleComplete,
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(color: _primaryPink, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Text(
                      '완료',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavIcon(Icons.roofing, false),
                  _buildNavIcon(Icons.group, false),
                  _buildNavIcon(Icons.timer, true),
                  _buildNavIcon(Icons.account_box, false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isActive) {
    return Icon(icon, size: 28, color: isActive ? _primaryPink : Colors.grey[400]);
  }
}