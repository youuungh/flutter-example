import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'face_detector_painter.dart';
import 'camera_view_page.dart';
import 'gallery_page.dart';

enum DetectorViewMode { liveFeed, gallery }

class FaceDetectionPage extends StatefulWidget {
  const FaceDetectionPage({super.key});

  @override
  State<FaceDetectionPage> createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front; // 얼굴 인식은 전면 카메라가 기본
  bool _isBusy = false;
  bool _canProcess = true;

  FaceDetector? _faceDetector;

  @override
  void initState() {
    super.initState();
    _initializeDetector();
  }

  void _initializeDetector() {
    try {
      // 가장 기본적인 옵션으로 설정 (안정성 우선)
      final options = FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        enableClassification: true,
        enableTracking: false, // 추적 기능 비활성화로 안정성 향상
      );
      _faceDetector = FaceDetector(options: options);
    } catch (e) {
      print('얼굴 감지기 초기화 오류: $e');
      // 오류 발생 시 기본 옵션으로 재시도
      try {
        _faceDetector = FaceDetector(options: FaceDetectorOptions());
      } catch (e2) {
        print('기본 옵션으로도 초기화 실패: $e2');
      }
    }
  }

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetectorView(
        title: "얼굴 인식",
        customPaint: _customPaint,
        text: _text,
        onImage: _processImage,
        initialCameraLensDirection: _cameraLensDirection,
        initialDetectionMode: DetectorViewMode.gallery,
        onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
      ),
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    if (_faceDetector == null) return;

    _isBusy = true;

    setState(() {
      _text = '';
    });

    try {
      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isNotEmpty) {
        if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
          final painter = FaceDetectorPainter(
            faces,
            inputImage.metadata!.size,
            inputImage.metadata!.rotation,
            _cameraLensDirection,
          );
          _customPaint = CustomPaint(painter: painter);
        } else {
          final painter = FaceDetectorPainter(
            faces,
            const Size(1080, 1920),
            InputImageRotation.rotation0deg,
            _cameraLensDirection,
          );
          _customPaint = CustomPaint(painter: painter);
        }
      } else {
        _customPaint = null;
      }

      String text = '감지된 얼굴: ${faces.length}개\n\n';

      for (int i = 0; i < faces.length; i++) {
        final face = faces[i];
        text += '얼굴 ${i + 1}:\n';
        text += '위치: ${face.boundingBox}\n';

        // 추적 ID (활성화된 경우만)
        if (face.trackingId != null) {
          text += '추적 ID: ${face.trackingId}\n';
        }

        // 감정 분석
        if (face.smilingProbability != null) {
          final smilePercent = (face.smilingProbability! * 100).toStringAsFixed(1);
          text += '웃음 확률: $smilePercent%\n';

          if (face.smilingProbability! > 0.7) {
            text += '😊 웃고 있음\n';
          } else if (face.smilingProbability! > 0.3) {
            text += '😐 보통\n';
          } else {
            text += '😔 웃지 않음\n';
          }
        }

        // 눈 상태
        if (face.leftEyeOpenProbability != null && face.rightEyeOpenProbability != null) {
          final leftOpen = face.leftEyeOpenProbability! > 0.5;
          final rightOpen = face.rightEyeOpenProbability! > 0.5;

          if (leftOpen && rightOpen) {
            text += '👀 눈이 열려있음\n';
          } else if (!leftOpen && !rightOpen) {
            text += '😴 눈이 감겨있음\n';
          } else {
            text += '😉 윙크\n';
          }

          text += '왼쪽 눈: ${(face.leftEyeOpenProbability! * 100).toStringAsFixed(1)}%\n';
          text += '오른쪽 눈: ${(face.rightEyeOpenProbability! * 100).toStringAsFixed(1)}%\n';
        }

        // 머리 방향
        if (face.headEulerAngleY != null) {
          final yAngle = face.headEulerAngleY!;
          text += '좌우 회전: ${yAngle.toStringAsFixed(1)}°';
          if (yAngle > 15) {
            text += ' (오른쪽 향함)';
          } else if (yAngle < -15) {
            text += ' (왼쪽 향함)';
          } else {
            text += ' (정면)';
          }
          text += '\n';
        }

        if (face.headEulerAngleZ != null) {
          final zAngle = face.headEulerAngleZ!;
          text += '기울임: ${zAngle.toStringAsFixed(1)}°';
          if (zAngle > 15) {
            text += ' (오른쪽 기울임)';
          } else if (zAngle < -15) {
            text += ' (왼쪽 기울임)';
          } else {
            text += ' (수직)';
          }
          text += '\n';
        }

        text += '\n';
      }

      if (faces.isEmpty) {
        text += '얼굴을 찾을 수 없습니다.\n\n';
        text += '💡 팁:\n';
        text += '• 조명이 밝은 곳에서 시도해보세요\n';
        text += '• 카메라와 얼굴 사이의 거리를 조절해보세요\n';
        text += '• 얼굴이 화면에 완전히 보이는지 확인하세요';
      }

      _text = text;
    } catch (e) {
      print('얼굴 인식 처리 중 오류: $e');
      _text = '얼굴 인식 중 오류가 발생했습니다.\n\n오류: $e\n\n앱을 다시 시작해보세요.';
      _customPaint = null;
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

// DetectorView 클래스
class DetectorView extends StatefulWidget {
  const DetectorView({
    super.key,
    required this.title,
    required this.onImage,
    this.customPaint,
    this.text,
    this.initialDetectionMode = DetectorViewMode.gallery,
    this.initialCameraLensDirection = CameraLensDirection.front,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
  });

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final DetectorViewMode initialDetectionMode;
  final Function(InputImage inputImage) onImage;
  final Function()? onCameraFeedReady;
  final Function(DetectorViewMode mode)? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<DetectorView> createState() => _DetectorViewState();
}

class _DetectorViewState extends State<DetectorView> {
  late DetectorViewMode _mode;

  @override
  void initState() {
    _mode = widget.initialDetectionMode;
    super.initState();
  }

  void _onDetectorViewModeChanged() {
    if (_mode == DetectorViewMode.liveFeed) {
      _mode = DetectorViewMode.gallery;
    } else {
      _mode = DetectorViewMode.liveFeed;
    }
    if (widget.onDetectorViewModeChanged != null) {
      widget.onDetectorViewModeChanged!(_mode);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return switch (_mode) {
      DetectorViewMode.liveFeed => CameraView(
        customPaint: widget.customPaint,
        onImage: widget.onImage,
        onCameraFeedReady: widget.onCameraFeedReady,
        onDetectorViewModeChanged: _onDetectorViewModeChanged,
        initialCameraLensDirection: widget.initialCameraLensDirection,
        onCameraLensDirectionChanged: widget.onCameraLensDirectionChanged,
      ),
      _ => GalleryView(
        title: widget.title,
        text: widget.text,
        onImage: widget.onImage,
        onDetectorViewModeChanged: _onDetectorViewModeChanged,
      ),
    };
  }
}