// lib/screens/auth/signup_screen.dart (일부)

import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // 2번에서 만든 서비스
import '../../utils/dialog.dart'; // 팝업 함수

final _authService = AuthService();

void _handleSignUp() async {
  // ... 이메일, 비밀번호 입력값 가져오기 ...
  
  try {
    await _authService.signUpAndSendVerification(email: email, password: password);
    
    // 🌟 성공 시 UI 로직: 팝업 띄우기 🌟
    showVerificationDialog(context); 

  } catch (e) {
    // ... 에러 처리
  }
}