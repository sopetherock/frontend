// lib/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://localhost:3000/api", // ← 너희 서버 URL
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  static String? _token;

  /// 앱 시작 시 초기화 (interceptor 설정)
  static void init() {
    dio.interceptors.clear();

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 토큰이 있으면 Authorization header 자동 추가
          if (_token != null) {
            options.headers["Authorization"] = "Bearer $_token";
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// Firebase Token을 저장하고 Dio가 자동으로 쓰도록 함
  static Future<void> setToken(String token) async {
    _token = token;
    init(); // ← interceptor 갱신
  }
}
