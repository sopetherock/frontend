import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/auth/login_choice_screen.dart';
import 'screens/auth/terms_aggreement_screens.dart';
import 'screens/auth/signup_screen_input_email.dart';
import 'screens/auth/email_login_screen.dart';
import 'screens/auth/password_reset_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/mypage/mypage_screen.dart';

import 'app/app.dart'; // AppRoot
import 'services/api_service.dart';

import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'services/fcm_service.dart';
import 'providers/timer_provider.dart';
import 'widgets/urgent_todo_widget.dart';

// 로컬 알림 플러그인 인스턴스 생성
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 알림 채널 정의
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  '벼락치기 알림',
  description: '벼락치기 실패 및 그룹 초대 알림을 위한 채널입니다.',
  importance: Importance.high,
);

// 백그라운드 메시지 처리 함수
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message received: ${message.data}");

  RemoteNotification? notification = message.notification;

  if (notification != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title ?? "벼락치기 알림",
      notification.body ?? "벼락치기 실패! 벼락을 못피해서 통구이가 되셨네요.",
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 알림 채널 생성
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 백그라운드 알림 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // API 서비스 초기화 (토큰 자동 주입)
  ApiService.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => TimerProvider(),
      child: const ZeusOnApp(),  // 🔥 MyApp → ZeusOnApp 교체 완료
    ),
  );
}

class ZeusOnApp extends StatelessWidget {
  const ZeusOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zeus On',
      theme: ThemeData(
        fontFamily: "Pretendard",
        useMaterial3: true,
      ),
      home: const AppRoot(), // 앱 시작 화면
    );
  }
}

