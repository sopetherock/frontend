import 'package:flutter/material.dart';
import '../../services/social_service.dart';
import 'search_friend_screen.dart';
import 'create_group_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<dynamic> friends = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(title: const Text("친구")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SearchFriendScreen()),
          ).then((_) => loadFriends());
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/zeus_sad.png", width: 150),
                      const SizedBox(height: 15),
                      const Text("등록된 친구가 없습니다."),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, i) {
                    final f = friends[i];
                    final user = f["requester"];
                    final me = f["addressee"];

                    final friend = (user["id"] == f["myId"]) ? me : user;

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
                ),
    );
  }
}
