import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// ══════════════════════════════════════════════════════════════════
//  Signature Controller
// ══════════════════════════════════════════════════════════════════

class SignatureController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];
  final List<Offset> _currentStroke = [];

  List<List<Offset>> get strokes => _strokes;
  List<Offset> get currentStroke => _currentStroke;

  bool get isSigned => _strokes.isNotEmpty || _currentStroke.isNotEmpty;

  void addPoint(Offset point) {
    _currentStroke.add(point);
    notifyListeners();
  }

  void endStroke() {
    if (_currentStroke.isNotEmpty) {
      _strokes.add(List.from(_currentStroke));
      _currentStroke.clear();
    }
  }

  void clear() {
    _strokes.clear();
    _currentStroke.clear();
    notifyListeners();
  }

  Future<Uint8List?> capture(GlobalKey repaintKey) async {
    final boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}

// ══════════════════════════════════════════════════════════════════
//  Signature Painter
// ══════════════════════════════════════════════════════════════════

class SignaturePainter extends CustomPainter {
  final SignatureController controller;
  final Color inkColor;

  SignaturePainter(this.controller, {required this.inkColor})
    : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = inkColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in controller.strokes) {
      if (stroke.length > 1) {
        for (int i = 0; i < stroke.length - 1; i++) {
          canvas.drawLine(stroke[i], stroke[i + 1], paint);
        }
      }
    }

    if (controller.currentStroke.length > 1) {
      for (int i = 0; i < controller.currentStroke.length - 1; i++) {
        canvas.drawLine(
          controller.currentStroke[i],
          controller.currentStroke[i + 1],
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter old) => true;
}
