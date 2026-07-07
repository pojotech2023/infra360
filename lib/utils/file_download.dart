import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../base_url.dart';
import '../service/shared_preference_service.dart';

class CommonFileDownloader {
  static Future<void> downloadAndOpen({
    required String urls,
    String? fileName,
    required BuildContext context,
  }) async {
    print("URLS :${urls}");
    var myUrl = urls;
    
    // Capture the ScaffoldMessenger before any async gap
    final messenger = ScaffoldMessenger.of(context);

    try {
      messenger.showSnackBar(
        const SnackBar(content: Text("⬇️ Download started...")),
      );

      // Get documents directory
      final dir = await getApplicationDocumentsDirectory();

      // Extract filename from URL (handles slashes and query parameters)
      String extractedName = Uri.decodeComponent(myUrl.split('/').last.split('?').first);

      // If user passes fileName, use that; else use extracted one
      String safeFileName = fileName ?? extractedName;

      // Build request with auth token
      final token = PreferenceUtils().getSessionToken();
      final request = http.Request('GET', Uri.parse(myUrl));
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Detect extension from Content-Type if file has no extension
        if (!safeFileName.contains('.')) {
          final contentType = response.headers['content-type'] ?? '';
          if (contentType.contains('pdf')) {
            safeFileName = '$safeFileName.pdf';
          } else if (contentType.contains('spreadsheetml') || contentType.contains('excel')) {
            safeFileName = '$safeFileName.xlsx';
          } else if (contentType.contains('csv')) {
            safeFileName = '$safeFileName.csv';
          } else if (contentType.contains('zip')) {
            safeFileName = '$safeFileName.zip';
          } else {
            safeFileName = '$safeFileName.pdf'; // fallback
          }
        }

        final filePath = '${dir.path}/$safeFileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        messenger.showSnackBar(
          SnackBar(content: Text("✅ File downloaded: $safeFileName")),
        );

        // Open file
        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          messenger.showSnackBar(
            SnackBar(content: Text("⚠️ File saved but could not open: ${result.message}")),
          );
        }
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text("❌ Download failed (Status: ${response.statusCode})")),
        );
      }
    } catch (e) {
      debugPrint("Download error: $e");
      messenger.showSnackBar(
        const SnackBar(content: Text("❌ Error downloading file")),
      );
    }
  }
}
