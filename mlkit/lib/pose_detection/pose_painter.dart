import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  PosePainter(
      this.poses,
      this.imageSize,
      this.rotation,
      this.cameraLensDirection,
      );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    final pointPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0
      ..color = Colors.red;

    for (final pose in poses) {
      // 모든 랜드마크 포인트 그리기
      pose.landmarks.forEach((type, landmark) {
        final point = Offset(
          translateX(
            landmark.x,
            size,
            imageSize,
            rotation,
            cameraLensDirection,
          ),
          translateY(
            landmark.y,
            size,
            imageSize,
            rotation,
            cameraLensDirection,
          ),
        );
        canvas.drawCircle(point, 3, pointPaint);
      });

      // 신체 연결선 그리기
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.nose, PoseLandmarkType.leftEyeInner, paint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftEyeInner, PoseLandmarkType.leftEye, paint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftEye, PoseLandmarkType.leftEyeOuter, paint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftEyeOuter, PoseLandmarkType.leftEar, paint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.nose, PoseLandmarkType.rightEyeInner, paint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.rightEyeInner, PoseLandmarkType.rightEye, paint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.rightEye, PoseLandmarkType.rightEyeOuter, paint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.rightEyeOuter, PoseLandmarkType.rightEar, paint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftMouth, PoseLandmarkType.rightMouth, paint);

      // 왼쪽 팔 (노란색)
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb, leftPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftWrist, PoseLandmarkType.leftPinky, leftPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftWrist, PoseLandmarkType.leftIndex, leftPaint);

      // 오른쪽 팔 (파란색)
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, rightPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb, rightPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.rightWrist, PoseLandmarkType.rightPinky, rightPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.rightWrist, PoseLandmarkType.rightIndex, rightPaint);

      // 몸통
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, paint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, paint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, paint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, paint);

      // 왼쪽 다리 (노란색)
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel, leftPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.leftHeel, PoseLandmarkType.leftFootIndex, leftPaint);

      // 오른쪽 다리 (파란색)
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel, rightPaint);
      _paintPoseLine(canvas, size, pose, PoseLandmarkType.rightHeel, PoseLandmarkType.rightFootIndex, rightPaint);
    }
  }

  void _paintPoseLine(
      Canvas canvas,
      Size size,
      Pose pose,
      PoseLandmarkType type1,
      PoseLandmarkType type2,
      Paint paint,
      ) {
    final PoseLandmark? joint1 = pose.landmarks[type1];
    final PoseLandmark? joint2 = pose.landmarks[type2];

    if (joint1 == null || joint2 == null) {
      return;
    }

    final point1 = Offset(
      translateX(
        joint1.x,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      ),
      translateY(
        joint1.y,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      ),
    );
    final point2 = Offset(
      translateX(
        joint2.x,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      ),
      translateY(
        joint2.y,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      ),
    );
    canvas.drawLine(point1, point2, paint);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }
}

double translateX(
    double x,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection cameraLensDirection,
    ) {
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