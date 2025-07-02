import 'package:quiz/model/problem.dart';

class QuizManager {
  List<ProblemOption>? problems;
  String? title;
  ProblemOption? answer;

  QuizManager({this.problems, this.title, this.answer});
}

class QuizDetail {
  String? code;
  List<Problems>? problems;

  QuizDetail({this.code, this.problems});

  QuizDetail.fromJson(Map<String, dynamic> json) {
    code = json['code'] as String?;
    if (json['problems'] != null) {
      problems = [];
      json['problems'].forEach((v) {
        problems!.add(Problems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['code'] = code;
    if (problems != null) {
      data["problems"] = problems!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class Quiz {
  String? code;
  String? generateTime;
  String? quizDetailRef;
  int? timestamp;
  String? uid;

  Quiz({
    this.code,
    this.generateTime,
    this.quizDetailRef,
    this.timestamp,
    this.uid,
  });

  Quiz.fromJson(Map<String, dynamic> json) {
    code = json['code'] as String?;
    generateTime = json['generateTime'] as String?;
    quizDetailRef = json['quizDetailRef'] as String?;
    timestamp = json['timestamp'] as int?;
    uid = json['uid'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['code'] = code;
    data['generateTime'] = generateTime;
    data['quizDetailRef'] = quizDetailRef;
    data['timestamp'] = timestamp;
    data['uid'] = uid;
    return data;
  }
}
