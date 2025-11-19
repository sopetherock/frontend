import 'package:flutter/material.dart';
import '../../services/social_service.dart';

class SearchFriendScreen extends StatefulWidget {
  @override
  State<SearchFriendScreen> createState() => _SearchFriendScreenState();
}

class _SearchFriendScreenState extends State<SearchFriendScreen> {
  final ctrl = TextEditingController();
  Map<String, dynamic>? user;
  bool loading = false;

  Future<void> search() async {
    setState(() => loading = true);
    final result = await SocialService.searchUser(ctrl.text.trim());
    setState(() {
      user = result;
      loading = false;
    });
  }

  Future<void> sendRequest() async {
    if (user == null) return;

    final ok = await SocialService.sendRequest(user!["id"]);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? "친구 요청 보냈습니다!" : "요청 실패")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("친구 검색")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                hintText: "아이디 검색",
                filled: true,
                fillColor: Color(0xfff0f0f0),
              ),
              onSubmitted: (_) => search(),
            ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            if (user != null && !loading)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user!["nickname"]),
                  subtitle: Text(user!["username"]),
                  trailing: ElevatedButton(
                    onPressed: sendRequest,
                    child: const Text("친구 요청"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
