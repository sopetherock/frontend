// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ⭐️ [내부 사용] 현재 로그인된 사용자에게 인증 메일을 발송합니다.
  Future<void> _sendVerificationEmail(User? user) async {
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  // 1. 회원가입 및 인증 메일 발송 로직 통합
  Future<void> signUpAndSendVerification({
    required String email, 
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // 유저 생성 후 분리된 함수를 호출하여 인증 메일 발송
    await _sendVerificationEmail(userCredential.user);
  }

  // 2. 인증 상태 갱신 및 확인 로직
  Future<bool> reloadUserAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    await user.reload(); // 최신 상태 갱신 (핵심!)
    final updatedUser = _auth.currentUser;
    
    return updatedUser?.emailVerified ?? false;
  }
  
  // ⭐️ 3. [추가] 비밀번호 재설정 메일 발송 로직
  // 비밀번호를 잊었을 때 사용합니다.
  Future<void> sendPasswordResetEmail({required String email}) async {
    // Firebase Auth 인스턴스를 사용하여 비밀번호 재설정 메일을 발송합니다.
    await _auth.sendPasswordResetEmail(email: email);
  }
}