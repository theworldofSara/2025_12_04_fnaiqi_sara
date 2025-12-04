class Exercise {
  Exercise({
    required this.name,
    required this.score,
    required this.submittedAt,
  }) : assert(score >= 0 && score <= 100);

  final String name;
  final int score;
  final DateTime submittedAt;

  bool get passed => score >= 60;

  @override
  String toString() {
    return "Exercise($name, $score, $submittedAt)";
  }
}

List<Exercise> getPassed(List<Exercise> items) {
  final result = <Exercise>[];
  for (final ex in items) {
    if (ex.passed) {
      result.add(ex);
    }
  }
  return result;
}

double averageScore(List<Exercise> list) {
  if (list.isEmpty) return 0;

  var total = 0;
  for (final x in list) {
    total = total + x.score;
  }

  final avg = total / list.length;
  return avg;
}

String bestStudent(List<Exercise> arr) {
  if (arr.isEmpty) throw StateError("Empty");

  var top = arr[0];
  var i = 1;
  while (i < arr.length) {
    final now = arr[i];
    if (now.score > top.score) {
      top = now;
    }
    i++;
  }

  return top.name;
}
