// lib/screens/social/friend_request_screen.dart
import 'package:flutter/material.dart';
import '../../services/social_service.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  List<dynamic> requests = [];
  bool loading = true;
  final Set<int> selected = {};

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    final data = await SocialService.getIncomingRequests();
    setState(() {
      requests = data;
      loading = false;
    });
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
          "친구 요청",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? _buildEmpty()
              : _buildRequestList(),
    );
  }

  Widget _buildEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SizedBox(
          height: 220,
          child: Image(
            image: AssetImage('assets/images/zeus_sad.png'),
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 24),
        Text(
          "친구 요청이 없어요!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestList() {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final r = requests[index];
              final user = r["requester"];

              final selectedThis = selected.contains(r["id"]);

              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFCCCC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    user["nickname"],
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedThis) {
                          selected.remove(r["id"]);
                        } else {
                          selected.add(r["id"]);
                        }
                      });
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                        color: selectedThis
                            ? const Color(0xFFB8B8B8)
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // 하단 버튼
        Container(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 삭제 기능 미구현
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9D9D9),
                  ),
                  child: const Text("요청 삭제하기"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () async {
                          for (final id in selected) {
                            await SocialService.acceptRequest(id);
                          }
                          loadRequests();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE4B80),
                  ),
                  child: const Text("요청 수락하기"),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
