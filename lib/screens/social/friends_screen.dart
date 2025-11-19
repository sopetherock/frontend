import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/services/api_service.dart';
import '../../services/social_service.dart';
import '../../services/user_service.dart';
import 'search_friend_screen.dart';
import 'create_group_screen.dart';
import 'incoming_requests_screen.dart';

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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("❌ 로그인 필요");
      return;
    }

    // 토큰 붙이기
    final token = await user.getIdToken(true);
    await ApiService.setToken(token!);

    // 내 정보 가져오기
    final me = await UserService.getMe();
    myId = me["id"];

    loadFriends();
  }

  Future<void> loadFriends() async {
    final data = await SocialService.getFriends();
    setState(() {
      friends = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("친구"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchFriendScreen()),
              ).then((_) => loadFriends());
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.mail),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => IncomingRequestsScreen()),
          ).then((_) => loadFriends());
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : friends.isEmpty
              ? _emptyUI()
              : _friendList(),
    );
  }

  Widget _emptyUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/zeus_sad.png", width: 150),
          const SizedBox(height: 15),
          const Text("등록된 친구가 없습니다."),
        ],
      ),
    );
  }

  Widget _friendList() {
    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, i) {
        final f = friends[i];
        final requester = f["requester"];
        final addressee = f["addressee"];

        final friend = (requester["id"] == myId) ? addressee : requester;

        return ListTile(
          leading: CircleAvatar(child: Text(friend["nickname"][0])),
          title: Text(friend["nickname"]),
          subtitle: Text(friend["username"]),
          trailing: IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateGroupScreen(friends),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
