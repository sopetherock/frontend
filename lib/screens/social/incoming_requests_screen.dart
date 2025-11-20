import 'package:flutter/material.dart';
import '../../services/social_service.dart';

class IncomingRequestsScreen extends StatefulWidget {
  @override
  State<IncomingRequestsScreen> createState() => _IncomingRequestsScreenState();
}

class _IncomingRequestsScreenState extends State<IncomingRequestsScreen> {
  List<dynamic> requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await SocialService.getIncomingRequests();
    setState(() {
      requests = data;
      loading = false;
    });
  }

  Future<void> accept(int id) async {
    await SocialService.acceptRequest(id);
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("친구 요청함")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: requests.map((r) {
                final user = r["requester"];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(user["nickname"][0])),
                    title: Text(user["nickname"]),
                    subtitle: Text(user["username"]),
                    trailing: ElevatedButton(
                      onPressed: () => accept(r["id"]),
                      child: const Text("수락"),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
