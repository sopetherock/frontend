import 'package:flutter/material.dart';
import '../auth/signup_choice_screen.dart';

// ============= 약관 동의 화면 ============= //

class TermsAgreementScreen extends StatefulWidget {
  const TermsAgreementScreen({super.key});

  @override
  State<TermsAgreementScreen> createState() => _TermsAgreementScreenState();
}

class _TermsAgreementScreenState extends State<TermsAgreementScreen> {
  bool allAgree = false;
  bool isOver14 = false;
  bool termsAgree = false;
  bool privacyAgree = false;

  Color get pink => const Color(0xFFFE4B80);

  bool get isRequiredAllChecked => isOver14 && termsAgree && privacyAgree;

  void _toggleAll(bool? value) {
    final v = value ?? false;
    setState(() {
      allAgree = v;
      isOver14 = v;
      termsAgree = v;
      privacyAgree = v;
    });
  }

  void _syncAllFlag() {
    final now = isOver14 && termsAgree && privacyAgree;
    setState(() {
      allAgree = now;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),

            // 제목
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'zeus on',
                      style: TextStyle(
                        fontFamily: 'Modulus', // pubspec에 등록된 폰트 기준
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.04,
                        height: 37 / 36,
                        color: pink,
                      ),
                    ),
                    Text(
                      '약관동의',
                      style: TextStyle(
                        fontFamily: 'Modulus', // pubspec에 등록된 폰트 기준
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.04,
                        height: 37 / 36,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                )),

            const SizedBox(height: 100),

            // 모두 동의
            _CheckRow(
              value: allAgree,
              title: '모두 동의합니다.',
              onChanged: _toggleAll,
            ),

            const SizedBox(height: 50),

            // 만 14세 이상
            _CheckRow(
              value: isOver14,
              title: '만 14세 이상입니다',
              onChanged: (v) {
                setState(() => isOver14 = v ?? false);
                _syncAllFlag();
              },
            ),

            const SizedBox(height: 20),

            // [필수] 이용약관 동의
            _CheckRow(
              value: termsAgree,
              title: '[필수] 이용약관 동의',
              onChanged: (v) {
                setState(() => termsAgree = v ?? false);
                _syncAllFlag();
              },
            ),

            const SizedBox(height: 20),

            // [필수] 개인정보 수집 및 이용 동의
            _CheckRow(
              value: privacyAgree,
              title: '[필수] 개인정보 수집 및 이용 동의',
              onChanged: (v) {
                setState(() => privacyAgree = v ?? false);
                _syncAllFlag();
              },
            ),

            const SizedBox(height: 80),

            // 동의하기 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 0, 23, 24),
              child: SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: isRequiredAllChecked
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpChoiceScreen()),
                          );
                        }
                      : null, // 필수 항목 안 체크되면 비활성화
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pink,
                    disabledBackgroundColor: pink.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '동의하기',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 체크박스 + 텍스트 한 줄
class _CheckRow extends StatelessWidget {
  final bool value;
  final String title;
  final ValueChanged<bool?> onChanged;

  const _CheckRow({
    required this.value,
    required this.title,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 19,
              height: 19,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                side: const BorderSide(color: Colors.black, width: 2),
                activeColor: Colors.black,
                checkColor: Colors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
