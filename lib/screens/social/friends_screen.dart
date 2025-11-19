// lib/screens/social/friends_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/social_service.dart';
import 'package:frontend/services/user_service.dart';

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

      final token = await user.getIdToken(true);
      await ApiService.setToken(token!);

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

      setState(() {
        friends = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ======================
      //        상단 AppBar
      // ======================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                color: Colors.black,
                onPressed: () => Navigator.pop(context),
              )
            : null,
        centerTitle: true,
        title: const Text(
          "친구 목록",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),

      // ======================
      //        본문
      // ======================
      body: Column(
        children: [
          // 🔍 검색창 (돋보기 아이콘 적용됨)
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

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : friends.isEmpty
                    ? _buildEmptyState()
                    : _buildFriendsList(),
          ),
        ],
      ),

      // ======================
      //      요청함 버튼 (노란색 고정)
      // ======================
      floatingActionButton: FloatingActionButton(
        backgroundColor: _yellow,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.mail, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FriendRequestScreen()),
          );
        },
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
        // 이미지 오른쪽으로 padding 조정
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: SizedBox(
            height: 220,
            child: Image.asset(
              'assets/images/zeus_sad.png',
              fit: BoxFit.contain,
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
      ],
    );
  }

  /// ==============================
  ///        친구 목록 표시
  /// ==============================
  Widget _buildFriendsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                child: const Icon(Icons.person, size: 20),
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
              const Icon(Icons.add, size: 22, color: Colors.black),
            ],
          ),
        );
      },
    );
  }
}
