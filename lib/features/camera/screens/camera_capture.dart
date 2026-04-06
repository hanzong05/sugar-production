import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/camera_controller.dart';
import '../widgets/camera_widgets.dart';

class CameraCaptureScreen extends StatefulWidget {
  final String title;
  final String description;

  const CameraCaptureScreen({
    super.key,
    this.title = 'Capture Proof',
    this.description = 'Take a photo of the delivery',
  });

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  late final CameraCaptureController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = CameraCaptureController();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _ctrl.openCamera(context),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Loading — camera opening or no image yet
    if (_ctrl.isCapturing || _ctrl.capturedImage == null) {
      return const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── Full-screen image preview ──────────────────
            Positioned.fill(
              child: Image.file(_ctrl.capturedImage!, fit: BoxFit.contain),
            ),

            // ── Top bar ───────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CameraTopBar(
                title: widget.title,
                description: widget.description,
                onClose: () => Navigator.pop(context),
              ),
            ),

            // ── Bottom controls ───────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CameraBottomControls(
                onRetake: () => _ctrl.retake(context),
                onConfirm: () => _ctrl.confirm(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
