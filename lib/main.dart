import 'package:flutter/material.dart';
import 'screens/auth/login_choice_screen.dart';
import 'screens/auth/terms_aggreement_screens.dart';
import 'screens/auth/signup_screen_input_email.dart';
import 'screens/auth/email_login_screen.dart';
import 'screens/auth/password_reset_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/mypage/mypage_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/app.dart'; // 자동 라우팅(AppRoot)
import 'services/api_service.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (firebase_options.dart 파일의 내용 필요)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 실제 환경에 따라 주석 해제
  );

  ApiService.init(); // 🔥 중요한 부분

  runApp(const ZeusOnApp());
}

class ZeusOnApp extends StatelessWidget {
  const ZeusOnApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zeus On',
      theme: ThemeData(
        fontFamily: "Pretendard",
        useMaterial3: true,
      ),
      home: const AppRoot(), // 🔥 앱 시작 화면
    );
  }
}
