import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'text_recognition_painter.dart';
import 'camera_view_page.dart';
import 'gallery_page.dart';

enum DetectorViewMode { liveFeed, gallery }

class TextRecognitionPage extends StatefulWidget {
  const TextRecognitionPage({super.key});

  @override
  State<TextRecognitionPage> createState() => _TextRecognitionPageState();
}

class _TextRecognitionPageState extends State<TextRecognitionPage> {
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;
  bool _isBusy = false;
  bool _canProcess = true;

  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  void dispose() {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetectorView(
        title: "텍스트 인식",
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

    final recognizedText = await _textRecognizer.processImage(inputImage);

    if (recognizedText.text.isNotEmpty) {
      if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
        final painter = TextRecognizerPainter(
          recognizedText,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      } else {
        final painter = TextRecognizerPainter(
          recognizedText,
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
    String text = '인식된 텍스트: ${recognizedText.blocks.length}개 블록\n\n';

    if (recognizedText.text.isNotEmpty) {
      text += '전체 텍스트:\n${recognizedText.text}\n\n';

      // 블록별 상세 정보
      text += '블록별 정보:\n';
      for (int i = 0; i < recognizedText.blocks.length; i++) {
        final block = recognizedText.blocks[i];
        text += '블록 ${i + 1}: ${block.text}\n';
        text += 'boundingBox: ${block.boundingBox}\n';
        text += 'lines: ${block.lines.length}개\n';
        text += 'language: ${block.recognizedLanguages.isNotEmpty ? block.recognizedLanguages.first : 'N/A'}\n\n';
      }
    } else {
      text += '텍스트를 찾을 수 없습니다.';
    }

    _text = text;

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

// DetectorView 클래스는 바코드와 동일
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