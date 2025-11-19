import 'package:flutter/material.dart';
import '../../services/social_service.dart';

class SearchFriendScreen extends StatefulWidget {
  @override
  State<SearchFriendScreen> createState() => _SearchFriendScreenState();
}

class _SearchFriendScreenState extends State<SearchFriendScreen> {
  final ctrl = TextEditingController();
  Map<String, dynamic>? result;
  bool loading = false;

  Future<void> search() async {
    setState(() => loading = true);
    final data = await SocialService.searchUser(ctrl.text.trim());
    setState(() {
      result = data;
      loading = false;
    });
  }

  Future<void> sendRequest() async {
    if (result == null) return;

    final ok = await SocialService.sendRequest(result!["id"]);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "친구 요청을 보냈습니다!" : "요청 실패"),
      ),
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
              decoration: InputDecoration(
                hintText: "아이디 검색",
                filled: true,
                fillColor: const Color(0xfff0f0f0),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: search,
                ),
              ),
              onSubmitted: (_) => search(),
            ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            if (!loading && result != null)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(result!["nickname"]),
                  subtitle: Text(result!["username"]),
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
