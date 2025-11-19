import 'package:flutter/material.dart';
import 'todo_screen.dart';
import '../../widgets/timer_display.dart';
import '../../services/timer_service.dart'; // [New] 서비스 임포트
import '../../widgets/CustomBottomNavigationBar.dart';

class PersonalTimerScreen extends StatefulWidget {
  const PersonalTimerScreen({super.key});

  @override
  State<PersonalTimerScreen> createState() => _PersonalTimerScreenState();
}

class _PersonalTimerScreenState extends State<PersonalTimerScreen> {
  // 서비스 인스턴스 생성
  final TimerService _timerService = TimerService();
  
  bool isLoading = true;
  List<dynamic> personalTimers = [];
  List<dynamic> groupTimers = [];

  // 색상 상수
  final Color _primaryPink = const Color(0xFFFE4B80);
  final Color _buttonYellow = const Color(0xFFFFE65B);

  @override
  void initState() {
    super.initState();
    _loadTimers();
  }

  // [Logic] 서비스 호출
  Future<void> _loadTimers() async {
    try {
      final timers = await _timerService.fetchRunningTimers();
      if (mounted) {
        setState(() {
          personalTimers = timers['personal']!;
          groupTimers = timers['group']!;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      // 필요 시 스낵바 등으로 에러 표시
      print(e);
    }
  }

  // [Logic] 화면 이동 로직
  void _goToTimerDisplay(Map<String, dynamic> timerData, bool isGroup) {
    // 서비스의 계산 로직 사용
    int initialDuration = _timerService.calculateInitialDuration(timerData, isGroup);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerDisplayScreen(
          todoId: isGroup ? timerData['groupId'] : timerData['id'],
          todo: isGroup ? timerData['group']['todo'] : timerData['todo'],
          duration: initialDuration,
          deadline: isGroup ? DateTime.parse(timerData['group']['deadline']) : null,
          isGroup: isGroup,
        ),
      ),
    ).then((_) => _loadTimers()); // 돌아오면 목록 갱신
  }

  @override
  Widget build(BuildContext context) {
    bool hasData = personalTimers.isNotEmpty || groupTimers.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. 상단 헤더
          _buildHeader(),

          // 2. 메인 콘텐츠
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (!hasData)
            _buildEmptyState()
          else
            _buildTimerList(),

          // 3. 하단 네비게이션 바
          _buildBottomNavBar(),

          // 4. 추가 버튼 (FAB)
          _buildFloatingActionButton(),
        ],
      ),
    );
  }

  // --- UI 위젯 분리 메서드들 ---

  Widget _buildHeader() {
    return Stack(
      children: [
        Positioned(
          top: 0, left: 0, right: 0, height: 100,
          child: Container(color: _primaryPink),
        ),
        Positioned(
          top: 61, left: 0, right: 0,
          child: const Center(
            child: Text(
              '타이머',
              style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Stack(
      children: [
        Positioned(
          top: 215, left: 116,
          child: Container(
            width: 161, height: 184,
            color: Colors.grey[200],
            child: const Icon(Icons.image, color: Colors.grey, size: 50),
          ),
        ),
        const Positioned(
          top: 416, left: 0, right: 0,
          child: Center(
            child: Text(
              '우왕 할 일이 없어요!\n할 일을 추가해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black, height: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerList() {
    final allTimers = [
      ...personalTimers.map((t) => {'type': 'personal', ...t}),
      ...groupTimers.map((t) => {'type': 'group', ...t}),
    ];

    return Positioned.fill(
      top: 100, bottom: 80,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: allTimers.length,
        itemBuilder: (context, index) {
          final item = Map<String, dynamic>.from(allTimers[index]);
          final isGroup = item['type'] == 'group';
          final title = isGroup ? item['group']['todo'] : item['todo'];

          return GestureDetector(
            onTap: () => _goToTimerDisplay(item, isGroup),
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFB6B6B6)),
              ),
              child: Row(
                children: [
                  Icon(isGroup ? Icons.group : Icons.person, color: _primaryPink),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      title ?? '할 일 없음',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildFloatingActionButton() {
    return Positioned(
      right: 33, bottom: 100,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TodoScreen()),
          ).then((_) => _loadTimers());
        },
        child: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: _buttonYellow,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: const Center(child: Icon(Icons.add, color: Colors.black, size: 27)),
        ),
      ),
    );
  }
}