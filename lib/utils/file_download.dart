import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../base_url.dart';
import '../service/shared_preference_service.dart';
import '../view/widgets/toast.dart';

class CommonFileDownloader {
  static Future<bool> downloadAndOpen({
    required String urls,
    String? fileName,
    required BuildContext context,
    bool showToast = true,
  }) async {
    print("URLS :${urls}");
    var myUrl = urls;
    
    try {
      if (showToast) {
        showToastMessage("⬇️ Download started...");
      }

      // Get temporary directory so other apps (like PDF viewers) can read the file
      final dir = await getTemporaryDirectory();

      // Extract filename from URL (handles slashes and query parameters)
      String extractedName = Uri.decodeComponent(myUrl.split('/').last.split('?').first);

      // If user passes fileName, use that; else use extracted one
      String safeFileName = fileName ?? extractedName;

      // Build request with auth token, ensuring URL is properly encoded for spaces
      final token = PreferenceUtils().getSessionToken();
      final encodedUrl = Uri.encodeFull(myUrl);
      final request = http.Request('GET', Uri.parse(encodedUrl));
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

        showToastMessage("✅ File downloaded: $safeFileName");

        // Open file
        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          showToastMessage("⚠️ File saved but could not open: ${result.message}");
        }
        return true;
      } else {
        if (showToast) {
          showToastMessage("❌ Download failed (Status: ${response.statusCode})");
        }
        return false;
      }
    } catch (e) {
      debugPrint("Download error: $e");
      if (showToast) {
        showToastMessage("❌ Error downloading file");
      }
      return false;
    }
  }
}
