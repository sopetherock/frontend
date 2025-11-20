import 'package:flutter/material.dart';
import 'todo_screen.dart';
import '../../widgets/timer_display.dart';
import '../../services/timer_service.dart';
import '../../widgets/CustomBottomNavigationBar.dart'; 

class PersonalTimerScreen extends StatefulWidget {
  const PersonalTimerScreen({super.key});

  @override
  State<PersonalTimerScreen> createState() => _PersonalTimerScreenState();
}

class _PersonalTimerScreenState extends State<PersonalTimerScreen> {
  final TimerService _timerService = TimerService();
  bool isLoading = true;
  List<dynamic> personalTimers = [];
  List<dynamic> groupTimers = [];

  final Color _primaryPink = const Color(0xFFFE4B80);
  final Color _buttonYellow = const Color(0xFFFFE65B);

  @override
  void initState() {
    super.initState();
    _loadTimers();
  }

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
      print(e);
    }
  }

  void _goToTimerDisplay(Map<String, dynamic> timerData, bool isGroup) {
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
    ).then((_) => _loadTimers());
  }

  @override
  Widget build(BuildContext context) {
    bool hasData = personalTimers.isNotEmpty || groupTimers.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      // [수정] 화면 전체를 꽉 채워서 정렬 문제 해결
      body: Stack(
        fit: StackFit.expand, 
        children: [
          Column(
            children: [
              // 상단 헤더
              Container(
                height: 100,
                color: _primaryPink,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 15),
                child: const Text(
                  '타이머',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white),
                ),
              ),
              
              // 메인 콘텐츠
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : hasData
                        ? _buildTimerList()
                        : _buildEmptyState(),
              ),
            ],
          ),

          // 하단 네비게이션 바 (바닥 고정)
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: CustomBottomNavigationBar(),
          ),

          // 추가 버튼 (FAB)
          Positioned(
            right: 33,
            bottom: 100, // 네비게이션 바 위로 띄움
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: const Center(child: Icon(Icons.add, color: Colors.black, size: 27)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // [수정] 중앙 정렬을 확실하게 하기 위해 Column 사용
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 161, height: 184,
          color: Colors.grey[200],
          child: const Icon(Icons.image, color: Colors.grey, size: 50),
        ),
        const SizedBox(height: 20),
        const Text(
          '우왕 할 일이 없어요!\n할 일을 추가해보세요',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.black, height: 1.2),
        ),
        const SizedBox(height: 80), // 하단바에 가려지지 않게 여백 추가
      ],
    );
  }

  Widget _buildTimerList() {
    final allTimers = [
      ...personalTimers.map((t) => {'type': 'personal', ...t}),
      ...groupTimers.map((t) => {'type': 'group', ...t}),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // 하단 여백 확보
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
    );
  }
}