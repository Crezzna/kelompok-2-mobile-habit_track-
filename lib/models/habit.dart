class Habit {
  String id;
  String name;
  String time;
  bool isCompleted;

  Habit({
    required this.id,
    required this.name,
    required this.time,
    this.isCompleted = false,
  });
}