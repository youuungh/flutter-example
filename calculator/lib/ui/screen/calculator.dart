import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:calculator/ui/widget/widget.dart';
import 'package:provider/provider.dart';

import '../../domain/domain.dart';
import '../../presentation/presentation.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CalculatorViewModel>().load();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: ValueListenableBuilder<CalculatorEntity>(
          valueListenable: context.read<CalculatorViewModel>(),
          builder: (context, calculator, child) => Column(
            children: [
              // 디스플레이 영역
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: CalculatorBoard(
                          number: calculator.result,
                          expression: calculator.expression,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 버튼 영역
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: CalculatorButton.complex(
                                text: 'C',
                                onTap: (buttonText) => _perform(buttonText, save: true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.complex(
                                text: '+/-',
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.complex(
                                text: '<',
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.operator(
                                text: '/',
                                operator: calculator.operator,
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: CalculatorButton.simple(
                                text: '7',
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.simple(
                                text: '8',
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.simple(
                                text: '9',
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.operator(
                                text: 'x',
                                operator: calculator.operator,
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: CalculatorButton.simple(
                                text: '4',
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.simple(
                                text: '5',
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.simple(
                                text: '6',
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.operator(
                                text: '-',
                                operator: calculator.operator,
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: CalculatorButton.simple(
                                text: '1',
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.simple(
                                text: '2',
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.simple(
                                text: '3',
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.operator(
                                text: '+',
                                operator: calculator.operator,
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: CalculatorButton.simple(
                                text: '0',
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.simple(
                                text: '.',
                                onTap: (buttonText) => _perform(buttonText),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CalculatorButton.operator(
                                text: '=',
                                onTap: (buttonText) => _perform(buttonText, save: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _perform(String buttonText, {bool save = false}) async {
    context.read<CalculatorViewModel>().calculate(buttonText);

    if (save) await context.read<CalculatorViewModel>().save();
  }
}
