import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 숫자 입력 제한용
import '../../widgets/timer_display.dart';
import '../../services/timer_service.dart'; // 서비스 임포트

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TimerService _timerService = TimerService(); // 서비스 인스턴스
  
  // 입력 컨트롤러
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  bool isSubmitting = false;

  // 색상 상수
  final Color _iconYellow = const Color(0xFFFFED86);
  final Color _buttonPink = const Color(0xFFFE4B80);

  @override
  void dispose() {
    _todoController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // [Logic] 타이머 생성 요청
  Future<void> _handleCreateTimer() async {
    if (_todoController.text.isEmpty || _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('할 일과 시간을 모두 입력해주세요.')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // 데이터 가공
      int minutes = int.parse(_durationController.text);
      int durationInSeconds = minutes * 60;

      // 서비스 호출
      final newTimer = await _timerService.createPersonalTimer(
        todo: _todoController.text,
        durationInSeconds: durationInSeconds,
      );

      if (!mounted) return;

      // 성공 시 타이머 디스플레이 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TimerDisplayScreen(
            todoId: newTimer['id'],
            todo: newTimer['todo'],
            duration: newTimer['duration'],
            isGroup: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('타이머 생성에 실패했습니다. 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. 상단 뒤로가기 버튼
          _buildBackButton(context),

          // 2. 중앙 아이콘 (노란색 원)
          _buildCentralIcon(),

          // 3. 타이틀
          _buildTitle(),

          // 4. 입력 필드 1 (Todo)
          _buildTodoInput(),

          // 5. 입력 필드 2 (Duration)
          _buildDurationInput(),

          // 6. 하단 버튼 (할 일 추가하기)
          _buildSubmitButton(),
        ],
      ),
    );
  }

  // --- UI 위젯 메서드들 ---

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 61, left: 16,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.black),
      ),
    );
  }

  Widget _buildCentralIcon() {
    return Positioned(
      top: 84, left: 146, // (393 - 102) / 2 = 145.5
      child: Container(
        width: 102, height: 102,
        decoration: BoxDecoration(color: _iconYellow, shape: BoxShape.circle),
        child: const Center(
          child: Icon(Icons.edit_note, size: 40, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Positioned(
      top: 216, left: 0, right: 0,
      child: const Center(
        child: Text(
          '할 일 추가',
          style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildTodoInput() {
    return Positioned(
      top: 300, left: 23, right: 23,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("어떤 일을 하시겠어요?", style: TextStyle(color: Colors.grey)),
          TextField(
            controller: _todoController,
            decoration: const InputDecoration(
              hintText: '예: 수학 3단원 벼락치기',
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x5F000000))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationInput() {
    return Positioned(
      top: 400, left: 23, right: 23,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("목표 시간은 얼마인가요? (분)", style: TextStyle(color: Colors.grey)),
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: '예: 30', suffixText: '분',
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x5F000000))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Positioned(
      top: 703, left: 23, width: 347, height: 49,
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
                  width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  '할 일 추가하기',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),
                ),
        ),
      ),
    );
  }
}