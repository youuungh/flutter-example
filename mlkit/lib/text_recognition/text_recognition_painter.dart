import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognizerPainter extends CustomPainter {
  TextRecognizerPainter(
      this.recognizedText,
      this.imageSize,
      this.rotation,
      this.cameraLensDirection,
      );

  final RecognizedText recognizedText;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightBlueAccent;

    final Paint backgroundPaint = Paint()
      ..color = Colors.black54;

    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.yellow;

    if (recognizedText.blocks.isEmpty) return;

    for (final textBlock in recognizedText.blocks) {
      if (textBlock.boundingBox.isEmpty) continue;

      final left = translateX(
        textBlock.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        textBlock.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        textBlock.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        textBlock.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      // 블록 경계선 그리기
      canvas.drawRect(
        Rect.fromLTRB(
          left.clamp(0, size.width),
          top.clamp(0, size.height),
          right.clamp(0, size.width),
          bottom.clamp(0, size.height),
        ),
        paint,
      );

      // 라인별로 더 세밀한 경계선 그리기
      for (final line in textBlock.lines) {
        if (line.boundingBox.isEmpty) continue;

        final lineLeft = translateX(
          line.boundingBox.left,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        final lineTop = translateY(
          line.boundingBox.top,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        final lineRight = translateX(
          line.boundingBox.right,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        final lineBottom = translateY(
          line.boundingBox.bottom,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );

        canvas.drawRect(
          Rect.fromLTRB(
            lineLeft.clamp(0, size.width),
            lineTop.clamp(0, size.height),
            lineRight.clamp(0, size.width),
            lineBottom.clamp(0, size.height),
          ),
          linePaint,
        );
      }

      // 텍스트 내용 표시
      if (textBlock.text.isNotEmpty) {
        final textSpan = TextSpan(
          text: textBlock.text.length > 30
              ? '${textBlock.text.substring(0, 30)}...'
              : textBlock.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final textOffset = Offset(left, (top - 25).clamp(0, size.height));
        final textBackgroundRect = Rect.fromLTWH(
          textOffset.dx - 4,
          textOffset.dy - 2,
          textPainter.width + 8,
          textPainter.height + 4,
        );
        canvas.drawRect(textBackgroundRect, backgroundPaint);
        textPainter.paint(canvas, textOffset);
      }

      // 언어 정보 표시
      if (textBlock.recognizedLanguages.isNotEmpty) {
        final languageText = 'Lang: ${textBlock.recognizedLanguages.first}';
        final languageSpan = TextSpan(
          text: languageText,
          style: const TextStyle(
            color: Colors.lightBlueAccent,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        );
        final languagePainter = TextPainter(
          text: languageSpan,
          textDirection: TextDirection.ltr,
        );
        languagePainter.layout();

        final languageOffset = Offset(left, (bottom + 5).clamp(0, size.height - 15));
        final languageBackgroundRect = Rect.fromLTWH(
          languageOffset.dx - 4,
          languageOffset.dy - 2,
          languagePainter.width + 8,
          languagePainter.height + 4,
        );
        canvas.drawRect(languageBackgroundRect, backgroundPaint);
        languagePainter.paint(canvas, languageOffset);
      }
    }
  }

  @override
  bool shouldRepaint(TextRecognizerPainter oldDelegate) {
    return oldDelegate.recognizedText != recognizedText;
  }
}

double translateX(
    double x,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection cameraLensDirection,
    ) {
  if (imageSize.width == 0) return 0;

  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x *
          canvasSize.width /
          (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation270deg:
      return canvasSize.width -
          x *
              canvasSize.width /
              (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      switch (cameraLensDirection) {
        case CameraLensDirection.back:
          return x * canvasSize.width / imageSize.width;
        default:
          return canvasSize.width - x * canvasSize.width / imageSize.width;
      }
  }
}

double translateY(
    double y,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection cameraLensDirection,
    ) {
  if (imageSize.height == 0) return 0;

  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y *
          canvasSize.height /
          (Platform.isIOS ? imageSize.height : imageSize.width);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return y * canvasSize.height / imageSize.height;
  }
}