import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/app.dart'; // 자동 라우팅(AppRoot)
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ApiService.init(); // 🔥 중요한 부분

  runApp(const ZeusOnApp());
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
      home: const AppRoot(), // 🔥 앱 시작 화면
    );
  }
}
