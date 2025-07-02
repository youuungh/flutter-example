import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'barcode_painter.dart';
import 'camera_view_page.dart';
import 'gallery_page.dart';

enum DetectorViewMode { liveFeed, gallery }

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;
  bool _isBusy = false;
  bool _canProcess = true;

  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  @override
  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetectorView(
        title: "바코드 스캐너",
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

    final barcodes = await _barcodeScanner.processImage(inputImage);

    if (barcodes.isNotEmpty) {
      if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
        final painter = BarcodeDetectorPainter(
          barcodes,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      } else {
        final painter = BarcodeDetectorPainter(
          barcodes,
          const Size(1080, 1920), // 기본 크기 (실제 이미지 크기로 조정 필요)
          InputImageRotation.rotation0deg, // 기본 회전
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      }
    } else {
      _customPaint = null;
    }

    // 텍스트 정보 생성
    String text = '바코드 탐색: ${barcodes.length}개 \n\n';
    for (final barcode in barcodes) {
      text += "바코드 값: ${barcode.rawValue} \n";
      text += "boundingBox : ${barcode.boundingBox} \n";
      text += "format : ${barcode.format} \n";
      text += "type : ${barcode.type} \n\n";
    }
    _text = text;

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

// DetectorView 클래스는 동일하게 유지
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