// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ApiService.init();

  runApp(const ZeusOnApp());
}

class ZeusOnApp extends StatelessWidget {
  const ZeusOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zeus On',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        useMaterial3: true,
      ),
      home: const AppRoot(),
    );
  }
}
