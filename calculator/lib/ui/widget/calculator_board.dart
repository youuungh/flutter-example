import 'package:flutter/material.dart';

class CalculatorBoard extends StatelessWidget {
  final String number;
  final String expression;

  const CalculatorBoard({
    super.key,
    this.number = '0',
    this.expression = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 연산 과정 표시 (작은 텍스트)
          if (expression.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                expression,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          
          // 현재 결과 표시 (큰 텍스트)
          FittedBox(
            child: Text(
              number.isNotEmpty ? number : '0',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
