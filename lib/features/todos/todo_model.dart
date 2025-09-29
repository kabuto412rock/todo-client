class Todo {
  final String id;
  final String title;
  final bool done;
  final DateTime? dueDate;

  Todo({
    required this.id,
    required this.title,
    required this.done,
    this.dueDate,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['id'];
    final String id = rawId is String ? rawId : rawId?.toString() ?? '';
    final dynamic rawDone = json['done'];
    final bool done = rawDone is bool
        ? rawDone
        : (rawDone is num ? rawDone != 0 : (rawDone?.toString() == 'true'));

    DateTime? dueDate;
    final dynamic rawDue = json['dueDate'];
    if (rawDue is String && rawDue.isNotEmpty) {
      try {
        dueDate = DateTime.parse(rawDue);
      } catch (_) {
        dueDate = null;
      }
    }

    return Todo(
      id: id,
      title: json['title'] as String? ?? '',
      done: done,
      dueDate: dueDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'done': done,
    if (dueDate != null) 'dueDate': dueDate!.toUtc().toIso8601String(),
  };
}
