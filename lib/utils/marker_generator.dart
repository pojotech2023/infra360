import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerGenerator {
  static Future<BitmapDescriptor> createCustomMarkerBitmap(String title) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    
    const double width = 380.0;
    const double height = 180.0;
    
    // Draw background bubble
    final Paint paint = Paint()..color = const Color(0xFF00897B);
    final Rect rect = const Rect.fromLTWH(0.0, 0.0, width, 90.0);
    final RRect roundedRect = RRect.fromRectAndRadius(rect, const Radius.circular(18.0));
    canvas.drawRRect(roundedRect, paint);

    // Draw little triangle at the bottom of the bubble
    final Path path = Path();
    path.moveTo(width / 2 - 18, 90);
    path.lineTo(width / 2, 130);
    path.lineTo(width / 2 + 18, 90);
    path.close();
    canvas.drawPath(path, paint);

    // Draw standard pin circle below the triangle (optional, to represent the exact point)
    final Paint circlePaint = Paint()..color = const Color(0xFFD32F2F);
    canvas.drawCircle(const Offset(width / 2, 145), 15, circlePaint);
    final Paint innerCirclePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(width / 2, 145), 6, innerCirclePaint);

    // Draw text inside the bubble
    final TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    );
    painter.text = TextSpan(
      text: title,
      style: const TextStyle(
        fontSize: 34.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
    painter.layout(maxWidth: width - 30);
    
    // Center text vertically and horizontally in the bubble
    painter.paint(
      canvas,
      Offset((width - painter.width) / 2, (90.0 - painter.height) / 2),
    );

    final ui.Image img = await pictureRecorder.endRecording().toImage(width.toInt(), height.toInt());
    final ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}
