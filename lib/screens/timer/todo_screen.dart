import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // iOS 스타일 피커용
import '../../services/timer_service.dart';
import '../../widgets/timer_display.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TimerService _timerService = TimerService();
  final TextEditingController _todoController = TextEditingController();

  // [변경] 마감 시간을 저장할 변수 (기본값: 현재시간 + 1시간)
  DateTime _selectedDeadline = DateTime.now().add(const Duration(hours: 1));

  bool isSubmitting = false;
  final Color _iconYellow = const Color(0xFFFFED86);
  final Color _buttonPink = const Color(0xFFFE4B80);

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  // 날짜/시간 선택 팝업 (CupertinoDatePicker 사용)
  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          color: Colors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime, // 날짜 + 시간 모드
            initialDateTime: _selectedDeadline,
            minimumDate: DateTime.now(), // 과거 날짜 선택 방지
            use24hFormat: false, // 오전/오후 표시
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                _selectedDeadline = newDateTime;
              });
            },
          ),
        );
      },
    );
  }

  // 타이머 생성 요청
  Future<void> _handleCreateTimer() async {
    if (_todoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('할 일을 입력해주세요.')),
      );
      return;
    }

    // 과거 시간 체크
    if (_selectedDeadline.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('마감 시간은 미래여야 합니다.')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // [변경] _selectedDeadline을 그대로 서버로 전송
      final newTimer = await _timerService.createPersonalTimer(
        todo: _todoController.text,
        deadline: _selectedDeadline,
      );

      if (!mounted) return;

      // 생성된 타이머 데이터를 가지고 화면 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TimerDisplayScreen(
            todoId: newTimer['id'],
            todo: newTimer['todo'],
            // 남은 시간(초) 계산해서 전달
            duration: _selectedDeadline.difference(DateTime.now()).inSeconds,
            deadline: _selectedDeadline, // 마감 시간 전달
            isGroup: false,
          ),
        ),
      );
    } catch (e) {
      print(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('생성 실패. 로그아웃 후 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  // 날짜 포맷팅 헬퍼 함수 (예: 11월 20일 14:30)
  String _formatDeadline(DateTime dt) {
    return "${dt.month}월 ${dt.day}일 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. 뒤로가기
          Positioned(
            top: 61,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.black),
            ),
          ),

          // 2. 아이콘 & 타이틀
          Positioned(
            top: 84,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 102,
                  height: 102,
                  decoration: BoxDecoration(color: _iconYellow, shape: BoxShape.circle),
                  child: const Center(child: Icon(Icons.edit_note, size: 40, color: Colors.black)),
                ),
                const SizedBox(height: 30),
                const Text(
                  '할 일 추가',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),

          // 3. 입력 폼 (할일 + 마감시간)
          Positioned(
            top: 300,
            left: 23,
            right: 23,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 할 일 입력
                const Text("어떤 일을 하시겠어요?", style: TextStyle(color: Colors.grey)),
                TextField(
                  controller: _todoController,
                  decoration: const InputDecoration(
                    hintText: '예: 수학 3단원 벼락치기',
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 40),

                // 마감 시간 선택 (버튼 형태)
                const Text("언제까지 끝내실 건가요? (마감기한)", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _showDatePicker, // 다이얼 띄우기
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 선택된 날짜 표시
                        Text(
                          _formatDeadline(_selectedDeadline),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "설정하기 >",
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. 완료 버튼
          Positioned(
            bottom: 50, // 하단 여백
            left: 23,
            right: 23,
            height: 49,
            child: GestureDetector(
              onTap: isSubmitting ? null : _handleCreateTimer,
              child: Container(
                decoration: BoxDecoration(
                  color: _buttonPink,
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        '할 일 추가하기',
                        style: TextStyle(
                          fontFamily: 'Inter',
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
    );
  }
}