import 'package:dio/dio.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/todo.dart';

class TimerService {
  final ApiService _apiService = ApiService();

  Future<Todo?> fetchUrgentTodo() async {
    try {
      final response = await ApiService.dio.get('/timer/urgent');
      
      // 응답 예시: { "task": { "title": "과제 제출", "deadline": "..." } }
      final taskData = response.data['task']; 

      if (taskData != null) {
        return Todo.fromJson(taskData);
      }
      return null;
    } on DioError catch (e) {
      print('Urgent Todo API 호출 오류: $e');
      // 오류 발생 시 null 반환 또는 예외 throw
      return null; 
    }
  }
}