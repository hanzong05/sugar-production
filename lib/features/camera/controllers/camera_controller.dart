import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sugar_production/core/theme/app_theme.dart';

class CameraCaptureController extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  File? capturedImage;
  bool isCapturing = false;

  Future<void> openCamera(BuildContext context) async {
    isCapturing = true;
    notifyListeners();

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        capturedImage = File(photo.path);
      } else {
        if (context.mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing camera: $e'),
            backgroundColor: AppTheme.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            margin: const EdgeInsets.all(12),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      isCapturing = false;
      notifyListeners();
    }
  }

  void retake(BuildContext context) {
    capturedImage = null;
    notifyListeners();
    openCamera(context);
  }

  void confirm(BuildContext context) {
    if (capturedImage != null) Navigator.pop(context, capturedImage);
  }
}
