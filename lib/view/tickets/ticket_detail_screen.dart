import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../base_url.dart';
import '../../utils/file_download.dart';
import '../../utils/file_picker_helper.dart';
import '../../utils/text_form_style.dart';
import '../widgets/common_app_bar.dart';
import 'ticket_detail_controller.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final TicketDetailController controller = Get.put(TicketDetailController());
  final TextEditingController chatEditingController = TextEditingController();

  /// Store selected attachment (single file)
  File? attachment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: "Tickets Details",
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: GetBuilder<TicketDetailController>(
          builder: (_) {
            if (controller.ticketDetailList.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                _chatHistory(),
                _messageBox(context),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Chat list
  Widget _chatHistory() {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemCount: controller.ticketDetailList.length,
        itemBuilder: (context, index) {
          final data = controller.ticketDetailList[index];
          final dateTime = DateTime.parse(data.createdAt!).toLocal();
          final formattedDate = DateFormat("dd/MM/yyyy hh:mm a").format(dateTime);
          final isAdmin = data.senderType!.toLowerCase() ==
              controller.userDetails.data!.role!.toLowerCase();

          return Align(
            alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
            child: Card(
              color: isAdmin ? Colors.grey[300] : Colors.blue[200],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.message != null && data.message!.isNotEmpty) 
                      Text(data.message!),
                    if (data.attachment != null && data.attachment!.isNotEmpty)
                      Builder(builder: (context) {
                        final String attachment = data.attachment!;
                        final isImage = attachment.toLowerCase().endsWith('.jpg') ||
                            attachment.toLowerCase().endsWith('.jpeg') ||
                            attachment.toLowerCase().endsWith('.png');
                        final fullUrl = '$imageUrl/$attachment';

                        if (isImage) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => _FullScreenImagePage(
                                    imageUrl: fullUrl,
                                    tag: 'ticket_img_${attachment}_${data.id ?? UniqueKey()}',
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'ticket_img_${attachment}_${data.id ?? UniqueKey()}',
                              child: Container(
                                width: 150,
                                height: 150,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(fullUrl),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      debugPrint('Image load failed: $exception');
                                    },
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade100, width: 1),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () {
                              CommonFileDownloader.downloadAndOpen(
                                urls: fullUrl,
                                context: context,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.insert_drive_file, color: Colors.blue, size: 30),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      attachment.split('/').last,
                                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                    Text(
                      "${isAdmin ? "You" : (data.senderName != null ? '${data.senderName} (${data.senderType})' : data.senderType)} | $formattedDate",
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Message input + attachment box
  Widget _messageBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (attachment != null) _attachmentPreview(),
          const SizedBox(height: 10),
          TextFormField(
            controller: chatEditingController,
            decoration: textBoxDecoration(
              hint: "Type a message...",
              suffixIcon: Obx(() {
                return controller.isMsgLoading.value
                    ? const CircularProgressIndicator()
                    : IconButton(
                  onPressed: () {
                    if (chatEditingController.text.isNotEmpty || attachment != null) {
                      controller.sendMessage(
                        message: chatEditingController.text,
                        file: attachment,
                      );
                      chatEditingController.clear();
                      setState(() => attachment = null);
                    }
                  },
                  icon: const Icon(Icons.send),
                );
              }),
              prefixIcon: IconButton(
                onPressed: () => _showAttachmentOptions(context),
                icon: const Icon(Icons.attach_file),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Attachment preview
  Widget _attachmentPreview() {
    final isImage = attachment!.path.endsWith('.jpg') ||
        attachment!.path.endsWith('.jpeg') ||
        attachment!.path.endsWith('.png');

    return SizedBox(
      height: 90,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isImage
                ? Image.file(attachment!, fit: BoxFit.cover, width: 90, height: 90)
                : Container(
              width: 90,
              height: 90,
              color: Colors.grey[200],
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.insert_drive_file, size: 30),
                  const SizedBox(height: 4),
                  Text(
                    attachment!.path.split('/').last,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () => setState(() => attachment = null),
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
      ),
    );
  }

  /// Attachment bottom sheet
  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Pick Document'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await FilePickerHelper.pickDocument();
                  if (file != null) setState(() => attachment = file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Pick Image'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await FilePickerHelper.pickImage();
                  if (file != null) setState(() => attachment = file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Pick Video'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await FilePickerHelper.pickVideo();
                  if (file != null) setState(() => attachment = file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Capture Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await FilePickerHelper.pickImage(fromCamera: true);
                  if (file != null) setState(() => attachment = file);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Full-screen image viewer with pinch-to-zoom and hero animation
class _FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const _FullScreenImagePage({required this.imageUrl, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: Hero(
            tag: tag,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
              errorBuilder: (context, error, _) => const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.white54, size: 60),
                  SizedBox(height: 12),
                  Text('Failed to load image',
                      style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
