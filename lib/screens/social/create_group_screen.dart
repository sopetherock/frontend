import 'package:flutter/material.dart';
import '../../services/social_service.dart';

class CreateGroupScreen extends StatefulWidget {
  final List<dynamic> friends;

  const CreateGroupScreen(this.friends, {super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final Set<int> selected = {};

  DateTime? deadline;

  Future<void> create() async {
    if (deadline == null) return;

    final ids = selected.toList();
    final result = await SocialService.createGroup(deadline!, ids);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            result == null ? "그룹 생성 실패" : "그룹 생성 완료! id = ${result["id"]}"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final friends = widget.friends;

    return Scaffold(
      appBar: AppBar(title: const Text("그룹 만들기")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
                initialDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  deadline = picked;
                });
              }
            },
            child: Text(
              deadline == null
                  ? "마감 날짜 선택"
                  : "마감: ${deadline!.toIso8601String()}",
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ...friends.map((f) {
                  final user = f["requester"];
                  final addressee = f["addressee"];

                  final friend = user ?? addressee;
                  final id = friend["id"];

                  return CheckboxListTile(
                    value: selected.contains(id),
                    onChanged: (_) {
                      setState(() {
                        if (selected.contains(id)) {
                          selected.remove(id);
                        } else {
                          selected.add(id);
                        }
                      });
                    },
                    title: Text(friend["nickname"]),
                    subtitle: Text(friend["username"]),
                  );
                })
              ],
            ),
          ),
          ElevatedButton(onPressed: create, child: const Text("그룹 생성")),
        ],
      ),
    );
  }
}
