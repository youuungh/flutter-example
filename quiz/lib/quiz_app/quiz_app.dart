import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:quiz/model/problem.dart';
import 'package:quiz/model/quiz.dart';

import '../main.dart';

class QuizPage extends StatefulWidget {
  final String quizRef;
  final String name;
  final String uid;
  final String code;

  const QuizPage({
    super.key,
    required this.quizRef,
    required this.code,
    required this.name,
    required this.uid,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  DatabaseReference? quizStateRef;
  List<Problems> problemList = [];
  List<Map<String, int>> problemTriggers = [];

  String quizStatePath = "quiz_state";
  String quizDetailPath = "quiz_detail";

  bool isDone = false;
  List<String> quizResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuizInfo();
  }

  Future<void> _fetchQuizInfo() async {
    try {
      quizStateRef = database?.ref("$quizStatePath/${widget.quizRef}");
      final quizDetailRef = database?.ref("$quizDetailPath/${widget.quizRef}");

      final value = await quizDetailRef?.get();
      if (value != null) {
        final obj = jsonDecode(jsonEncode(value.value));
        final quizDetail = QuizDetail.fromJson(obj);

        quizDetail.problems?.forEach((element) {
          problemList.add(element);
        });

        final triggersValue = await quizStateRef?.child("triggers").get();
        if (triggersValue != null) {
          for (var element in triggersValue.children) {
            final trigger = element.value as Map;
            problemTriggers.add({
              "startTime": trigger["startTime"],
              "endTime": trigger["endTime"],
            });
          }
        }

        await quizStateRef?.child("user").push().set({
          "uid": widget.uid,
          "name": widget.name,
        });

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("퀴즈 정보 로딩 오류: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _calculateResult() async {
    if (isDone) return;

    isDone = true;

    try {
      print("결과 계산 시작...");

      final result = await quizStateRef?.child("solve").once();
      Map<String, double> countMap = {};

      if (result?.snapshot.exists == false || result?.snapshot.children.isEmpty == true) {
        print("답안 데이터를 찾을 수 없음");

        final userResult = await quizStateRef?.child("user").once();
        if (userResult?.snapshot.exists == true) {
          for (var userElement in userResult!.snapshot.children) {
            final userData = userElement.value as Map;
            countMap["${userData["name"]}"] = 0.0;
          }
        }
      } else {
        for (var element in result!.snapshot.children) {
          final elements = element.children.toList();

          if (elements.isEmpty) {
            print("문제 ${element.key}에 대한 답안 없음");
            continue;
          }

          elements.sort((a, b) {
            final aa = a.value as Map;
            final bb = b.value as Map;
            final aTime = aa["timestamp"] as int? ?? 0;
            final bTime = bb["timestamp"] as int? ?? 0;
            return aTime.compareTo(bTime);
          });

          for (var i = (elements.length - 1); i >= 0; i--) {
            final element2 = elements[i];
            final elementMap = element2.value as Map;

            final name = "${elementMap["name"] ?? "Unknown"}";
            final isCorrect = elementMap["correct"] as bool? ?? false;

            double score = isCorrect ? (20 + i) / 1000 : 0;

            if (countMap.containsKey(name)) {
              countMap[name] = (countMap[name] ?? 0) + 1.00 + score;
            } else {
              countMap[name] = 1.00 + score;
            }
          }
        }
      }

      var sortedKeys = countMap.keys.toList(growable: false);
      if (sortedKeys.isNotEmpty) {
        sortedKeys.sort((k1, k2) => countMap[k2]!.compareTo(countMap[k1]!));
      }

      print("최종 결과: $countMap");
      print("정렬된 결과: $sortedKeys");

      if (mounted) {
        setState(() {
          quizResults = sortedKeys;
        });
      }

    } catch (e) {
      print("결과 계산 오류: $e");

      if (mounted) {
        setState(() {
          quizResults = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              "코드: ${widget.code}",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade700,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.indigo),
            const SizedBox(height: 16),
            Text("퀴즈 정보를 불러오는 중...", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      )
          : Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.people, color: Colors.indigo.shade600),
                                const SizedBox(width: 8),
                                const Text(
                                  "참가자 목록",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: StreamBuilder(
                              stream: quizStateRef?.child("/user").onValue,
                              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                                if (snapshot.hasData) {
                                  final items = snapshot.data?.snapshot.children.toList() ?? [];

                                  if (items.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person_outline, size: 48, color: Colors.grey.shade400),
                                          const SizedBox(height: 16),
                                          Text("아직 참가자가 없습니다", style: TextStyle(color: Colors.grey.shade600)),
                                        ],
                                      ),
                                    );
                                  }

                                  return ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: items.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final item = items[index].value as Map;
                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.indigo.shade100,
                                              child: Text(
                                                "${item["name"]}".substring(0, 1).toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.indigo.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${item["name"]}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  "${item["uid"]}".length > 20
                                                      ? "${"${item["uid"]}".substring(0, 20)}..."
                                                      : "${item["uid"]}",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text("참가자 확인 중..."),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: StreamBuilder(
                      stream: quizStateRef?.child("state").onValue,
                      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                        if (snapshot.hasData) {
                          final state = snapshot.data?.snapshot.value as bool;
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: state ? Colors.green.shade50 : Colors.orange.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    state ? Icons.play_arrow : Icons.hourglass_empty,
                                    color: state ? Colors.green.shade600 : Colors.orange.shade600,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state ? "퀴즈 진행 중" : "시작 대기 중",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: state ? Colors.green.shade700 : Colors.orange.shade700,
                                  ),
                                ),
                                Text(
                                  state ? "문제를 풀어보세요!" : "출제자가 시작할 때까지 기다려주세요",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned.fill(
            child: StreamBuilder(
              stream: quizStateRef?.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.hasData) {
                  int currentIndex = 0;
                  Map snapshotData = snapshot.data?.snapshot.value as Map;
                  final state = snapshotData["state"] as bool;

                  if (snapshotData.containsKey("current")) {
                    currentIndex = snapshotData["current"] as int;
                  }

                  problemTriggers.clear();
                  if (snapshotData.containsKey("triggers")) {
                    for (var element in snapshotData["triggers"]) {
                      final trigger = element as Map;
                      problemTriggers.add({
                        "startTime": trigger["startTime"],
                        "endTime": trigger["endTime"],
                      });
                    }
                  }

                  if (state) {
                    if (currentIndex < problemList.length) {
                      return Container(
                        color: Colors.grey.shade50,
                        child: _ProblemSolver(
                          index: currentIndex,
                          ref: quizStateRef!,
                          problems: problemList[currentIndex],
                          startTime: problemTriggers[currentIndex]["startTime"] ?? 0,
                          endTime: problemTriggers[currentIndex]["endTime"] ?? 0,
                          uid: widget.uid,
                          name: widget.name,
                        ),
                      );
                    } else {
                      _calculateResult();
                      return Container(
                        color: Colors.grey.shade50,
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.emoji_events, color: Colors.amber.shade600, size: 28),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "퀴즈 완료! 🎉",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: quizResults.isEmpty
                                    ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "아직 제출된 답안이 없습니다",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "모든 참가자가 답안을 제출하지 않았습니다",
                                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                )
                                    : ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: quizResults.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final isTopThree = index < 3;
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isTopThree
                                            ? [Colors.amber.shade50, Colors.grey.shade100, Colors.orange.shade50][index]
                                            : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: isTopThree
                                            ? Border.all(
                                          color: [Colors.amber.shade300, Colors.grey.shade400, Colors.orange.shade300][index],
                                          width: 2,
                                        )
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: isTopThree
                                                  ? [Colors.amber.shade600, Colors.grey.shade600, Colors.orange.shade600][index]
                                                  : Colors.indigo.shade100,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                "${index + 1}",
                                                style: TextStyle(
                                                  color: isTopThree ? Colors.white : Colors.indigo.shade700,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              quizResults[index],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isTopThree ? FontWeight.w700 : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          if (isTopThree)
                                            Icon(
                                              [Icons.emoji_events, Icons.emoji_events, Icons.emoji_events][index],
                                              color: [Colors.amber.shade600, Colors.grey.shade600, Colors.orange.shade600][index],
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProblemSolver extends StatefulWidget {
  final DatabaseReference ref;
  final Problems problems;
  final String uid;
  final String name;
  final int startTime;
  final int endTime;
  final int index;

  const _ProblemSolver({
    required this.ref,
    required this.problems,
    required this.uid,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.index,
  });

  @override
  State<_ProblemSolver> createState() => _ProblemSolverState();
}

class _ProblemSolverState extends State<_ProblemSolver> {
  Timer? timer;
  int remainingTime = 0;
  int countdownTime = 0;
  bool hasStarted = false;
  bool hasSubmitted = false;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _periodicTask() async {
    final startTime = DateTime.fromMillisecondsSinceEpoch(widget.startTime);
    final endTime = DateTime.fromMillisecondsSinceEpoch(widget.endTime);

    timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
      DateTime currentTime = DateTime.now();
      final sDiff = currentTime.difference(startTime);
      final eDiff = endTime.difference(currentTime);

      countdownTime = sDiff.inSeconds;
      remainingTime = eDiff.inSeconds;

      if (sDiff.inSeconds >= 0) {
        hasStarted = true;
      }

      if (eDiff.inSeconds <= 0) {
        int nextIndex = widget.index + 1;
        widget.ref.child("current").set(nextIndex);
        timer?.cancel();
        timer = null;
        hasStarted = false;
        hasSubmitted = false;
      }
      _refresh();
    });
  }

  Future<void> _submitAnswer(String answer, int index) async {
    try {
      await widget.ref.child("solve/${widget.index}").push().set({
        "name": widget.name,
        "uid": widget.uid,
        "answer": answer,
        "correct": widget.problems.answerIndex == index,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });
      setState(() {
        hasSubmitted = true;
      });
    } catch (e) {
      print("답안 제출 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    _periodicTask();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: hasStarted
          ? Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: remainingTime <= 3 ? Colors.red.shade50 : Colors.indigo.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    color: remainingTime <= 3 ? Colors.red.shade600 : Colors.indigo.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$remainingTime초",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: remainingTime <= 3 ? Colors.red.shade700 : Colors.indigo.shade700,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: hasSubmitted
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "답안 제출 완료!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "다음 문제를 기다려주세요",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
                    : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.problems.title ?? "문제",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: widget.problems.options?.length ?? 0,
                        itemBuilder: (context, index) {
                          final option = widget.problems.options?[index] ?? "";
                          return GestureDetector(
                            onTap: () => _submitAnswer(option, index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.indigo.shade200,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade600,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${index + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          : Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: widget.index > 0
            ? Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    "다음 문제 준비 중",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: widget.ref
                    .child("solve/${widget.index - 1}")
                    .orderByChild("timestamp")
                    .onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.hasData) {
                    final items = snapshot.data?.snapshot.children.toList() ?? [];
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index].value as Map;
                        final isCorrect = item["correct"] as bool;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isCorrect ? Colors.green.shade600 : Colors.red.shade600,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "${item["name"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? Colors.green.shade600 : Colors.red.shade600,
                                size: 20,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                "${countdownTime * -1}초 후 시작",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.quiz,
                color: Colors.blue.shade600,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "퀴즈 시작 대기 중",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "곧 첫 번째 문제가 시작됩니다",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 40),
            Text(
              "${countdownTime * -1}초 후 시작",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}