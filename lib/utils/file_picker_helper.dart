import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick Image from gallery or camera
  static Future<File?> pickImage({bool fromCamera = false}) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70, // reduce size
      );
      if (pickedFile != null) return File(pickedFile.path);
    } catch (e) {
      print('Error picking image: $e');
    }
    return null;
  }

  /// Pick Video from gallery or camera
  static Future<File?> pickVideo({bool fromCamera = false}) async {
    try {
      final pickedFile = await _picker.pickVideo(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (pickedFile != null) return File(pickedFile.path);
    } catch (e) {
      print('Error picking video: $e');
    }
    return null;
  }

  /// Pick any file (PDF, DOC, etc.)
  static Future<File?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }

    return null;
  }
}
