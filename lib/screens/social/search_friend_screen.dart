// lib/screens/social/search_friend_screen.dart
import 'package:flutter/material.dart';
import '../../services/social_service.dart';

class SearchFriendScreen extends StatefulWidget {
  const SearchFriendScreen({super.key});

  @override
  State<SearchFriendScreen> createState() => _SearchFriendScreenState();
}

class _SearchFriendScreenState extends State<SearchFriendScreen> {
  final ctrl = TextEditingController();
  Map<String, dynamic>? user;
  bool loading = false;
  bool searched = false;

  Future<void> search() async {
    final keyword = ctrl.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      loading = true;
      searched = true;
      user = null;
    });

    final result = await SocialService.searchUser(keyword);

    setState(() {
      loading = false;
      user = result;
    });
  }

  Future<void> sendRequest() async {
    if (user == null) return;
    final ok = await SocialService.sendRequest(user!["id"]);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? "친구 요청을 보냈어요!" : "요청 실패")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "친구 검색",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // 검색창
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      decoration: const InputDecoration(
                        hintText: "아이디로 친구 검색",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Color(0xFF666666),
                          fontFamily: 'Inter',
                          fontSize: 15,
                        ),
                      ),
                      onSubmitted: (_) => search(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.black),
                    onPressed: search,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (searched && user == null)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                "존재하지 않는 아이디입니다.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          else if (user != null)
            _buildUserCard()
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 65,
        margin: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            // 프로필 원형 (연분홍)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFCCCC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 20, color: Colors.black),
            ),
            const SizedBox(width: 16),
            // 닉네임
            Text(
              user!["nickname"],
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            // +
            IconButton(
              icon: const Icon(Icons.add, size: 26, color: Colors.black),
              onPressed: sendRequest,
            )
          ],
        ),
      ),
    );
  }
}
