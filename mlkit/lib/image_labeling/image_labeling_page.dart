import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'label_detector_painter.dart';
import 'camera_view_page.dart';
import 'gallery_page.dart';

enum DetectorViewMode { liveFeed, gallery }

class ImageLabelingPage extends StatefulWidget {
  const ImageLabelingPage({super.key});

  @override
  State<ImageLabelingPage> createState() => _ImageLabelingPageState();
}

class _ImageLabelingPageState extends State<ImageLabelingPage> {
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;
  bool _isBusy = false;
  bool _canProcess = true;

  late ImageLabeler _imageLabeler;

  @override
  void initState() {
    super.initState();
    _initializeLabeler();
  }

  void _initializeLabeler() {
    final options = ImageLabelerOptions(
      confidenceThreshold: 0.5, // 50% 이상 신뢰도만 표시
    );
    _imageLabeler = ImageLabeler(options: options);
  }

  @override
  void dispose() {
    _canProcess = false;
    _imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetectorView(
        title: "이미지 라벨링",
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

    final labels = await _imageLabeler.processImage(inputImage);

    if (labels.isNotEmpty) {
      final painter = LabelDetectorPainter(labels);
      _customPaint = CustomPaint(painter: painter);
    } else {
      _customPaint = null;
    }

    // 텍스트 정보 생성
    String text = '감지된 라벨: ${labels.length}개\n\n';

    if (labels.isNotEmpty) {
      // 신뢰도 순으로 정렬
      labels.sort((a, b) => b.confidence.compareTo(a.confidence));

      text += '이미지 분류 결과:\n';
      for (int i = 0; i < labels.length; i++) {
        final label = labels[i];
        text += '${i + 1}. ${label.label}: ${(label.confidence * 100).toStringAsFixed(1)}%\n';
      }

      text += '\n상위 3개 분류:\n';
      for (int i = 0; i < 3 && i < labels.length; i++) {
        final label = labels[i];
        final confidenceEmoji = label.confidence > 0.8 ? '🟢' :
        label.confidence > 0.6 ? '🟡' : '🔴';
        text += '$confidenceEmoji ${label.label} (${(label.confidence * 100).toStringAsFixed(1)}%)\n';
      }
    } else {
      text += '라벨을 찾을 수 없습니다.\n신뢰도 임계값: 50%';
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