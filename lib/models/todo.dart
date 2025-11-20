class Todo {
  final String title;
  final DateTime deadline;

  Todo({required this.title, required this.deadline});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'] as String,
      deadline: DateTime.parse(json['deadline'] as String).toLocal(), // UTC -> 로컬 시간으로 변환
    );
  }
}