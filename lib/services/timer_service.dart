import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/todo.dart';

class TimerService {
  final storage = const FlutterSecureStorage();
  
  // [중요] 에뮬레이터는 10.0.2.2, 실제 기기/웹은 localhost 또는 PC IP
  static const String _baseUrl = 'http://localhost:3000/api/timers';

  // 1. 진행 중인 타이머 목록 조회 (이게 없어서 에러가 났었습니다)
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

  // 2. 개인 타이머 생성 (Deadline 전송 버전)
  Future<Map<String, dynamic>> createPersonalTimer({
    required String todo,
    required DateTime deadline, // [변경] duration 대신 deadline 받음
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
          'deadline': deadline.toIso8601String(), // 날짜 형식으로 전송
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body); 
      } else {
        throw Exception('생성 실패: ${response.body}');
      }
    } catch (e) {
      print('TimerService Error: $e');
      throw Exception('타이머 생성 중 오류 발생');
    }
  }

  // 3. 남은 시간 계산 로직
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
   // 4. 가장 마감이 임박한 TODO 가져오기
Future<Todo?> fetchUrgentTodo() async {
  try {
    final token = await storage.read(key: 'accessToken');

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('데이터 로드 실패: ${response.body}');
    }

    final data = jsonDecode(response.body);

    final personalTimers = (data['personal'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    if (personalTimers.isEmpty) {
      return null;
    }

    // deadline 가장 가까운 todo 찾기
    personalTimers.sort((a, b) {
      final aDeadline = DateTime.parse(a['deadline']);
      final bDeadline = DateTime.parse(b['deadline']);
      return aDeadline.compareTo(bDeadline);
    });

    // ❗ Map을 Todo 객체로 변환
    return Todo.fromJson(personalTimers.first);

  } catch (e) {
    print('UrgentTodo Error: $e');
    throw Exception('긴급 TODO 조회 실패');
  }
}
}
