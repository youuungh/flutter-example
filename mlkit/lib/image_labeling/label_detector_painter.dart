import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class LabelDetectorPainter extends CustomPainter {
  LabelDetectorPainter(this.labels);

  final List<ImageLabel> labels;

  @override
  void paint(Canvas canvas, Size size) {
    if (labels.isEmpty) return;

    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7);

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.redAccent;

    // 신뢰도 순으로 정렬
    final sortedLabels = List<ImageLabel>.from(labels);
    sortedLabels.sort((a, b) => b.confidence.compareTo(a.confidence));

    // 상위 5개 라벨만 표시
    final displayLabels = sortedLabels.take(5).toList();

    // 라벨 박스 크기 계산
    const double padding = 16.0;
    const double itemHeight = 35.0;
    const double borderRadius = 8.0;

    final double boxHeight = (displayLabels.length * itemHeight) + (padding * 2);
    final double boxWidth = size.width - 32; // 양쪽 여백 16씩

    // 배경 박스 그리기 (상단에 위치)
    final Rect backgroundRect = Rect.fromLTWH(
      16, // 왼쪽 여백
      16, // 상단 여백
      boxWidth,
      boxHeight,
    );

    final RRect backgroundRRect = RRect.fromRectAndRadius(
      backgroundRect,
      const Radius.circular(borderRadius),
    );

    // 배경과 테두리 그리기
    canvas.drawRRect(backgroundRRect, backgroundPaint);
    canvas.drawRRect(backgroundRRect, borderPaint);

    // 제목 텍스트
    const titleSpan = TextSpan(
      text: '🏷️ 이미지 분류',
      style: TextStyle(
        color: Colors.redAccent,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    final titlePainter = TextPainter(
      text: titleSpan,
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, Offset(28, 24));

    // 각 라벨 표시
    for (int i = 0; i < displayLabels.length; i++) {
      final label = displayLabels[i];
      final yPosition = 50 + (i * itemHeight);

      // 신뢰도에 따른 색상
      Color confidenceColor;
      String confidenceEmoji;

      if (label.confidence > 0.8) {
        confidenceColor = Colors.green;
        confidenceEmoji = '🟢';
      } else if (label.confidence > 0.6) {
        confidenceColor = Colors.orange;
        confidenceEmoji = '🟡';
      } else {
        confidenceColor = Colors.red;
        confidenceEmoji = '🔴';
      }

      // 라벨 텍스트
      final labelText = '$confidenceEmoji ${label.label}';
      final labelSpan = TextSpan(
        text: labelText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
      final labelPainter = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(canvas, Offset(28, yPosition));

      // 신뢰도 텍스트 (오른쪽 정렬)
      final confidenceText = '${(label.confidence * 100).toStringAsFixed(1)}%';
      final confidenceSpan = TextSpan(
        text: confidenceText,
        style: TextStyle(
          color: confidenceColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      final confidencePainter = TextPainter(
        text: confidenceSpan,
        textDirection: TextDirection.ltr,
      );
      confidencePainter.layout();

      final confidenceX = backgroundRect.right - confidencePainter.width - 12;
      confidencePainter.paint(canvas, Offset(confidenceX, yPosition));

      // 신뢰도 바 그리기
      final barWidth = 60.0;
      final barHeight = 4.0;
      final barX = confidenceX - barWidth - 8;
      final barY = yPosition + 8;

      // 배경 바
      final barBackgroundRect = Rect.fromLTWH(barX, barY, barWidth, barHeight);
      final barBackgroundPaint = Paint()..color = Colors.grey.withOpacity(0.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(barBackgroundRect, const Radius.circular(2)),
        barBackgroundPaint,
      );

      // 신뢰도 바
      final confidenceBarWidth = barWidth * label.confidence;
      final barRect = Rect.fromLTWH(barX, barY, confidenceBarWidth, barHeight);
      final barPaint = Paint()..color = confidenceColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(2)),
        barPaint,
      );
    }

    // 하단에 전체 라벨 수 표시
    if (labels.length > 5) {
      final moreText = '+${labels.length - 5} more labels';
      final moreSpan = TextSpan(
        text: moreText,
        style: TextStyle(
          color: Colors.grey[300],
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      );
      final morePainter = TextPainter(
        text: moreSpan,
        textDirection: TextDirection.ltr,
      );
      morePainter.layout();
      morePainter.paint(
        canvas,
        Offset(28, backgroundRect.bottom + 8),
      );
    }
  }

  @override
  bool shouldRepaint(LabelDetectorPainter oldDelegate) {
    return oldDelegate.labels != labels;
  }
}