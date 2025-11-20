import 'api_service.dart';

class UserService {
  /// 로그인된 내 정보 조회
  /// GET /auth/me  (ApiService에서 자동으로 /api 붙음)
  static Future<Map<String, dynamic>> getMe() async {
    // [수정] ApiService.dio.get -> ApiService.get 사용
    // 이제 헤더(토큰) 설정은 ApiService 내부에서 자동으로 처리됩니다.
    final res = await ApiService.get("/auth/me");
    return res.data;
  }
}
