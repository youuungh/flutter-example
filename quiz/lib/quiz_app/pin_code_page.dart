import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz/quiz_app/quiz_app.dart';

import '../main.dart';

class PinCodePage extends StatefulWidget {
  const PinCodePage({super.key});

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController pinController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();
  String? uid;
  final List<String> codeItems = [];
  bool isLoading = false;
  bool isSigningIn = true;

  @override
  void initState() {
    super.initState();
    _signInAnonymously();
  }

  @override
  void dispose() {
    pinController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  Future<void> _signInAnonymously() async {
    try {
      setState(() => isSigningIn = true);
      final result = await auth.signInAnonymously();
      setState(() {
        uid = result.user?.uid;
        isSigningIn = false;
      });
    } catch (e) {
      setState(() => isSigningIn = false);
      if (mounted) {
        _showErrorSnackBar("로그인에 실패했습니다: $e");
      }
    }
  }

  Future<bool> _findPinCode(String code) async {
    try {
      final quizRef = database?.ref("quiz");
      final result = await quizRef?.get().timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw TimeoutException('퀴즈 검색 시간 초과'),
      );

      codeItems.clear();

      if (result?.children != null) {
        for (var element in result!.children) {
          final data = jsonDecode(jsonEncode(element.value)) as Map<String, dynamic>;

          DateTime currentTime = DateTime.now();
          DateTime generatedTime = DateTime.parse(data['generateTime']);

          if (currentTime.difference(generatedTime).inDays < 1) {
            if (data.containsValue(code)) {
              codeItems.add(data["quizDetailRef"]);
            }
          }
        }
      }

      return codeItems.isNotEmpty;
    } on TimeoutException {
      print("핀코드 검색 타임아웃");
      return false;
    } catch (e) {
      print("핀코드 검색 오류: $e");
      return false;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _joinQuiz() async {
    if (pinController.text.trim().isEmpty) {
      _showErrorSnackBar("핀코드를 입력해주세요.");
      return;
    }

    if (nicknameController.text.trim().isEmpty) {
      _showErrorSnackBar("닉네임을 입력해주세요.");
      return;
    }

    if (uid == null) {
      _showErrorSnackBar("로그인이 필요합니다.");
      return;
    }

    setState(() => isLoading = true);

    try {
      String pinCode = pinController.text.trim();
      final result = await _findPinCode(pinCode);

      setState(() => isLoading = false);

      if (result) {
        _showSuccessSnackBar("퀴즈방에 입장합니다!");

        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => QuizPage(
                quizRef: codeItems.first,
                code: pinCode,
                name: nicknameController.text.trim(),
                uid: uid!,
              ),
            ),
          );
        }
      } else {
        _showErrorSnackBar("유효하지 않거나 만료된 핀코드입니다.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (e is TimeoutException) {
        _showErrorSnackBar("서버 응답 시간이 초과되었습니다. 다시 시도해주세요.");
      } else {
        _showErrorSnackBar("퀴즈 검색 중 오류가 발생했습니다: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // 키보드가 올라올 때 화면 크기 조정
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("퀴즈 입장", style: TextStyle(fontWeight: FontWeight.w600)),
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
      body: isSigningIn
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
          : SafeArea(
        child: SingleChildScrollView(  // 스크롤 가능하게 만들기
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight - 40, // AppBar와 패딩 제외한 최소 높이
            ),
            child: IntrinsicHeight(  // 자식들의 실제 높이만큼만 차지
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 상단 정보 컨테이너
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.quiz,
                            size: 32,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "퀴즈에 참여하세요!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "출제자가 제공한 핀코드와\n닉네임을 입력해주세요",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.indigo.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 입력 필드들
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 핀코드 입력
                      Row(
                        children: [
                          Icon(Icons.pin, color: Colors.indigo.shade600, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            "핀코드",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
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
                        child: TextField(
                          controller: pinController,
                          decoration: InputDecoration(
                            hintText: "6자리 핀코드를 입력하세요",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.indigo.shade400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 닉네임 입력
                      Row(
                        children: [
                          Icon(Icons.person_outline, color: Colors.indigo.shade600, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            "닉네임",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
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
                        child: TextField(
                          controller: nicknameController,
                          decoration: InputDecoration(
                            hintText: "다른 사람들에게 보여질 이름",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(Icons.face, color: Colors.indigo.shade400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          maxLength: 10,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 유연한 공간 (Spacer 대신)
                  const SizedBox(height: 32),

                  // 하단 버튼과 정보
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 56,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _joinQuiz,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade600,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
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
                              const Text(
                                "확인 중...",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                "퀴즈 입장하기",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "출제자에게 6자리 핀코드를 받아 입력하세요.\n퀴즈는 24시간 후 자동으로 만료됩니다.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}