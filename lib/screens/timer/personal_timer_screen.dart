import 'package:flutter/material.dart';
import 'todo_screen.dart';
import '../../widgets/timer_display.dart';
import '../../services/timer_service.dart';
import '../../widgets/CustomBottomNavigationBar.dart'; 
// [New] Route Observer를 쓰기 위해 필요
import 'dart:async'; 
// [New] routeObserver가 정의된 파일 경로 import (예시: lib/app/app.dart)
import '../../main.dart';

class PersonalTimerScreen extends StatefulWidget {
  const PersonalTimerScreen({super.key});

  @override
  // [확인] State 클래스 이름도 맞는지 확인
  State<PersonalTimerScreen> createState() => _PersonalTimerScreenState();
}

class _PersonalTimerScreenState extends State<PersonalTimerScreen>with RouteAware {
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
  // 2. [New] Observer 구독 시작
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Observer 구독: 이 화면이 Route 변화를 감지하게 됩니다.
    // [수정] ModalRoute 대신 routeObserver에 subscribe 호출
    final route = ModalRoute.of(context);
  
  // RouteObserver.subscribe는 PageRoute만 받으므로 타입 체크 후 구독합니다.
    if (route is PageRoute) { 
    // 전역 routeObserver 변수에 이 화면(this)의 구독을 요청합니다.
      routeObserver.subscribe(this, route); 
  }
}

  // 3. [New] 다른 화면이 닫히고 이 화면이 다시 보일 때 호출됨
  @override
  void didPopNext() {
    // TimerDisplayScreen에서 back 버튼을 눌러 돌아왔을 때, 이 함수가 호출됩니다.
    print("ROUTE AWARE: Screen is coming back into view. Refreshing timers.");
    _loadTimers(); // 강제로 목록을 갱신합니다.
  }

  // 4. [New] Observer 구독 해제
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
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

  // [추가] 시간 포맷 헬퍼 함수 (HH:MM:SS)
  String _formatTime(int seconds) {
    if (seconds < 0) return '시간 초과';
    final int h = seconds ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;
    final int s = seconds % 60;
    if (h > 0) return '${h}시간 ${m}분';
    return '${m}분 ${s}초';
  }
  
  @override
  Widget build(BuildContext context) {
    bool hasData = personalTimers.isNotEmpty || groupTimers.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
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
            child: CustomBottomNavigationBar(currentIndex: 2),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🔥 이미지 오른쪽으로 살짝 이동 (left padding 추가)
        Padding(
          padding: const EdgeInsets.only(right: 80), // ← 여기 숫자 조절하면 됨
          child: SizedBox(
            height: 220,
            child: Image.asset(
              'assets/images/timer_success.png',
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          '우왕 할 일이 없어요!\n할 일을 추가해보세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Colors.black,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 80),
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

        // [New Logic] 남은 시간 계산
        int remainingSeconds = _timerService.calculateInitialDuration(item, isGroup);
        String timeDisplay = remainingSeconds <= 0 ? '시간 초과!' : _formatTime(remainingSeconds);

        if (isGroup) {
           // 그룹 타이머는 마감일을 바로 표시하는 것이 더 명확합니다.
           final deadline = DateTime.parse(item['group']['deadline']);
           timeDisplay = '마감: ${deadline.month}월 ${deadline.day}일';
        }

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 할 일 제목
                      Text(
                        title ?? '할 일 없음',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 남은 시간/마감 시간
                      Text(
                        timeDisplay,
                        style: TextStyle(
                          fontSize: 14, 
                          color: remainingSeconds <= 0 && !isGroup ? Colors.red : Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
              ],
            ),
          ),
        );
      },
    );
  }
}