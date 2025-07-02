import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:mlkit/pose_detection/camera_view.dart';

class DetectorView extends StatefulWidget {
  const DetectorView({
    Key? key,
    required this.title,
    required this.onImage,
    this.customPaint,
    this.text,
    this.initialCameraLensDirection = CameraLensDirection.back,
    this.onCameraLensDirectionChanged,
  }) : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialCameraLensDirection;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;

  @override
  State<DetectorView> createState() => _DetectorViewState();
}

class _DetectorViewState extends State<DetectorView> {
  bool _liveFeedEnabled = true;
  int _poseCount = 0;
  bool _isDetecting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _switchMode,
            icon: Icon(
              _liveFeedEnabled ? Icons.photo_camera : Icons.videocam,
            ),
          ),
        ],
      ),
      body: _liveFeedEnabled ? _liveFeedBody() : _galleryBody(),
    );
  }

  Widget _liveFeedBody() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraView(
            customPaint: widget.customPaint,
            onImage: (image) {
              setState(() {
                _isDetecting = true;
              });
              widget.onImage(image);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  setState(() {
                    _isDetecting = false;
                  });
                }
              });
            },
            onCameraFeedReady: () {
              setState(() {});
            },
            onCameraLensDirectionChanged: widget.onCameraLensDirectionChanged,
            initialCameraLensDirection: widget.initialCameraLensDirection,
          ),
          _buildStatusOverlay(),
        ],
      ),
    );
  }

  Widget _galleryBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade100,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: widget.customPaint != null
                ? Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.customPaint!,
              ),
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.accessibility_new,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '이미지를 선택하여\n자세를 분석해보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 갤러리에서 이미지 선택 로직은 부모에서 처리
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('이미지 선택'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.text != null && widget.text!.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '분석 결과',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.text!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusOverlay() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isDetecting ? Colors.red : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isDetecting ? '분석 중...' : '실시간 분석',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '실시간 모드',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _switchMode() {
    setState(() {
      _liveFeedEnabled = !_liveFeedEnabled;
    });
  }
}