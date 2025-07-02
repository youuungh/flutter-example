import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeDetectorPainter extends CustomPainter {
  BarcodeDetectorPainter(
      this.barcodes,
      this.imageSize,
      this.rotation,
      this.cameraLensDirection,
      );

  final List<Barcode> barcodes;
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

    if (barcodes.isEmpty) return;

    for (final Barcode barcode in barcodes) {
      if (barcode.boundingBox.isEmpty) continue;

      final left = translateX(
        barcode.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        barcode.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        barcode.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        barcode.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      if (left < 0 || top < 0 || right > size.width || bottom > size.height) {
        print('좌표 범위 초과: left=$left, top=$top, right=$right, bottom=$bottom');
        print('Canvas 크기: ${size.width} x ${size.height}');
        print('Image 크기: ${imageSize.width} x ${imageSize.height}');
      }

      canvas.drawRect(
        Rect.fromLTRB(
          left.clamp(0, size.width),
          top.clamp(0, size.height),
          right.clamp(0, size.width),
          bottom.clamp(0, size.height),
        ),
        paint,
      );

      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        final textSpan = TextSpan(
          text: barcode.rawValue,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
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

      final typeText = '${barcode.type.name} - ${barcode.format.name}';
      final typeTextSpan = TextSpan(
        text: typeText,
        style: const TextStyle(
          color: Colors.lightGreenAccent,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      final typeTextPainter = TextPainter(
        text: typeTextSpan,
        textDirection: TextDirection.ltr,
      );
      typeTextPainter.layout();

      final typeOffset = Offset(left, (bottom + 5).clamp(0, size.height - 20));
      final typeBackgroundRect = Rect.fromLTWH(
        typeOffset.dx - 4,
        typeOffset.dy - 2,
        typeTextPainter.width + 8,
        typeTextPainter.height + 4,
      );
      canvas.drawRect(typeBackgroundRect, backgroundPaint);
      typeTextPainter.paint(canvas, typeOffset);
    }
  }

  @override
  bool shouldRepaint(BarcodeDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize ||
        oldDelegate.barcodes != barcodes;
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