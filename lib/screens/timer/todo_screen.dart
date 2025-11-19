// lib/screens/timer/todo_screen.dart

import 'package:flutter/material.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  
  // 🌟 Duration을 저장할 변수 (기본값: 1시간)
  Duration _selectedDuration = const Duration(hours: 1); 
  
  // 디자인에서 추출한 색상
  static const Color _primaryColor = Color(0xFFFE4B80); // 버튼 색상
  static const Color _yellowCircleColor = Color(0xFFFFED86); // 상단 원 색상

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
  
  // 🌟 시간 선택기 (Time Picker) 로직
  Future<void> _selectDuration() async {
    // 임시로 Hour/Minute 피커를 사용하여 Duration을 설정합니다.
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime(0, 0, 0, _selectedDuration.inHours, _selectedDuration.inMinutes % 60)),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), 
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        // 선택된 시간을 Duration으로 변환 (시간과 분만 사용)
        _selectedDuration = Duration(
          hours: pickedTime.hour,
          minutes: pickedTime.minute,
        );
      });
    }
  }

  // 🌟 폼 제출 및 데이터 반환 로직
  void _submitTodo() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDuration.inSeconds == 0) {
        // 시간이 0이면 알림
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('마감시간은 0초 이상이어야 합니다.')),
        );
        return;
      }
      
      // 1. 새로운 할 일 모델 (임시) 생성
      // 이전에 정의한 TimerTodo 모델을 사용합니다. (ID와 isCompleted는 임시값)
      final newTodo = TimerTodo(
        DateTime.now().microsecondsSinceEpoch.toString(), // 임시 ID
        _titleController.text,
        // UI 표시용 시간 형식으로 저장 (실제 백엔드 통신 시에는 Duration 자체를 보낼 수도 있습니다)
        "${_selectedDuration.inHours.toString().padLeft(2, '0')}:"
        "${_selectedDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:00",
        false, // 미완료 상태
      );
      
      // 2. Navigator.pop을 통해 데이터 (Duration 및 Todo List)를 이전 화면으로 반환
      Navigator.of(context).pop({
        'duration': _selectedDuration,
        // 단일 할 일 추가이므로 리스트 형태로 반환
        'todoList': [newTodo], 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // 1. 뒤로가기 버튼
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // 2. AppBar 커스터마이징 (디자인에 따라 투명하게 설정)
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // 3. 상단 아이콘 영역 (Group 75)
              Container(
                width: 102,
                height: 102,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _yellowCircleColor, // #FFED86
                ),
                child: const Icon(Icons.group, size: 54, color: Colors.black), // group 아이콘
              ),
              const SizedBox(height: 10),
              
              // 4. "할 일 추가" 텍스트
              const Text(
                '할 일 추가', // 디자인의 텍스트
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 50),
              
              // 5. 할 일 제목 입력 필드
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '할 일 제목을 입력해주세요',
                  border: UnderlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '할 일 제목은 필수입니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // 6. 구분선 (Line 19)
              const Divider(color: Colors.black54, thickness: 1),
              const SizedBox(height: 40),

              // 7. 마감 시간 선택 영역
              ListTile(
                title: const Text('마감시간 설정 (Duration)'),
                subtitle: Text(
                  // 선택된 Duration을 HH:MM 형식으로 표시
                  '${_selectedDuration.inHours.toString().padLeft(2, '0')}시간 '
                  '${_selectedDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}분',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.access_time),
                onTap: _selectDuration,
              ),
            ],
          ),
        ),
      ),
      
      // 8. 하단 '할 일 추가하기' 버튼 (Group 15)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(23.0),
        child: SizedBox(
          height: 49,
          child: ElevatedButton(
            onPressed: _submitTodo,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor, // #FE4B80
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            child: const Text('할 일 추가하기', style: TextStyle(
              fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400,
            )),
          ),
        ),
      ),
    );
  }
}