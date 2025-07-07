import 'dart:ui';
import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final bool isSelected;
  final Function(String) onTap;

  const CalculatorButton({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0xFF333333),
    this.isSelected = false,
    required this.onTap,
  });

  factory CalculatorButton.simple({
    required String text,
    required Function(String) onTap,
  }) {
    return CalculatorButton(
      text: text,
      backgroundColor: const Color(0xFF333333),
      onTap: onTap,
    );
  }

  factory CalculatorButton.complex({
    required String text,
    required Function(String) onTap,
  }) {
    return CalculatorButton(
      text: text,
      backgroundColor: const Color(0xFF666666),
      onTap: onTap,
    );
  }

  factory CalculatorButton.operator({
    required String text,
    String operator = '',
    required Function(String) onTap,
  }) {
    return CalculatorButton(
      text: text,
      backgroundColor: text == operator 
          ? const Color(0xFF007AFF)
          : const Color(0xFFFF9500),
      isSelected: text == operator,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(text),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: backgroundColor.withOpacity(0.8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
