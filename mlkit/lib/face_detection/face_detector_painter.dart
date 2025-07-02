import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
      this.faces,
      this.imageSize,
      this.rotation,
      this.cameraLensDirection,
      );

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.red;

    final Paint paint2 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.orange;

    final Paint paint3 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.blue;

    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.6);

    if (faces.isEmpty) return;

    for (final face in faces) {
      if (face.boundingBox.isEmpty) continue;

      // 얼굴 경계 상자 좌표 변환
      final left = translateX(
        face.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        face.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        face.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        face.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      // 얼굴 경계선 그리기
      final faceRect = Rect.fromLTRB(
        left.clamp(0, size.width),
        top.clamp(0, size.height),
        right.clamp(0, size.width),
        bottom.clamp(0, size.height),
      );
      canvas.drawRect(faceRect, paint1);

      // 추적 ID 표시 (있는 경우)
      if (face.trackingId != null) {
        _drawText(
          canvas,
          'ID: ${face.trackingId}',
          Offset(left, top - 35),
          const TextStyle(
            color: Colors.yellow,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          backgroundPaint,
        );
      }

      // 웃음 상태 표시
      if (face.smilingProbability != null) {
        final smilePercent = (face.smilingProbability! * 100).round();
        String smileEmoji = '😐';
        if (face.smilingProbability! > 0.7) {
          smileEmoji = '😊';
        } else if (face.smilingProbability! < 0.3) {
          smileEmoji = '😔';
        }

        _drawText(
          canvas,
          '$smileEmoji $smilePercent%',
          Offset(left, top - 20),
          const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          backgroundPaint,
        );
      }

      // 눈 상태 표시
      if (face.leftEyeOpenProbability != null && face.rightEyeOpenProbability != null) {
        final leftOpen = face.leftEyeOpenProbability! > 0.5;
        final rightOpen = face.rightEyeOpenProbability! > 0.5;

        String eyeStatus = '👀';
        if (!leftOpen && !rightOpen) {
          eyeStatus = '😴';
        } else if (!leftOpen || !rightOpen) {
          eyeStatus = '😉';
        }

        _drawText(
          canvas,
          eyeStatus,
          Offset(left, bottom + 5),
          const TextStyle(
            color: Colors.lightBlue,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          backgroundPaint,
        );
      }

      // 머리 방향 표시
      if (face.headEulerAngleY != null) {
        final angle = face.headEulerAngleY!;
        String direction = '⬆️';
        if (angle > 15) {
          direction = '➡️';
        } else if (angle < -15) {
          direction = '⬅️';
        }

        _drawText(
          canvas,
          '$direction ${angle.toStringAsFixed(0)}°',
          Offset(right - 60, top - 20),
          const TextStyle(
            color: Colors.greenAccent,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          backgroundPaint,
        );
      }

      // 얼굴 랜드마크 그리기
      _drawLandmarks(canvas, face, size);

      // 얼굴 윤곽선 그리기
      _drawContours(canvas, face, size);
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style, Paint backgroundPaint) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final backgroundRect = Rect.fromLTWH(
      position.dx - 4,
      position.dy - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
    canvas.drawRect(backgroundRect, backgroundPaint);
    textPainter.paint(canvas, position);
  }

  void _drawLandmarks(Canvas canvas, Face face, Size size) {
    // 주요 랜드마크 그리기
    final landmarks = [
      FaceLandmarkType.leftEye,
      FaceLandmarkType.rightEye,
      FaceLandmarkType.noseBase,
      FaceLandmarkType.leftMouth,
      FaceLandmarkType.rightMouth,
      FaceLandmarkType.bottomMouth,
    ];

    for (final landmarkType in landmarks) {
      final landmark = face.landmarks[landmarkType];
      if (landmark != null) {
        final x = translateX(
          landmark.position.x as double,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        final y = translateY(
          landmark.position.y as double,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );

        // 랜드마크 타입에 따른 색상 구분
        Color color = Colors.orange;
        double radius = 3;

        switch (landmarkType) {
          case FaceLandmarkType.leftEye:
          case FaceLandmarkType.rightEye:
            color = Colors.blue;
            radius = 4;
            break;
          case FaceLandmarkType.noseBase:
            color = Colors.green;
            radius = 5;
            break;
          case FaceLandmarkType.leftMouth:
          case FaceLandmarkType.rightMouth:
          case FaceLandmarkType.bottomMouth:
            color = Colors.red;
            radius = 3;
            break;
          default:
            color = Colors.orange;
        }

        canvas.drawCircle(
          Offset(x.clamp(0, size.width), y.clamp(0, size.height)),
          radius,
          Paint()
            ..style = PaintingStyle.fill
            ..color = color,
        );
      }
    }
  }

  void _drawContours(Canvas canvas, Face face, Size size) {
    // 얼굴 윤곽선 그리기
    final faceContour = face.contours[FaceContourType.face];
    if (faceContour != null && faceContour.points.isNotEmpty) {
      final path = Path();

      for (int i = 0; i < faceContour.points.length; i++) {
        final point = faceContour.points[i];
        final x = translateX(
          point.x as double,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        final y = translateY(
          point.y as double,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.yellow.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}

// 좌표 변환 함수들
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