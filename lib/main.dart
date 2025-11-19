import 'package:flutter/material.dart';
import 'screens/auth/login_choice_screen.dart';
import 'screens/auth/terms_aggreement_screens.dart';
import 'screens/auth/signup_screen_input_email.dart';
import 'screens/auth/email_login_screen.dart';
import 'screens/auth/password_reset_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/mypage/mypage_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <--- 이 파일이 위 config JSON 역할을 대신합니다.
import 'app/app.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (firebase_options.dart 파일의 내용 필요)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 실제 환경에 따라 주석 해제
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppRoot(),
      debugShowCheckedModeBanner: false,
    );
  }
}
