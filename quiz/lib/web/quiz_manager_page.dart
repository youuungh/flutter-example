import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz/model/quiz.dart';
import 'package:quiz/web/w_quiz_bottom_sheet.dart';

import '../main.dart';

class QuizManagerPage extends StatefulWidget {
  const QuizManagerPage({super.key});

  @override
  State<QuizManagerPage> createState() => _QuizManagerPageState();
}

class _QuizManagerPageState extends State<QuizManagerPage> {
  static const int PIN_CODE_MAX = 999999;
  static const int PIN_CODE_LENGTH = 6;
  static const int QUIZ_START_DELAY = 5;
  static const int PROBLEM_SOLVE_TIME = 5;

  String? uid;
  List<QuizManager> quizItems = [];
  List<Quiz> quizList = [];
  bool isLoading = false;
  bool isGenerating = false;

  @override
  void initState() {
    super.initState();
    _signInAnonymously();
    _streamQuizzes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _signInAnonymously() async {
    try {
      setState(() => isLoading = true);

      final result = await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        uid = result.user?.uid ?? "";
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        _showErrorDialog("로그인 실패", "익명 로그인에 실패했습니다: $e");
      }
    }
  }

  Future<void> _generateQuiz() async {
    if (quizItems.isEmpty) {
      _showErrorDialog("오류", "문제를 먼저 추가해주세요.");
      return;
    }

    if (uid == null || uid!.isEmpty) {
      _showErrorDialog("오류", "로그인이 필요합니다.");
      return;
    }

    try {
      setState(() => isGenerating = true);

      final pinCode = Random()
          .nextInt(PIN_CODE_MAX)
          .toString()
          .padLeft(PIN_CODE_LENGTH, '0');

      final quizRef = database!.ref("quiz");
      final quizDetailRef = database!.ref("quiz_detail");
      final quizStateRef = database!.ref("quiz_state");

      final newQuizDetailRef = quizDetailRef.push();
      await newQuizDetailRef.set({
        "code": pinCode,
        "problems": quizItems
            .map((e) => {
          "title": e.title,
          "options": e.problems?.map((e2) => e2.text).toList(),
          "answerIndex": e.answer?.index,
          "answer": e.answer?.text,
        })
            .toList(),
      });

      await quizStateRef.child("${newQuizDetailRef.key}").set({
        "quizDetailRef": newQuizDetailRef.key,
        "user": [],
        "state": false,
        "score": [],
        "solve": [{}],
      });

      final newQuizRef = quizRef.push();
      await newQuizRef.set({
        "code": pinCode,
        "uid": uid,
        "generateTime": DateTime.now().toString(),
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "quizDetailRef": newQuizDetailRef.key,
      });

      setState(() {
        isGenerating = false;
        quizItems.clear();
      });

      if (mounted) {
        _showSuccessDialog("퀴즈 생성 완료", "핀코드: $pinCode\n퀴즈가 성공적으로 생성되었습니다!");
      }
    } catch (e) {
      setState(() => isGenerating = false);
      if (mounted) {
        _showErrorDialog("생성 실패", "퀴즈 생성에 실패했습니다: $e");
      }
    }
  }

  void _streamQuizzes() {
    try {
      database?.ref("quiz").onValue.listen(
            (event) {
          try {
            final data = event.snapshot.children;
            quizList.clear();

            for (var element in data) {
              final quizData = jsonDecode(jsonEncode(element.value));
              quizList.add(Quiz.fromJson(quizData));
            }

            if (mounted) {
              setState(() {});
            }
          } catch (e) {
            print("퀴즈 데이터 파싱 오류: $e");
          }
        },
        onError: (error) {
          print("퀴즈 스트림 오류: $error");
          if (mounted) {
            _showErrorDialog("데이터 로드 실패", "퀴즈 목록을 불러올 수 없습니다.");
          }
        },
      );
    } catch (e) {
      print("스트림 초기화 오류: $e");
    }
  }

  Future<void> _startQuiz(Quiz item) async {
    try {
      final ref = await database?.ref("quiz_state/${item.quizDetailRef}/state").get();
      final currentState = (ref?.value as bool?) ?? false;

      if (currentState) {
        _showErrorDialog("알림", "이미 시작된 퀴즈입니다.");
        return;
      }

      final quizDetailRef = await database?.ref("quiz_detail/${item.quizDetailRef}").get();
      final problemCount = quizDetailRef?.child("/problems").children.length ?? 0;

      if (problemCount == 0) {
        _showErrorDialog("오류", "문제가 없는 퀴즈입니다.");
        return;
      }

      DateTime currentTime = DateTime.now();
      List<Map<String, dynamic>> triggerTimes = [];

      for (var i = 0; i < problemCount; i++) {
        final startTime = currentTime.add(
          Duration(seconds: QUIZ_START_DELAY + (i * PROBLEM_SOLVE_TIME)),
        );
        final endTime = startTime.add(Duration(seconds: PROBLEM_SOLVE_TIME));

        triggerTimes.add({
          "startTime": startTime.millisecondsSinceEpoch,
          "endTime": endTime.millisecondsSinceEpoch,
        });

        currentTime = endTime;
      }

      if (mounted) {
        _showStartConfirmDialog(item, triggerTimes);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog("시작 실패", "퀴즈 시작에 실패했습니다: $e");
      }
    }
  }

  void _showStartConfirmDialog(Quiz item, List<Map<String, dynamic>> triggerTimes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.play_arrow, color: Colors.indigo.shade600),
            ),
            const SizedBox(width: 12),
            const Text("퀴즈 시작"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("퀴즈를 시작할까요?"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.pin, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text("코드: ${item.code}", style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("취소", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                await database?.ref("quiz_state/${item.quizDetailRef}").update({
                  "state": true,
                  "current": 0,
                  "triggers": triggerTimes,
                });

                if (mounted) {
                  _showSuccessDialog("시작 완료", "퀴즈가 시작되었습니다!");
                }
              } catch (e) {
                if (mounted) {
                  _showErrorDialog("시작 실패", "퀴즈 시작에 실패했습니다: $e");
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("시작"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.error_outline, color: Colors.red.shade600),
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.check_circle_outline, color: Colors.green.shade600),
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddQuizBottomSheet() async {
    try {
      final quiz = await showModalBottomSheet<QuizManager>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const QuizBottomSheet(),
      );

      if (quiz != null) {
        setState(() {
          quizItems.add(quiz);
        });
      }
    } catch (e) {
      _showErrorDialog("오류", "문제 추가에 실패했습니다: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("퀴즈 출제하기", style: TextStyle(fontWeight: FontWeight.w600)),
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
            Text("로그인 중...", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      )
          : DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.indigo.shade700,
                unselectedLabelColor: Colors.grey.shade500,
                indicatorColor: Colors.indigo.shade700,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: "출제하기", icon: Icon(Icons.edit, size: 20)),
                  Tab(text: "퀴즈목록", icon: Icon(Icons.list, size: 20)),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildQuizCreateTab(),
                  _buildQuizListTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddQuizBottomSheet,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
        label: const Text("문제 추가", style: TextStyle(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuizCreateTab() {
    return Column(
      children: [
        Expanded(
          child: quizItems.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.quiz,
                    size: 48,
                    color: Colors.indigo.shade300,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "아직 추가된 문제가 없습니다",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "하단의 '문제 추가' 버튼을 눌러\n새로운 문제를 만들어보세요!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizItems.length,
            itemBuilder: (context, index) {
              final quiz = quizItems[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(
                    quiz.title ?? "제목 없음",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "선택지 ${quiz.problems?.length ?? 0}개",
                            style: TextStyle(
                              color: Colors.indigo.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete_outline, color: Colors.red.shade600, size: 20),
                    ),
                    onPressed: () {
                      setState(() {
                        quizItems.removeAt(index);
                      });
                    },
                  ),
                  children: quiz.problems
                      ?.map((e) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Icon(
                            e == quiz.answer
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: e == quiz.answer
                                ? Colors.green.shade600
                                : Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.text,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
                      .toList() ??
                      [],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isGenerating ? null : _generateQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isGenerating
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text("생성 중...", style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                )
                    : const Text(
                  "퀴즈 생성 및 핀코드 발급",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizListTab() {
    return quizList.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.quiz_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "생성된 퀴즈가 없습니다",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "먼저 문제를 추가하고 퀴즈를 생성해보세요",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizList.length,
      itemBuilder: (context, index) {
        final item = quizList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.quiz, color: Colors.indigo.shade600),
            ),
            title: Text(
              "코드: ${item.code ?? '없음'}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Container(
              margin: const EdgeInsets.only(top: 4),
              child: Text(
                "참조: ${item.quizDetailRef ?? '없음'}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.play_arrow, color: Colors.green.shade600),
            ),
            onTap: () => _startQuiz(item),
          ),
        );
      },
    );
  }
}