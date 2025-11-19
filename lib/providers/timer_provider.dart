import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/models/todo.dart';
import 'package:frontend/services/timer_service.dart';


// TimerProvider: 30분마다 가장 급한 할 일 데이터를 갱신하여 제공
class TimerProvider extends ChangeNotifier {
  final TimerService _timerService = TimerService();
  Todo? _urgentTodo;
  Timer? _refreshTimer;

  Todo? get urgentTodo => _urgentTodo;

  TimerProvider() {
    _startAutoRefresh();
  }

  // 30분마다 데이터를 갱신하는 타이머 시작
  void _startAutoRefresh() {
    // 30분 간격
    const refreshDuration = Duration(minutes: 30); 
    
    // 앱 시작 시 즉시 데이터 로드
    fetchUrgentTodo(isManual: true);

    _refreshTimer = Timer.periodic(refreshDuration, (timer) {
      fetchUrgentTodo();
    });
  }

  // API 호출하여 가장 급한 할 일 가져오기
  Future<void> fetchUrgentTodo({bool isManual = false}) async {
    final todo = await _timerService.fetchUrgentTodo();
    
    if (todo != _urgentTodo) {
      _urgentTodo = todo;
      notifyListeners(); // 데이터 변경 시 위젯에 알림
    } else if (isManual && todo != null) {
      // 위젯 타이머가 시작되도록 강제 알림 (앱 시작 시점)
      notifyListeners(); 
    }
  }

  // Provider가 dispose될 때 타이머도 해제
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}