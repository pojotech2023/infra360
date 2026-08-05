import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base_url.dart';
import '../../model/drawing_model.dart';
import '../../utils/app_text_style.dart';
import '../../utils/file_picker_helper.dart';
import '../../utils/res/colors.dart';
import '../../utils/url_helper.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_button.dart';
import '../widgets/common_loader.dart';
import '../widgets/log_out.dart';
import 'drawing_controller.dart';
import 'drawing_detail_screen.dart';

class DrawingListScreen extends StatefulWidget {
  const DrawingListScreen({super.key});

  @override
  State<DrawingListScreen> createState() => _DrawingListScreenState();
}

class _DrawingListScreenState extends State<DrawingListScreen> {
  final DrawingController controller = Get.put(DrawingController());

  // State for file uploads
  final List<File> attachments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CommonAppBar.appBar(
        title: "Drawing",
        onTap: () {
          Get.back();
        },
      ),
      body: SafeArea(
        child: GetBuilder<DrawingController>(
          builder: (controller) {
            if (controller.isLoading.value && controller.drawingList.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Drawing Update Form ──
                  if (controller.userDetails.data?.role?.toLowerCase() == 'admin')
                    _buildUploadForm(context),

                  const SizedBox(height: 24),

                  // ── Uploaded Drawings Title ──
                  Text(
                    "Uploaded Drawings",
                    style: AppTextStyle.textMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Uploaded Drawings Table/List ──
                  _buildDrawingsTable(context, controller),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUploadForm(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Icon(Icons.upload_file, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Drawing Update Form",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
          
          // Form Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Upload Files",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 12),
                
                // Attachments Preview
                if (attachments.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: attachments.map((file) => _filePreview(file)).toList(),
                  ),
                if (attachments.isNotEmpty) const SizedBox(height: 12),

                // Add More / Choose File Button
                OutlinedButton.icon(
                  onPressed: () => _showAttachmentOptions(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(attachments.isEmpty ? "Choose Files" : "Add More"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                    side: BorderSide(color: Colors.blue.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Actions: Submit / Cancel
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          attachments.clear();
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.indigo.shade400,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (attachments.isEmpty) {
                                Get.snackbar("Error", "Please select at least one file");
                                return;
                              }
                              controller.drawingUpload(files: attachments).then((_) {
                                setState(() {
                                  attachments.clear();
                                });
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text("Submit", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filePreview(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png'].contains(extension);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isImage
              ? Image.file(file, fit: BoxFit.cover, width: 70, height: 70)
              : Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          extension == 'pdf'
                              ? Icons.picture_as_pdf
                              : Icons.insert_drive_file,
                          color: Colors.grey.shade600,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          extension.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: InkWell(
            onTap: () {
              setState(() {
                attachments.remove(file);
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _handlePickedFile(File? file) async {
    if (file != null) {
      final sizeInBytes = await file.length();
      if (sizeInBytes > 2 * 1024 * 1024) {
        Get.snackbar("Error", "File size must not exceed 2 MB");
      } else {
        setState(() => attachments.add(file));
      }
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.file_upload, color: Colors.blue),
              title: const Text('Choose File (Image, PDF, XLS, DWG)'),
              onTap: () async {
                Navigator.pop(context);
                final file = await FilePickerHelper.pickDrawingFile();
                _handlePickedFile(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Capture Photo'),
              onTap: () async {
                Navigator.pop(context);
                final file = await FilePickerHelper.pickImage(fromCamera: true);
                _handlePickedFile(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawingsTable(BuildContext context, DrawingController controller) {
    final list = controller.drawingList;
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              "No drawings available.",
              style: AppTextStyle.textRegular15.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E3238), // Dark color matching web UI header
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 40, child: Text("S.NO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(child: Text("DRAWING", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                SizedBox(width: 110, child: Text("ACTION", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
          ),
          
          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            primary: false,
            itemCount: list.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final item = list[index];
              return _buildTableRow(context, item, index + 1, controller);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, DrawingData item, int index, DrawingController controller) {
    final imageUrl = UrlHelper.getFullImageUrl(item.drawingViewUrl);
    final ext = imageUrl.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
    final isPdf = ext == 'pdf';
    final isDoc = ['xls', 'xlsx', 'dwg', 'doc', 'docx'].contains(ext);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: index.isOdd ? Colors.grey.shade50 : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // S.NO
          SizedBox(
            width: 40,
            child: Text(
              "$index",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
            ),
          ),
          
          // DRAWING
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isImage) {
                  Get.to(() => DrawingDetailScreen(data: item));
                } else {
                  controller.downloadDrawing(item, context);
                }
              },
              child: isImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        imageUrl,
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Icon(
                          isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                          color: isPdf ? Colors.red : Colors.blueGrey,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "View ${ext.toUpperCase()}",
                          style: TextStyle(
                              color: Colors.blue.shade600,
                              decoration: TextDecoration.underline,
                              fontSize: 12),
                        ),
                      ],
                    ),
            ),
          ),
          
          // ACTION — vertical column so full text always fits
          SizedBox(
            width: 110,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _actionButton(
                  icon: Icons.download,
                  label: 'Download',
                  color: Colors.blue.shade600,
                  onTap: () => controller.downloadDrawing(item, context),
                ),
                const SizedBox(height: 4),
                _actionButton(
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  color: Colors.green.shade500,
                  onTap: () => controller.shareViaWhatsApp(item),
                ),
                const SizedBox(height: 4),
                _actionButton(
                  icon: Icons.delete,
                  label: 'Delete',
                  color: Colors.red.shade500,
                  onTap: () {
                    deleteDialog(context, () {
                      controller.deleteDrawing(item.drawingId.toString());
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 11),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}