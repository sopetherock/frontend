// lib/screens/timer/personal_timer_screen.dart

import 'package:flutter/material.dart';
// TimerDisplay 위젯 및 todo_screen 파일 경로 import
import '../../widgets/timer_display.dart'; 
import '../todo/todo_screen.dart'; // [TODO] 실제 경로 확인 필요

// [TODO] 실제 구현 시 models/todo.dart 사용해야 함
class TimerTodo {
  final String id;
  final String title;
  final String deadlineTime;
  final bool isCompleted;

  const TimerTodo(this.id, this.title, this.deadlineTime, this.isCompleted);
}

class PersonalTimerScreen extends StatefulWidget {
  const PersonalTimerScreen({super.key});

  @override
  State<PersonalTimerScreen> createState() => _PersonalTimerScreenState();
}

class _PersonalTimerScreenState extends State<PersonalTimerScreen> {
  // 🌟 임시 활성 타이머 상태 (실제는 Provider나 DB에서 가져와야 함)
  bool _hasActiveTimer = false;
  Duration _activeDuration = Duration.zero;
  List<TimerTodo> _activeTodos = [];

  // 디자인에서 추출한 색상
  static const Color _primaryColor = Color(0xFFFE4B80); // 상단바, 버튼색
  static const Color _addButtonColor = Color(0xFFFFE65B); // '+' 버튼 색상

  @override
  void initState() {
    super.initState();
    // [TODO] 초기 DB/Provider에서 활성 타이머 상태를 확인하는 로직 필요
    // _checkActiveTimer(); 
  }

  // 🌟 [추가] 타이머 완료 처리 및 결과 화면 이동 함수
  void _onTimerCompleted() {
    required TimerResultType type, 
    required Duration timeDiff, 
    required String taskName,
    required int questReward,
    // 1. 타이머 상태를 '없음'으로 변경하여 Empty State로 전환 준비
    setState(() {
      _hasActiveTimer = false;
      _activeDuration = Duration.zero;
      _activeTodos = [];
    });
    
    // 2. 결과 화면으로 이동
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TimerResultScreen(
          resultType: type, // 🌟 성공/실패 유형 전달
          taskName: taskName,
          timeDifference: timeDiff,
          questReward: questReward,
        ),
      ),
    );
  }
  // 🌟 [수정] _buildBody: TimerDisplay에 콜백 전달
  Widget _buildBody() {
    if (_hasActiveTimer) {
      // 1. 활성 타이머가 있을 때: TimerDisplay 위젯 호출
      return TimerDisplay(
        initialDuration: _activeDuration,
        todoList: _activeTodos,
        // 🌟 콜백 전달 시, 함수 자체를 그대로 전달합니다.
        onCompletion: _onTimerCompleted, 
      );
    } else {
      // 2. 활성 타이머가 없을 때: Empty State UI 표시
      return _buildEmptyState();
    }
  }

  // 🌟 [+] 버튼 클릭 핸들러: todo_screen으로 이동
  void _navigateToAddTodo() async {
    // todo_screen으로 이동하며 결과를 기다립니다.
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TodoScreen(), // todo_screen.dart로 이동
      ),
    );

    // [TODO] TodoScreen에서 {duration: Duration, todoList: List<Todo>} 같은 객체를 반환했다고 가정
    if (result != null && result is Map) {
      final Duration newDuration = result['duration'] ?? Duration.zero;
      final List<TimerTodo> newTodos = result['todoList'] ?? [];
      
      if (newDuration.inSeconds > 0 && newTodos.isNotEmpty) {
        setState(() {
          _hasActiveTimer = true;
          _activeDuration = newDuration;
          _activeTodos = newTodos;
        });
      }
    }
  }
  
  // 🌟 상태에 따라 다른 위젯을 반환하는 핵심 분기 함수 🌟
  Widget _buildBody() {
    if (_hasActiveTimer) {
      // 1. 활성 타이머가 있을 때: TimerDisplay 위젯 호출
      return TimerDisplay(
        initialDuration: _activeDuration,
        todoList: _activeTodos,
        onCompletion: _onTimerCompleted, // 🌟 TimerDisplay에 콜백 전달
      );
    } else {
      // 2. 활성 타이머가 없을 때: Empty State UI 표시
      return _buildEmptyState();
    }
  }

  // 🌟 Empty State UI 구현
  Widget _buildEmptyState() {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // "우왕 할 일이 없어요! 할 일을 추가해보세요" 메시지
          Positioned(
            top: 416, // 디자인의 위치 반영
            child: const Text(
              '우왕 할 일이 없어요!\n할 일을 추가해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          
          // [TODO] 이미지 placeholder (제목_없는_아트워크 65)
          Positioned(
            top: 215,
            child: Container(
              width: 161,
              height: 184,
              color: Colors.grey.shade200, // 이미지 Placeholder
              alignment: Alignment.center,
              child: const Text('아트워크 이미지\n(assets/...')
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // 1. 상단 타이틀 바 (Rectangle 144)
      appBar: AppBar(
        toolbarHeight: 100, // 높이 100px
        backgroundColor: _primaryColor,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        title: const Text('타이머', style: TextStyle(
          fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white,
        )),
        centerTitle: true,
        // TODO: 좌측 keyboard_arrow_down(90deg 회전) 아이콘 추가
      ),
      
      body: Column(
        children: [
          _buildBody(), // 상태에 따라 Empty or TimerDisplay 위젯 표시
          // TODO: 하단 네비게이션 바 (Group 105) 위젯 추가
          SizedBox(height: 77 + 34), // 하단바 공간 확보
        ],
      ),
      
      // 3. [+] 추가 버튼 (Rectangle 153)
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTodo,
        backgroundColor: _addButtonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: const Text('+', style: TextStyle(fontSize: 28, color: Colors.black)),
      ),
      // FAB 위치를 디자인에 맞게 조정하려면 FloatingActionButtonLocation을 사용해야 합니다.
    );
  }
}