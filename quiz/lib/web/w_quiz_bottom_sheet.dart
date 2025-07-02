import 'package:flutter/material.dart';
import 'package:quiz/model/problem.dart';
import 'package:quiz/model/quiz.dart';

class QuizBottomSheet extends StatefulWidget {
  const QuizBottomSheet({super.key});

  @override
  State<QuizBottomSheet> createState() => _QuizBottomSheetState();
}

class _QuizBottomSheetState extends State<QuizBottomSheet> {
  List<TextEditingController> optionControllers = [];
  List<ProblemOption> problemOptions = [];
  int? selectedAnswerIndex;
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addOption();
    _addOption();
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    final controller = TextEditingController();
    optionControllers.add(controller);
    problemOptions.add(
      ProblemOption(
        index: problemOptions.length,
        text: "",
      ),
    );
    setState(() {});
  }

  void _removeOption(int index) {
    if (optionControllers.length <= 2) {
      _showErrorSnackBar("최소 2개의 선택지가 필요합니다.");
      return;
    }

    optionControllers[index].dispose();
    optionControllers.removeAt(index);
    problemOptions.removeAt(index);

    for (int i = 0; i < problemOptions.length; i++) {
      problemOptions[i] = ProblemOption(
        index: i,
        text: problemOptions[i].text,
      );
    }

    if (selectedAnswerIndex != null) {
      if (selectedAnswerIndex! == index) {
        selectedAnswerIndex = null;
      } else if (selectedAnswerIndex! > index) {
        selectedAnswerIndex = selectedAnswerIndex! - 1;
      }
    }

    setState(() {});
  }

  void _updateProblemOption(int index, String text) {
    if (index < problemOptions.length) {
      problemOptions[index] = ProblemOption(
        index: index,
        text: text,
      );
    }
  }

  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      _showErrorSnackBar("문제 제목을 입력해주세요.");
      return false;
    }

    List<String> options = [];
    for (var controller in optionControllers) {
      final text = controller.text.trim();
      if (text.isEmpty) {
        _showErrorSnackBar("모든 선택지를 입력해주세요.");
        return false;
      }
      if (options.contains(text.toLowerCase())) {
        _showErrorSnackBar("중복된 선택지가 있습니다.");
        return false;
      }
      options.add(text.toLowerCase());
    }

    if (selectedAnswerIndex == null) {
      _showErrorSnackBar("정답을 선택해주세요.");
      return false;
    }

    return true;
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

  void _submitQuiz() {
    if (!_validateForm()) return;

    try {
      List<ProblemOption> finalOptions = [];
      for (int i = 0; i < optionControllers.length; i++) {
        finalOptions.add(
          ProblemOption(
            index: i,
            text: optionControllers[i].text.trim(),
          ),
        );
      }

      final quiz = QuizManager(
        problems: finalOptions,
        title: titleController.text.trim(),
        answer: finalOptions[selectedAnswerIndex!],
      );

      Navigator.of(context).pop<QuizManager>(quiz);
    } catch (e) {
      _showErrorSnackBar("퀴즈 생성에 실패했습니다: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.quiz,
                        color: Colors.indigo.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "퀴즈 문제 만들기",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.help_outline, color: Colors.indigo.shade600, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            "문제",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: "문제를 입력해주세요",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        maxLines: 3,
                        minLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Icon(Icons.list, color: Colors.indigo.shade600, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "선택지",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _addOption,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("추가"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.indigo.shade600,
                        backgroundColor: Colors.indigo.shade50,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: optionControllers.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedAnswerIndex == index;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.green.shade300 : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: index,
                              groupValue: selectedAnswerIndex,
                              onChanged: (value) {
                                setState(() {
                                  selectedAnswerIndex = value;
                                });
                              },
                              activeColor: Colors.green.shade600,
                            ),
                            Expanded(
                              child: TextField(
                                controller: optionControllers[index],
                                decoration: InputDecoration(
                                  hintText: "선택지 ${index + 1}",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                onChanged: (text) {
                                  _updateProblemOption(index, text);
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _removeOption(index),
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade600,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                if (selectedAnswerIndex != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "선택된 정답",
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                optionControllers.length > selectedAnswerIndex!
                                    ? (optionControllers[selectedAnswerIndex!].text.isEmpty
                                    ? '선택지 ${selectedAnswerIndex! + 1}'
                                    : optionControllers[selectedAnswerIndex!].text)
                                    : '',
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          "취소",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _submitQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "문제 추가",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}