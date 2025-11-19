//Flutter의 modal dialog(showDialog에서 사용)로 기능하도록 AlertDialog 형태가 아닌 사용자 정의 Dialog 위젯으로 구현
import 'package:flutter/material.dart';

class GroupInviteAlertScreen extends StatelessWidget {
  // 백엔드 연동 전이므로 임시 데이터를 사용합니다.
  final String inviterNickname = "채채";
  final String deadline = "00일 00시 00분";

  const GroupInviteAlertScreen({Key? key}) : super(key: key);

  // 버튼 스타일 정의
  ButtonStyle _buttonStyle({Color? backgroundColor, Color? borderColor}) {
    return TextButton.styleFrom(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // border-radius: 5px
        side: borderColor != null ? BorderSide(color: borderColor, width: 1) : BorderSide.none,
      ),
      elevation: 0,
      minimumSize: const Size(330, 49), // width: 330px, height: 49px
      padding: EdgeInsets.zero,
    );
  }

  // 텍스트 스타일 정의 (Pretendard-Medium 사용 가정)
  TextStyle _textStyle({double fontSize = 15, FontWeight fontWeight = FontWeight.w400, Color color = Colors.black}) {
    return TextStyle(
      // CSS에는 Inter로 되어있으나, 요청에 따라 Pretendard 사용을 가정
      fontFamily: 'Pretendard-Medium', 
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.2, // line-height: 21px / 17px 근사치
      letterSpacing: -0.5, // 폰트에 따라 조정 필요
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dialog 위젯으로 모달 형태 구현
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent, // 기본 배경을 투명하게 설정
      // 모달의 크기와 형태를 정의하는 Container (Rectangle 132)
      child: Container(
        width: 361, // width: 361px
        height: 280, // height: 280px
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), // background: #FFFFFF
          borderRadius: BorderRadius.circular(15), // border-radius: 15px
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내부 요소 크기에 맞춤
          children: [
            const SizedBox(height: 40), // 상단 여백 (top: 461px 근사치)

            // 1. 초대 메시지
            // CSS: left: 83px, top: 461px, font-size: 17px, font-weight: 500
            Text(
              '$inviterNickname님이 $deadline 까지인 벼락치기에 초대했어요!',
              textAlign: TextAlign.center,
              style: _textStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF000000),
              ),
            ),

            const SizedBox(height: 25), // 버튼 상단 여백 (top: 528px 근사치)

            // 2. 수락하기 버튼 (Group 88 / Rectangle 87: #FFCCCC)
            SizedBox(
              width: 330,
              height: 49,
              child: TextButton(
                onPressed: () {
                  // TODO: 수락 API 호출 및 그룹 타이머로 이동
                  Navigator.of(context).pop(true); // 팝업 닫기 및 수락 결과 반환
                },
                style: _buttonStyle(
                  backgroundColor: const Color(0xFFFFCCCC), // background: #FFCCCC (연한 핑크)
                ),
                child: Text(
                  '수락하기', // left: 171px, font-size: 15px
                  style: _textStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            
            const SizedBox(height: 8), // 버튼 간 간격 (585px - 528px - 49px = 8px)

            // 3. 거절하기 버튼 (Group 87 / Rectangle 133: border: 1px solid #666666)
            SizedBox(
              width: 330,
              height: 49,
              child: TextButton(
                onPressed: () {
                  // TODO: 거절 API 호출
                  Navigator.of(context).pop(false); // 팝업 닫기 및 거절 결과 반환
                },
                style: _buttonStyle(
                  backgroundColor: const Color(0xFFFFFFFF),
                  borderColor: const Color(0xFF666666), // border: 1px solid #666666
                ),
                child: Text(
                  '거절하기', // left: 171px, font-size: 15px
                  style: _textStyle(fontSize: 15, fontWeight: FontWeight.w400, color: const Color(0xFF000000)),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 4. 하단 흐린 메시지
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '수락하면 그룹 타이머로 이동됩니다 그룹 타이머 실행 시 앱을 종료했을 때 벼락을 맞게 됩니다!',
                textAlign: TextAlign.center,
                style: _textStyle(
                  fontSize: 11, // 흐린 메시지는 작게 설정
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF666666), // 흐린 색상
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}