import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'object_detector_painter.dart';
import 'camera_view_page.dart';
import 'gallery_page.dart';

enum DetectorViewMode { liveFeed, gallery }

class ObjectDetectionPage extends StatefulWidget {
  const ObjectDetectionPage({super.key});

  @override
  State<ObjectDetectionPage> createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;
  bool _isBusy = false;
  bool _canProcess = true;

  late ObjectDetector _objectDetector;

  @override
  void initState() {
    super.initState();
    _initializeDetector();
  }

  void _initializeDetector() {
    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  @override
  void dispose() {
    _canProcess = false;
    _objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetectorView(
        title: "객체 감지",
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
    _isBusy = true;

    setState(() {
      _text = '';
    });

    final objects = await _objectDetector.processImage(inputImage);

    if (objects.isNotEmpty) {
      if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
        final painter = ObjectDetectorPainter(
          objects,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      } else {
        final painter = ObjectDetectorPainter(
          objects,
          const Size(1080, 1920), // 기본 크기
          InputImageRotation.rotation0deg, // 기본 회전
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      }
    } else {
      _customPaint = null;
    }

    // 텍스트 정보 생성
    String text = '감지된 객체: ${objects.length}개\n\n';

    if (objects.isNotEmpty) {
      for (int i = 0; i < objects.length; i++) {
        final object = objects[i];
        text += '객체 ${i + 1}:\n';
        text += 'boundingBox: ${object.boundingBox}\n';
        text += 'trackingId: ${object.trackingId ?? 'N/A'}\n';

        if (object.labels.isNotEmpty) {
          text += '분류:\n';
          for (final label in object.labels) {
            text += '  - ${label.text}: ${(label.confidence * 100).toStringAsFixed(1)}%\n';
          }
        } else {
          text += '분류: 없음\n';
        }
        text += '\n';
      }
    } else {
      text += '객체를 찾을 수 없습니다.';
    }

    _text = text;

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
    this.initialCameraLensDirection = CameraLensDirection.back,
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