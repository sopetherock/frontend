import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://localhost:3000/api",
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
          if (_token != null) {
            options.headers["Authorization"] = "Bearer $_token";
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// 🔥 friends_screen.dart 에서 사용하는 메서드 추가
  static Future<void> setToken(String token) async {
    _token = token;
  }

  /// 토큰 제거가 필요하면 (선택)
  static Future<void> clearToken() async {
    _token = null;
  }
}

