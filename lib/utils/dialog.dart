import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 인증 메일 발송 후 사용자에게 상태 확인을 요청하는 팝업을 표시합니다.
void showVerificationDialog(BuildContext context) {
  showDialog(
    context: context,
    // 사용자가 외부 탭으로 팝업을 닫지 못하게 강제하여 인증을 유도합니다.
    barrierDismissible: false, 
    builder: (BuildContext dialogContext) {
      // FirebaseAuth 인스턴스를 가져옵니다.
      final user = FirebaseAuth.instance.currentUser;
      
      // 이미 인증된 상태이거나 유저가 없다면 팝업을 띄울 이유가 없으므로 닫습니다.
      if (user == null || user.emailVerified) {
          Navigator.of(dialogContext).pop();
          return const SizedBox.shrink(); // 비어있는 위젯 반환
      }

      return AlertDialog(
        title: const Text('📧 이메일 인증이 필요합니다'),
        content: const Text(
            '가입하신 이메일로 인증 메일이 발송되었습니다. 메일함에서 링크를 클릭한 후 아래 버튼을 눌러주세요.'),
        actions: <Widget>[
          // 1. 메일 재발송 버튼
          TextButton(
            child: const Text('메일 다시 보내기'),
            onPressed: () async {
              try {
                // 현재 유저에게 재발송 요청
                await user.sendEmailVerification(); 
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('인증 메일을 다시 보냈습니다.')),
                );
              } catch (e) {
                print('메일 재발송 오류: $e');
              }
            },
          ),
          
          // 2. 인증 완료 확인 버튼 (핵심 로직)
          ElevatedButton(
            child: const Text('✅ 인증 완료 확인'),
            onPressed: () async {
              // 🌟🌟🌟 가장 중요한 단계: 서버에서 최신 유저 정보를 강제 갱신 🌟🌟🌟
              await user.reload(); 
              
              // 갱신된 정보를 반영하여 현재 유저 객체를 다시 가져옵니다.
              final updatedUser = FirebaseAuth.instance.currentUser;

              if (updatedUser != null && updatedUser.emailVerified) {
                // 인증 성공!
                Navigator.of(dialogContext).pop(); // 팝업 닫기
                
                // TODO: 인증 성공 후 메인 화면으로 이동하는 로직을 여기에 추가해야 합니다.
                // 예: Navigator.of(context).pushReplacementNamed('/home');
                
              } else {
                // 아직 인증이 완료되지 않음
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('아직 인증이 완료되지 않았습니다. 메일 확인 후 다시 시도해 주세요.')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}