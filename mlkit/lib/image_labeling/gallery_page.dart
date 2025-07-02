import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _image = null;
              });
            },
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _getImage(ImageSource.gallery),
            heroTag: "gallery",
            tooltip: '갤러리에서 선택',
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => _getImage(ImageSource.camera),
            heroTag: "camera",
            tooltip: '사진 촬영',
            child: const Icon(Icons.camera),
          ),
        ],
      ),
    );
  }

  Widget _galleryBody() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
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
                child: Image.file(
                  _image!,
                  fit: BoxFit.contain,
                ),
              )
                  : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.label,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '분류할 이미지를\n선택하거나 촬영해주세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
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
                        Icons.label,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '이미지 분류',
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
                          : const Text(
                        '이미지 라벨링 결과가 여기에 표시됩니다.\n\n이미지를 분석하면:\n• 감지된 라벨 수\n• 각 라벨의 신뢰도 점수\n• 상위 분류 결과\n• 신뢰도별 색상 구분\n이 표시됩니다.\n\n🟢 높은 신뢰도 (80% 이상)\n🟡 보통 신뢰도 (60-80%)\n🔴 낮은 신뢰도 (50-60%)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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

  Future _processFile(String path) async {
    try {
      final inputImage = InputImage.fromFilePath(path);
      widget.onImage(inputImage);
    } catch (e) {
      print('이미지 처리 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 처리 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future _getImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _processFile(pickedFile.path);
      }
    } catch (e) {
      print('이미지 선택 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}