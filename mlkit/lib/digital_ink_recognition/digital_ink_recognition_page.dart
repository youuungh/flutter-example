import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class DigitalInkRecognitionPage extends StatefulWidget {
  const DigitalInkRecognitionPage({super.key});

  @override
  State<DigitalInkRecognitionPage> createState() => _DigitalInkRecognitionPageState();
}

class _DigitalInkRecognitionPageState extends State<DigitalInkRecognitionPage> {
  final DigitalInkRecognizerModelManager _modelManager =
  DigitalInkRecognizerModelManager();
  var _language = "en";
  var _digitalInkRecognizer = DigitalInkRecognizer(languageCode: 'en');

  final _languages = ["en", 'ko', 'ja', 'zh-Hani'];
  String _recognizedText = '';

  final Ink _ink = Ink();
  List<StrokePoint> _points = [];

  @override
  void dispose() {
    _digitalInkRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("디지털 잉크 인식"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 언어 선택 및 모델 관리 섹션
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          '언어 선택: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _language,
                            isExpanded: true,
                            items: _languages
                                .map(
                                  (e) => DropdownMenuItem<String>(
                                value: e,
                                child: Text(_getLanguageName(e)),
                              ),
                            )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _language = v;
                                  _digitalInkRecognizer.close();
                                  _digitalInkRecognizer =
                                      DigitalInkRecognizer(languageCode: _language);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final value =
                              await _modelManager.isModelDownloaded(_language);
                              final result = value ? '다운로드 되어있음' : '다운로드된 모델 없음';
                              _showSnackBar(result);
                            },
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text("모델 확인"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final value = await _modelManager.downloadModel(_language);
                              final result = value ? '다운로드 성공' : '다운로드 실패';
                              _showSnackBar(result);
                            },
                            icon: const Icon(Icons.download),
                            label: const Text("다운로드"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final value = await _modelManager.deleteModel(_language);
                              final result = value ? '삭제 성공' : '삭제 실패';
                              _showSnackBar(result);
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text("삭제"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 그리기 영역 제목
            const Text(
              "손글씨를 써보세요",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),

            // 그리기 캔버스
            Expanded(
              child: Card(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GestureDetector(
                    onPanStart: (details) {
                      _ink.strokes.add(Stroke());
                    },
                    onPanEnd: (details) {
                      _points.clear();
                      setState(() {});
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _points = List.from(_points)
                          ..add(
                            StrokePoint(
                                x: details.localPosition.dx,
                                y: details.localPosition.dy,
                                t: DateTime.now().millisecondsSinceEpoch),
                          );
                        if (_ink.strokes.isNotEmpty) {
                          _ink.strokes.last.points = _points.toList();
                        }
                      });
                    },
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: Signature(ink: _ink),
                    ),
                  ),
                ),
              ),
            ),

            // 인식 결과 표시
            if (_recognizedText.isNotEmpty)
              Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "인식 결과:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        child: SingleChildScrollView(
                          child: Text(
                            _recognizedText,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 하단 버튼들
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final candidates =
                          await _digitalInkRecognizer.recognize(_ink);
                          _recognizedText = "";
                          for (final candidate in candidates) {
                            _recognizedText += "${candidate.text}\n";
                          }
                          setState(() {});
                        } catch (e) {
                          _showSnackBar("인식 실패: ${e.toString()}");
                        }
                      },
                      icon: const Icon(Icons.search),
                      label: const Text("인식하기"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _ink.strokes.clear();
                          _points.clear();
                          _recognizedText = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text("지우기"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return '영어 (English)';
      case 'ko':
        return '한국어 (Korean)';
      case 'ja':
        return '일본어 (Japanese)';
      case 'zh-Hani':
        return '중국어 (Chinese)';
      default:
        return code;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class Signature extends CustomPainter {
  final Ink ink;

  Signature({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (final stroke in ink.strokes) {
      for (var i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        canvas.drawLine(
          Offset(p1.x.toDouble(), p1.y.toDouble()),
          Offset(p2.x.toDouble(), p2.y.toDouble()),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}