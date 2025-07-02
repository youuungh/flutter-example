import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class ObjectDetectorPainter extends CustomPainter {
  ObjectDetectorPainter(
      this.objects,
      this.imageSize,
      this.rotation,
      this.cameraLensDirection,
      );

  final List<DetectedObject> objects;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    final Paint backgroundPaint = Paint()
      ..color = Colors.black54;

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.lightGreenAccent.withValues(alpha: 0.1);

    if (objects.isEmpty) return;

    for (final detectedObject in objects) {
      if (detectedObject.boundingBox.isEmpty) continue;

      final left = translateX(
        detectedObject.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        detectedObject.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        detectedObject.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        detectedObject.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      final rect = Rect.fromLTRB(
        left.clamp(0, size.width),
        top.clamp(0, size.height),
        right.clamp(0, size.width),
        bottom.clamp(0, size.height),
      );

      // 반투명 채우기
      canvas.drawRect(rect, fillPaint);

      // 경계선 그리기
      canvas.drawRect(rect, paint);

      // 추적 ID 표시 (있는 경우)
      if (detectedObject.trackingId != null) {
        final idText = 'ID: ${detectedObject.trackingId}';
        final idSpan = TextSpan(
          text: idText,
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        final idPainter = TextPainter(
          text: idSpan,
          textDirection: TextDirection.ltr,
        );
        idPainter.layout();

        final idOffset = Offset(left, (top - 35).clamp(0, size.height));
        final idBackgroundRect = Rect.fromLTWH(
          idOffset.dx - 4,
          idOffset.dy - 2,
          idPainter.width + 8,
          idPainter.height + 4,
        );
        canvas.drawRect(idBackgroundRect, backgroundPaint);
        idPainter.paint(canvas, idOffset);
      }

      // 가장 신뢰도 높은 라벨 표시
      if (detectedObject.labels.isNotEmpty) {
        final bestLabel = detectedObject.labels.first;
        final labelText = '${bestLabel.text} (${(bestLabel.confidence * 100).toStringAsFixed(1)}%)';
        final labelSpan = TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
        final labelPainter = TextPainter(
          text: labelSpan,
          textDirection: TextDirection.ltr,
        );
        labelPainter.layout();

        final labelOffset = Offset(left, (top - 20).clamp(0, size.height));
        final labelBackgroundRect = Rect.fromLTWH(
          labelOffset.dx - 4,
          labelOffset.dy - 2,
          labelPainter.width + 8,
          labelPainter.height + 4,
        );
        canvas.drawRect(labelBackgroundRect, backgroundPaint);
        labelPainter.paint(canvas, labelOffset);
      }

      // 객체 정보 표시 (하단)
      final infoText = 'Object';
      final infoSpan = TextSpan(
        text: infoText,
        style: const TextStyle(
          color: Colors.lightGreenAccent,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      final infoPainter = TextPainter(
        text: infoSpan,
        textDirection: TextDirection.ltr,
      );
      infoPainter.layout();

      final infoOffset = Offset(left, (bottom + 5).clamp(0, size.height - 20));
      final infoBackgroundRect = Rect.fromLTWH(
        infoOffset.dx - 4,
        infoOffset.dy - 2,
        infoPainter.width + 8,
        infoPainter.height + 4,
      );
      canvas.drawRect(infoBackgroundRect, backgroundPaint);
      infoPainter.paint(canvas, infoOffset);
    }
  }

  @override
  bool shouldRepaint(ObjectDetectorPainter oldDelegate) {
    return oldDelegate.objects != objects;
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