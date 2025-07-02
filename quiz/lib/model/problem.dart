class ProblemOption {
  int? index;
  String text;

  ProblemOption({required this.index, required this.text});
}

class Problems {
  int? answerIndex;
  String? answer;
  List<String>? options;
  String? title;

  Problems({this.answerIndex, this.answer, this.options, this.title});

  Problems.fromJson(Map<String, dynamic> json) {
    answerIndex = json['answerIndex'] as int?;
    answer = json['answer'] as String?;
    options = (json['options'] as List?)?.cast<String>();
    title = json['title'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['answerIndex'] = answerIndex;
    data['answer'] = answer;
    data['options'] = options;
    data['title'] = title;
    return data;
  }
}