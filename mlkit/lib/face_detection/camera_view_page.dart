import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    super.key,
    required this.customPaint,
    required this.onImage,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
    this.initialCameraLensDirection = CameraLensDirection.front,
  });

  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  bool _changingCameraLens = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }

      // 원하는 카메라 찾기
      for (var i = 0; i < _cameras.length; i++) {
        if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
          _cameraIndex = i;
          break;
        }
      }

      // 원하는 카메라가 없으면 첫 번째 카메라 사용
      if (_cameraIndex == -1 && _cameras.isNotEmpty) {
        _cameraIndex = 0;
      }

      if (_cameraIndex != -1) {
        await _startLiveFeed();
      }
    } catch (e) {
      print('카메라 초기화 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('카메라 초기화 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('얼굴 인식'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 상태 표시
          if (!_isInitialized)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _liveFeedBody(),
    );
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '카메라를 사용할 수 없습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '카메라 권한을 확인해주세요',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_controller == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('카메라 초기화 중...'),
          ],
        ),
      );
    }

    if (!_controller!.value.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('카메라 준비 중...'),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: _changingCameraLens
                ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Changing camera lens',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            )
                : CameraPreview(
              _controller!,
              child: widget.customPaint,
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Stack(
      children: [
        // 갤러리 모드 전환 버튼
        Positioned(
          bottom: 16,
          left: 16,
          child: SizedBox(
            height: 50.0,
            width: 50.0,
            child: FloatingActionButton(
              heroTag: "gallery_mode",
              onPressed: widget.onDetectorViewModeChanged,
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 25,
                color: Colors.black,
              ),
            ),
          ),
        ),
        // 카메라 전환 버튼
        Positioned(
          bottom: 16,
          right: 16,
          child: SizedBox(
            height: 50.0,
            width: 50.0,
            child: FloatingActionButton(
              heroTag: "camera_switch",
              onPressed: _cameras.length > 1 ? _switchLiveCamera : null,
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              child: Icon(
                Platform.isIOS
                    ? Icons.flip_camera_ios_outlined
                    : Icons.flip_camera_android_outlined,
                size: 25,
                color: _cameras.length > 1 ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
        // 줌 컨트롤
        if (_isInitialized) _zoomControl(),
      ],
    );
  }

  Widget _zoomControl() {
    return Positioned(
      bottom: 16,
      left: 80,
      right: 80,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Slider(
                value: _currentZoomLevel,
                min: _minAvailableZoom,
                max: _maxAvailableZoom,
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                onChanged: (value) async {
                  try {
                    setState(() {
                      _currentZoomLevel = value;
                    });
                    await _controller?.setZoomLevel(value);
                  } catch (e) {
                    print('줌 설정 오류: $e');
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 45,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${_currentZoomLevel.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startLiveFeed() async {
    try {
      if (_cameraIndex < 0 || _cameraIndex >= _cameras.length) return;

      final camera = _cameras[_cameraIndex];
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();

      if (!mounted) return;

      // 줌 레벨 설정
      try {
        _minAvailableZoom = await _controller!.getMinZoomLevel();
        _maxAvailableZoom = await _controller!.getMaxZoomLevel();
        _currentZoomLevel = _minAvailableZoom;
      } catch (e) {
        print('줌 레벨 설정 오류: $e');
        _minAvailableZoom = 1.0;
        _maxAvailableZoom = 1.0;
        _currentZoomLevel = 1.0;
      }

      // 이미지 스트림 시작
      await _controller!.startImageStream(_processCameraImage);

      _isInitialized = true;

      if (widget.onCameraFeedReady != null) {
        widget.onCameraFeedReady!();
      }
      if (widget.onCameraLensDirectionChanged != null) {
        widget.onCameraLensDirectionChanged!(camera.lensDirection);
      }

      if (mounted) setState(() {});
    } catch (e) {
      print('카메라 시작 오류: $e');
      _isInitialized = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('카메라 시작 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {});
      }
    }
  }

  Future<void> _stopLiveFeed() async {
    try {
      await _controller?.stopImageStream();
      await _controller?.dispose();
      _controller = null;
      _isInitialized = false;
    } catch (e) {
      print('카메라 중지 오류: $e');
    }
  }

  Future<void> _switchLiveCamera() async {
    if (_cameras.length <= 1) return;

    setState(() => _changingCameraLens = true);

    try {
      _cameraIndex = (_cameraIndex + 1) % _cameras.length;
      await _stopLiveFeed();
      await _startLiveFeed();
    } catch (e) {
      print('카메라 전환 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('카메라 전환 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _changingCameraLens = false);
    }
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    try {
      final camera = _cameras[_cameraIndex];
      final sensorOrientation = camera.sensorOrientation;

      InputImageRotation? rotation;
      if (Platform.isIOS) {
        rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
      } else if (Platform.isAndroid) {
        var rotationCompensation =
        _orientations[_controller!.value.deviceOrientation];
        if (rotationCompensation == null) return null;
        if (camera.lensDirection == CameraLensDirection.front) {
          rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
        } else {
          rotationCompensation =
              (sensorOrientation - rotationCompensation + 360) % 360;
        }
        rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      }
      if (rotation == null) return null;

      final format = InputImageFormatValue.fromRawValue(image.format.raw);

      if (format == null ||
          (Platform.isAndroid && format != InputImageFormat.nv21) ||
          (Platform.isIOS && format != InputImageFormat.bgra8888)) {
        return null;
      }

      if (image.planes.length != 1) return null;
      final plane = image.planes.first;

      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(
            image.width.toDouble(),
            image.height.toDouble(),
          ),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      print('이미지 변환 오류: $e');
      return null;
    }
  }

  void _processCameraImage(CameraImage image) {
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;
      widget.onImage(inputImage);
    } catch (e) {
      print('카메라 이미지 처리 오류: $e');
    }
  }
}