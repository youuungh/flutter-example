import 'package:flutter/material.dart';
import 'package:mlkit/barcode_scanner/barcode_scanner_page.dart';
import 'package:mlkit/text_recognition/text_recognition_page.dart';
import 'package:mlkit/object_detection/object_detection_page.dart';
import 'package:mlkit/image_labeling/image_labeling_page.dart';
import 'package:mlkit/face_detection/face_detection_page.dart';
import 'package:mlkit/digital_ink_recognition/digital_ink_recognition_page.dart';
import 'package:mlkit/pose_detection/pose_detection_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MLKit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MLKitMenuPage(),
    );
  }
}

class MLKitMenuPage extends StatelessWidget {
  const MLKitMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('MLKit'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildFeatureCard(
              context,
              title: '바코드 스캐너',
              icon: Icons.qr_code_scanner,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerPage(),
                  ),
                );
              },
            ),
            _buildFeatureCard(
              context,
              title: '텍스트 인식',
              icon: Icons.text_fields,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TextRecognitionPage(),
                  ),
                );
              },
            ),
            _buildFeatureCard(
              context,
              title: '얼굴 인식',
              icon: Icons.face,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FaceDetectionPage(),
                  ),
                );
              },
            ),
            _buildFeatureCard(
              context,
              title: '객체 감지',
              icon: Icons.search,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ObjectDetectionPage(),
                  ),
                );
              },
            ),
            _buildFeatureCard(
              context,
              title: '이미지 라벨링',
              icon: Icons.label,
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImageLabelingPage(),
                  ),
                );
              },
            ),
            _buildFeatureCard(
              context,
              title: '디지털 잉크 인식',
              icon: Icons.edit,
              color: Colors.deepOrange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DigitalInkRecognitionPage(),
                  ),
                );
              },
            ),
            _buildFeatureCard(
              context,
              title: '자세 인식',
              icon: Icons.accessibility_new,
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PoseDetectionPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}