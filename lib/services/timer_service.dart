import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TimerService {
  final storage = const FlutterSecureStorage();
  
  // 안드로이드 에뮬레이터: 10.0.2.2, iOS/Web: localhost
  // 실제 기기 테스트 시 PC의 내부 IP 주소 사용 권장
  static const String _baseUrl = 'http://localhost:3000/api/timers';

  // 1. 진행 중인 타이머 목록 조회
  Future<Map<String, List<dynamic>>> fetchRunningTimers() async {
    try {
      final token = await storage.read(key: 'accessToken');
      
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'personal': data['personal'] ?? [],
          'group': data['group'] ?? [],
        };
      } else {
        throw Exception('데이터 로드 실패: ${response.body}');
      }
    } catch (e) {
      print('TimerService Error: $e');
      throw Exception('서버 통신 오류');
    }
  }

  // 2. 남은 시간 계산 로직 (순수 함수로 분리)
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
    return 0; // 그룹 타이머의 경우 duration이 아닌 deadline을 사용하므로 0 리턴 (혹은 처리 방식에 따라 변경)
  }
  // ... (기존 fetchRunningTimers, calculateInitialDuration 코드 유지) ...

// [New] 개인 타이머 생성 로직 추가
  Future<Map<String, dynamic>> createPersonalTimer({
    required String todo,
    required int durationInSeconds,
  }) async {
    try {
      final token = await storage.read(key: 'accessToken');
      final response = await http.post(
        Uri.parse('$_baseUrl/personal'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'todo': todo,
          'duration': durationInSeconds,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body); // 성공 시 생성된 타이머 데이터 반환
      } else {
        throw Exception('생성 실패: ${response.body}');
      }
    } catch (e) {
      print('TimerService Error: $e');
      throw Exception('타이머 생성 중 오류 발생');
    }
  }
}