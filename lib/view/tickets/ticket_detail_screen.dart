import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../base_url.dart';
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
                    if (data.message != null) Text(data.message!),
                    if (data.attachment != null)
                      Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage('$imageUrl/${data.attachment!}'),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              debugPrint('Image load failed: $exception');
                            },
                          ),borderRadius:BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade100, width: 1,),
                        ),
                      ),
                    Text(    "${isAdmin ? "You" : data.senderType} | $formattedDate", style: const TextStyle(fontSize: 10)),
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
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.videocam)),
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
