// lib/screens/notifications/friend_fail_alert_screen.dart

import 'package:flutter/material.dart';

class FriendFailAlertScreen extends StatelessWidget {
  // 이 화면은 친구의 실패 알림을 보여줍니다.
  // 백엔드 연동은 나중에 할 예정이므로, 현재는 임시 친구 이름을 사용
  final String failedFriendName = "채현";
  
  const FriendFailAlertScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold는 기본 화면 구조를 제공합니다.
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      
      // 앱바는 CSS에 포함된 상태 표시줄(Status Bar) 및 네비게이션을 무시하고, 
      // 깔끔한 UI를 위해 비워두거나 PreferredSize로 처리할 수 있습니다.
      // 현재는 간단히 비워둡니다.
      // appBar: AppBar(elevation: 0, backgroundColor: Colors.white),

      body: SafeArea(
        child: Column(
          // 전체 내용을 중앙 정렬
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ----------------------------------------------------
            // 1. 캐릭터 이미지
            // CSS: image 13 (width: 187px, height: 202px)
            // ----------------------------------------------------
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Image.asset(
                'assets/images/level icon(Lv.3).png', 
                width: 187,
                height: 202,
                fit: BoxFit.contain,
              ),
            ),
            
            // ----------------------------------------------------
            // 2. 메시지 텍스트
            // CSS: '채현님이 벼락치기에 실패했어요... 벼락을 쳐주세요!' (top: 469px)
            // ----------------------------------------------------
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 150), // 이미지와 버튼 사이 간격 조정
              child: Text(
                '$failedFriendName님이 벼락치기에 실패했어요...\n벼락을 쳐주세요!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  // font-family: 'Inter'
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.2, // line-height: 19px 근사치
                  color: Color(0xFF000000),
                ),
              ),
            ),
            
            // ----------------------------------------------------
            // 3. 버튼 영역 (최하단에 배치하기 위해 Expanded 사용)
            // ----------------------------------------------------
            const Spacer(), // 남은 공간을 차지하여 버튼들을 아래로 밀어냅니다.
            
            // 벼락 치기 버튼 (Yellow)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16), // left: 15px, 16px 근사치
              width: double.infinity, // width: 361px
              height: 50, // height: 50px
              child: TextButton(
                onPressed: () {
                  // TODO: 벼락 치기 액션 구현 (백엔드 연동)
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE65B), // background: #FFE65B
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // border-radius: 10px
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '벼락 치기',
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15, // font-size: 15px
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 14), // 두 버튼 사이의 간격

            // 다음에 하기 버튼 (White)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16), // left: 16px 근사치
              width: double.infinity, // width: 361px
              height: 50, // height: 50px
              child: TextButton(
                onPressed: () {
                  // TODO: 다음에 하기 액션 구현 (화면 닫기/이동)
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFFFF), // background: #FFFFFF
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // border-radius: 10px
                    // CSS의 Rectangle 153의 border는 현재 생략 (필요시 BoxDecoration에 추가 가능)
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '다음에 하기',
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15, // font-size: 15px
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 34), // Home Indicator 공간 확보
          ],
        ),
      ),
    );
  }
}