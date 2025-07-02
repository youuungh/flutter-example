import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:market/main.dart';

class CameraExamplePage extends StatefulWidget {
  const CameraExamplePage({super.key});

  @override
  State<CameraExamplePage> createState() => _CameraExamplePageState();
}

class _CameraExamplePageState extends State<CameraExamplePage> {
  CameraController? cameraController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameraController = CameraController(cameras[0], ResolutionPreset.high);
      await cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('카메라 초기화 실패: $e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cameraController?.value.isInitialized ?? false
          ? CameraPreview(cameraController!)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
