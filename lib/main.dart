import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/services/fcm_service.dart';
import 'package:frontend/providers/timer_provider.dart';
import 'package:frontend/widgets/urgent_todo_widget.dart';

// 로컬 알림 플러그인 인스턴스 생성
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 알림 채널 정의 (Android 8.0/Oreo 이상 필수)
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // ID: 백엔드에서 전송 시 이 ID를 사용해야 합니다.
  '벼락치기 알림', // Name
  description: '벼락치기 실패 및 그룹 초대 알림을 위한 채널입니다.',
  importance: Importance.high,
);

// 백그라운드/종료 상태에서 알림 처리하는 최상위 함수
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message received: ${message.data}");
  // TODO: 백그라운드 알림 처리 로직
  // OS 알림: 벼락치기에 실패하셨어요!
  // 백엔드에서 data 페이로드만 보냈을 경우에 유효
  RemoteNotification? notification = message.notification;

  // 백엔드에서 notification 필드를 함께 보냈을 경우
  if (notification != null) {
      // 벼락치기 실패 알림에 사용할 임시 제목과 내용 정의
      String title = notification.title ?? "벼락치기 알림";
      String body = notification.body ?? "벼락치기 실패! 벼락을 못피해서 통구이가 되셨네요.";

      flutterLocalNotificationsPlugin.show(
        // 알림 ID (여러 알림 구분을 위해 랜덤 ID 사용)
        notification.hashCode, 
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id, // 위에서 정의한 채널 ID 사용
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher', // 앱 아이콘 설정
          ),
          // iOS 설정은 추가 구성이 필요할 수 있음
        ),
        // payload: message.data.toString(), // 알림 클릭 시 전달할 데이터
      );
  }
}
void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase Core 초기화
  // 로컬 알림 초기화 및 채널 생성 (android 전용)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => TimerProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      home: const UrgentTodoWidget(),
    );  
  }
}
