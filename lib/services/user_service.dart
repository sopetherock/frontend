import 'package:dio/dio.dart';
import 'api_service.dart';

class UserService {
  /// 로그인된 내 정보 조회
  /// GET /auth/me  (ApiService에서 자동으로 /api 붙음)
  static Future<Map<String, dynamic>> getMe() async {
    final res = await ApiService.dio.get("/auth/me");
    return res.data;
  }
}
