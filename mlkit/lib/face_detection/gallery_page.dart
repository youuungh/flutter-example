import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({
    super.key,
    required this.title,
    this.text,
    required this.onImage,
    required this.onDetectorViewModeChanged,
  });

  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _clearImage,
            icon: const Icon(Icons.refresh),
            tooltip: '초기화',
          ),
          IconButton(
            onPressed: widget.onDetectorViewModeChanged,
            icon: const Icon(Icons.camera_alt),
            tooltip: '라이브 카메라',
          )
        ],
      ),
      body: _galleryBody(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: _isProcessing ? null : () => _getImage(ImageSource.gallery),
          heroTag: "gallery",
          tooltip: '갤러리에서 선택',
          backgroundColor: _isProcessing ? Colors.grey : null,
          child: _isProcessing
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Icon(Icons.photo_library),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: _isProcessing ? null : () => _getImage(ImageSource.camera),
          heroTag: "camera",
          tooltip: '사진 촬영',
          backgroundColor: _isProcessing ? Colors.grey : null,
          child: _isProcessing
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Icon(Icons.camera),
        ),
      ],
    );
  }

  Widget _galleryBody() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 이미지 표시 영역
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _image != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Image.file(
                      _image!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    if (_isProcessing)
                      Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                '얼굴 인식 중...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              )
                  : _buildPlaceholder(),
            ),
          ),
          const SizedBox(height: 16),
          // 결과 표시 영역
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.face,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '얼굴 인식 결과',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: widget.text != null
                          ? SelectableText(
                        widget.text!,
                        style: const TextStyle(fontSize: 14),
                      )
                          : _buildInstructions(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.face,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '얼굴이 포함된 이미지를\n선택하거나 촬영해주세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '📸 하단의 버튼으로 이미지 선택',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return const Text(
      '👤 얼굴 인식 기능:\n\n'
          '🔍 감지 기능:\n'
          '• 얼굴 위치 및 경계선\n'
          '• 실시간 얼굴 추적 (ID)\n'
          '• 얼굴 랜드마크 포인트\n'
          '• 얼굴 윤곽선\n\n'
          '😊 감정 분석:\n'
          '• 웃음 확률 측정\n'
          '• 감정 상태 표시\n\n'
          '👀 눈 상태 감지:\n'
          '• 눈 열림/닫힘 판별\n'
          '• 윙크 감지\n\n'
          '🔄 머리 방향:\n'
          '• 좌우 회전 각도\n'
          '• 머리 기울임 각도\n\n'
          '💡 팁:\n'
          '• 밝은 곳에서 촬영하세요\n'
          '• 얼굴이 선명하게 보이도록 하세요\n'
          '• 여러 얼굴도 동시에 인식 가능합니다',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey,
        fontStyle: FontStyle.italic,
        height: 1.4,
      ),
    );
  }

  void _clearImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> _getImage(ImageSource source) async {
    if (_isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _processFile(pickedFile.path);
      }
    } catch (e) {
      print('이미지 선택 중 오류 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '다시 시도',
              textColor: Colors.white,
              onPressed: () => _getImage(source),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processFile(String path) async {
    try {
      final inputImage = InputImage.fromFilePath(path);
      await widget.onImage(inputImage);
    } catch (e) {
      print('이미지 처리 중 오류 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 처리 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '다시 시도',
              textColor: Colors.white,
              onPressed: () => _processFile(path),
            ),
          ),
        );
      }
    }
  }
}