import '../config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert'; 

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // FCM 토큰 발급 및 백엔드에 저장 요청
  Future<void> initializeAndSaveToken(BuildContext context) async {
    await _fcm.requestPermission();

    final token = await _fcm.getToken(); // 토큰 발급

    if (token != null) {
      print("FCM Token: $token");
      // TODO:토큰을 백엔드 서버의 API에 전송하여 DB에 저장하는 로직 구현
      await _saveFCMTokenToServer(token); // 토큰을 서버에 저장하는 함수 호출 
    }

    // 포그라운드 메시지 수신 핸들러 등록
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 백그라운드 메시지 핸들러는 main() 밖에서 최상위 함수로 등록해야 함.
  }

  // FCM 토큰을 백엔드에 전송하여 DB에 저장하는 함수
  Future<void> _saveFCMTokenToServer(String fcmToken) async {
    // 현재 로그인된 유저의 ID 토큰(인증 토큰) 가져오기
    final idToken = await _auth.currentUser?.getIdToken();

    if (idToken == null) {
      print("Error: User is not authenticated. Cannot send FCM token.");
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('$kApiBase/fcm/token'), // 백엔드 토큰 저장 API 엔드포인트
        headers: {
          'Content-Type': 'application/json',
          // Authorization 헤더에 Bearer 스킴과 ID Token 포함 (Postman 설정과 동일)
          'Authorization': 'Bearer $idToken', 
        },
        body: jsonEncode({
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("FCM Token successfully saved to backend DB.");
      } else {
        print("Failed to save FCM Token. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error sending FCM token to server: $e");
    }
  }

  // 포그라운드 알림 수신 시 처리
  void _handleForegroundMessage(RemoteMessage message) {
    print("Foreground message received: ${message.data}");

    // 알림 데이터(message.data)를 파싱하여 '벼락치기 실패 팝업'을 띄우는 로직 구현
    // -> 그냥 무시
    return;
  } 
}