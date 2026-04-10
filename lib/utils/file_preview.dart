import 'dart:io';
import 'package:flutter/material.dart';

/// ✅ Reusable preview widget for a single file (image or video)
class FilePreview extends StatelessWidget {
  final File file;
  final bool isImage;
  final VoidCallback? onRemove; // callback when close icon tapped

  const FilePreview({
    Key? key,
    required this.file,
    required this.isImage,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isImage
              ? Image.file(
            file,
            fit: BoxFit.cover,
            width: 90,
            height: 90,
          )
              : Container(
            width: 90,
            height: 90,
            color: Colors.grey[300],
            child: const Icon(Icons.videocam, size: 30),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove, // use callback instead of setState
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
