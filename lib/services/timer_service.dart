import 'package:frontend/models/todo.dart'; // Todo 모델이 있다면 유지, 없으면 삭제
import 'package:frontend/services/api_service.dart';

class TimerService {
  // 1. 진행 중인 타이머 목록 조회
  Future<Map<String, List<dynamic>>> fetchRunningTimers() async {
    try {
      final response = await ApiService.get('/timers');
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'personal': data['personal'] ?? [],
          'group': data['group'] ?? [],
        };
      }
      return {'personal': [], 'group': []};
    } catch (e) {
      print('TimerService Fetch Error: $e');
      return {'personal': [], 'group': []};
    }
  }

  // 2. 개인 타이머 생성
  Future<Map<String, dynamic>> createPersonalTimer({
    required String todo,
    required DateTime deadline,
  }) async {
    try {
      final response = await ApiService.post('/timers/personal', data: {
        'todo': todo,
        'deadline': deadline.toIso8601String(),
      });
      return response.data;
    } catch (e) {
      print('TimerService Create Error: $e');
      rethrow;
    }
  }

  // [NEW] 3. 타이머 완료 처리
  Future<void> completeTimer(int timerId, bool isGroup) async {
    try {
      final type = isGroup ? 'group' : 'personal';
      // ApiService가 토큰 자동 처리
      await ApiService.post('/timers/$type/$timerId/complete');
    } catch (e) {
      print('Timer Complete Error: $e');
      rethrow;
    }
  }

  // [NEW] 4. 타이머 실패 처리
  Future<void> failTimer(int timerId, bool isGroup) async {
    try {
      final type = isGroup ? 'group' : 'personal';
      // ApiService가 토큰 자동 처리
      await ApiService.post('/timers/$type/$timerId/fail');
    } catch (e) {
      print('Timer Fail Error: $e');
      rethrow;
    }
  }

  // 5. 남은 시간 계산 로직
  int calculateInitialDuration(Map<String, dynamic> timerData, bool isGroup) {
    if (!isGroup && timerData['startTime'] != null) {
      final startTime = DateTime.parse(timerData['startTime']);
      final now = DateTime.now();
      final originalDuration = timerData['duration'] as int;
      
      final elapsedSeconds = now.difference(startTime).inSeconds;
      final remaining = originalDuration - elapsedSeconds;

      return remaining > 0 ? remaining : 0;
    } else if (!isGroup) {
      return timerData['duration'];
    }
    return 0; 
  }

  // 6. 긴급 할일 조회 (필요시 유지)
  Future<dynamic> fetchUrgentTodo() async {
    try {
      final response = await ApiService.get('/timers');
      // 로직 생략 (기존 코드 유지하거나 필요 없으면 삭제)
      return null;
    } catch (e) {
      return null;
    }
  }
}
