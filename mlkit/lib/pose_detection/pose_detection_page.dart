import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/pose_detection/detector_view.dart';
import 'package:mlkit/pose_detection/pose_painter.dart';

class PoseDetectionPage extends StatefulWidget {
  const PoseDetectionPage({super.key});

  @override
  State<PoseDetectionPage> createState() => _PoseDetectionPageState();
}

class _PoseDetectionPageState extends State<PoseDetectionPage> {
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자세 인식'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<ImageSource>(
            onSelected: (ImageSource source) => _getImage(source),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<ImageSource>>[
              const PopupMenuItem<ImageSource>(
                value: ImageSource.gallery,
                child: Row(
                  children: [
                    Icon(Icons.photo_library),
                    SizedBox(width: 8),
                    Text('갤러리'),
                  ],
                ),
              ),
              const PopupMenuItem<ImageSource>(
                value: ImageSource.camera,
                child: Row(
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 8),
                    Text('카메라'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: DetectorView(
        title: '자세 인식',
        customPaint: _customPaint,
        text: _text,
        onImage: _processImage,
        initialCameraLensDirection: _cameraLensDirection,
        onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    setState(() {
      _customPaint = null;
      _text = '';
    });

    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      _processFile(pickedFile.path);
    }
  }

  Future<void> _processFile(String path) async {
    setState(() {
      _customPaint = null;
      _text = '';
    });

    final inputImage = InputImage.fromFilePath(path);
    _processImage(inputImage);
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });

    try {
      final poses = await _poseDetector.processImage(inputImage);
      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = PosePainter(
          poses,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      } else {
        String text = '감지된 자세: ${poses.length}\n\n';
        for (final pose in poses) {
          text += '자세 ID: ${pose.landmarks.length}개 랜드마크\n';

          // 주요 랜드마크들의 정보 표시
          final landmarks = pose.landmarks;
          if (landmarks.containsKey(PoseLandmarkType.nose)) {
            final nose = landmarks[PoseLandmarkType.nose]!;
            text += '코: (${nose.x.toStringAsFixed(1)}, ${nose.y.toStringAsFixed(1)})\n';
          }

          if (landmarks.containsKey(PoseLandmarkType.leftShoulder) &&
              landmarks.containsKey(PoseLandmarkType.rightShoulder)) {
            final leftShoulder = landmarks[PoseLandmarkType.leftShoulder]!;
            final rightShoulder = landmarks[PoseLandmarkType.rightShoulder]!;
            text += '어깨 너비: ${(leftShoulder.x - rightShoulder.x).abs().toStringAsFixed(1)}\n';
          }

          text += '\n';
        }
        _text = text;
        _customPaint = null;
      }
    } catch (e) {
      _text = '오류가 발생했습니다: $e';
      _customPaint = null;
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}