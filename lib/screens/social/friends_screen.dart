import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:frontend/services/social_service.dart';
import 'package:frontend/services/user_service.dart';

// 커스텀 네비게이션 바
import '../../widgets/CustomBottomNavigationBar.dart';
import 'search_friend_screen.dart';
import 'friend_request_screen.dart';

const _pink = Color(0xFFFE4B80);
const _lightPink = Color(0xFFFFCCCC);
const _yellow = Color(0xFFFFEB59);

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<dynamic> friends = [];
  bool loading = true;
  int? myId;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => loading = false);
        return;
      }

      // ApiService.setToken 제거됨 (자동 관리)
      await loadFriends();
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> loadFriends() async {
    try {
      final me = await UserService.getMe();
      myId = me["id"];

      final data = await SocialService.getFriends();

      if (mounted) {
        setState(() {
          friends = data;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // [변경] Stack 구조로 변경하여 네비게이션 바 고정
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 메인 콘텐츠 영역
          Column(
            children: [
              // --- AppBar ---
              Container(
                height: 100,
                color: Colors.white,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 뒤로가기 (네비게이터 스택이 있을 때만)
                    Navigator.canPop(context)
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          )
                        : const SizedBox(width: 48),
                    
                    const Text(
                      "친구 목록",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(width: 48), // 타이틀 중앙 정렬용 더미
                  ],
                ),
              ),

              // --- 검색창 ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SearchFriendScreen()),
                    );
                    await loadFriends();
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Color(0xFF666666), size: 20),
                        SizedBox(width: 12),
                        Text(
                          "아이디로 친구 검색",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- 리스트 ---
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : friends.isEmpty
                        ? _buildEmptyState()
                        : _buildFriendsList(),
              ),
            ],
          ),

          // 2. 하단 네비게이션 바 (1번 탭 활성화)
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavigationBar(currentIndex: 1),
          ),

          // 3. 요청함 버튼 (Floating Action Button 대체)
          Positioned(
            right: 20,
            bottom: 100, // 네비게이션 바 위로 띄움
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FriendRequestScreen()),
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _yellow,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: const Icon(Icons.mail, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ==============================
  ///   친구 없음 화면 (이미지 오른쪽 이동)
  /// ==============================
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: SizedBox(
            height: 220,
            child: Image.asset(
              'assets/images/zeus_sad.png',
              fit: BoxFit.contain,
              errorBuilder: (c, o, s) => Container(
                width: 100, height: 100, color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "저런~ 친구가 없어요!\nID로 친구를 추가해보세요",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 80), // 하단바 가려짐 방지
      ],
    );
  }

  /// ==============================
  ///        친구 목록 표시
  /// ==============================
  Widget _buildFriendsList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100), // 하단 여백 추가
      itemCount: friends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final f = friends[index];
        final requester = f["requester"];
        final addressee = f["addressee"];

        final friend = requester["id"] == myId ? addressee : requester;

        return SizedBox(
          height: 56,
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: index == 0 ? _pink : _lightPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 16),

              Text(
                friend["nickname"],
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Inter',
                  color: Colors.black,
                ),
              ),

              const Spacer(),
              // 친구 추가 아이콘은 의미가 모호할 수 있어 일단 유지하되,
              // 이미 친구인 상태라면 채팅이나 프로필 보기 아이콘으로 바꾸는 게 좋습니다.
              const Icon(Icons.navigate_next, size: 22, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }
}
