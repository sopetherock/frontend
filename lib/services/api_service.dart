import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  // 1. Dio 인스턴스 생성 및 기본 설정
  static final Dio _dio = Dio(
    BaseOptions(
      // 주의: 안드로이드 에뮬레이터는 'http://10.0.2.2:3000/api' 사용
      // iOS 시뮬레이터/웹은 'http://localhost:3000/api'
      baseUrl: "http://localhost:3000/api", 
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType: Headers.jsonContentType,
    ),
  );

  // 2. 초기화: 인터셉터 장착 (앱 시작 시 한 번만 호출)
  static void init() {
    _dio.interceptors.clear(); // 중복 방지

    _dio.interceptors.add(
      InterceptorsWrapper(
        // [요청 가로채기] 보내기 전에 토큰을 붙임
        onRequest: (options, handler) async {
          try {
            // 1) 현재 로그인된 유저 확인
            final user = FirebaseAuth.instance.currentUser;
            
            if (user == null) {
              // 로그인이 안 되어 있으면 에러 처리하거나 그냥 보냄 (백엔드에서 튕김)
              print("⚠️ [ApiService] 유저 정보 없음 (비로그인 상태)");
              return handler.next(options); 
            }

            // 2) Firebase에서 최신 토큰 강제 발급 (true: 강제 갱신)
            // 이렇게 하면 만료된 토큰이나 null을 보낼 일이 100% 사라집니다.
            final token = await user.getIdToken(true);
            
            // 3) 헤더에 붙이기
            options.headers['Authorization'] = 'Bearer $token';
            
            print("🚀 [API Request] ${options.method} ${options.path}");
            // print("🔑 Token: ${token.substring(0, 10)}..."); // 디버깅용

            return handler.next(options); // 다음 단계로 진행
          } catch (e) {
            print("🔥 [ApiService] 토큰 확보 실패: $e");
            return handler.reject(DioException(requestOptions: options, error: "토큰 발급 실패"));
          }
        },
        
        // [응답 가로채기] 에러 로그 편하게 보기
        onError: (DioException e, handler) {
          print("🔥 [API Error] ${e.response?.statusCode} : ${e.response?.data}");
          return handler.next(e);
        },
      ),
    );
    print("✅ ApiService Initialized (Dio)");
  }

  // --- 외부에서 쓰기 편하게 만든 헬퍼 메서드들 ---

  // GET 요청
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // POST 요청
  static Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  // PUT, DELETE 등 필요하면 추가...
}

