import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../base_url.dart';

class CommonFileDownloader {
  static Future<void> downloadAndOpen({
    required String urls,
    String? fileName,
    required BuildContext context,
  }) async {

   // var myUrl =  '$imageUrl/$urls';
    print("URLS :${urls}");
    var myUrl = urls;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⬇️ Download started...")),
      );

      // Get documents directory
      final dir = await getApplicationDocumentsDirectory();

      // Extract filename from URL (handles slashes and query parameters)
      String extractedName = Uri.decodeComponent(myUrl.split('/').last.split('?').first);

      // If user passes fileName, use that; else use extracted one
      final safeFileName = fileName ?? extractedName;

      final filePath = '${dir.path}/$safeFileName';
      final file = File(filePath);

      // Download the file
      final response = await http.get(Uri.parse(myUrl));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ File downloaded: $safeFileName")),
        );

        // Open file
        await OpenFilex.open(filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Download failed (Status: ${response.statusCode})")),
        );
      }
    } catch (e) {
      debugPrint("Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error downloading file")),
      );
    }
  }
}
