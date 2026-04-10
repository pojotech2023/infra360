
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/file_picker_helper.dart';
import '../../utils/res/colors.dart';
import '../../utils/res/spacing.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_button.dart';
import '../widgets/common_loader.dart';
import 'drawing_controller.dart';




class DrawingAddScreen extends StatefulWidget {
  const DrawingAddScreen({super.key});

  @override
  State<DrawingAddScreen> createState() => _DrawingAddScreenState();
}

class _DrawingAddScreenState extends State<DrawingAddScreen> {


    final List<File> attachments = [];




    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: CommonAppBar.appBar(
          title: "Add Drawing",
          onTap: () => Get.back(),
        ),
        body: GetBuilder<DrawingController>(
            builder: (controller) =>
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

 _supervisorForm()



                    ],
                  ),
                )),
      );
    }



    /// ✅ Supervisor Form
    Widget _supervisorForm() {
      return  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if (attachments.isNotEmpty || attachments.isNotEmpty)
            _attachmentsPreview(),
          VerticalSpacing.d5px(),
          OutlinedButton(
            onPressed: () => _showAttachmentOptions(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColor.textFieldBorder,
              side: BorderSide(color: AppColor.textFieldBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add),
                SizedBox(width: 8),
                Text("Upload Drawing Image / Video"),
              ],
            ),
          ),
          VerticalSpacing.d20px(),
          GetBuilder<DrawingController>(
            builder: (controller) =>
            controller.isLoading.value
                ? const Center(child: CommonLoader())
                : CommonButton(
              text: 'Submit',
              onTap: () {
                controller.drawingUpload(
                  files: attachments,

                );
              },
            ),
          ),
        ],
      );
    }



    /// ✅ Multiple Attachments Preview
    Widget _attachmentsPreview() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (attachments.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: attachments.map((file) {
                return _filePreview(file, isImage: true);
              }).toList(),
            ),

        ],
      );
    }

    /// ✅ Preview Widget for Single File
    Widget _filePreview(File file, {required bool isImage}) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isImage
                ? Image.file(file, fit: BoxFit.cover, width: 90, height: 90)
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
              onTap: () =>
                  setState(() {
                    if (isImage) {
                      attachments.remove(file);
                    } else {
                      attachments.remove(file);
                    }
                  }),
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


    /// ✅ File Picker Bottom Sheet
    void _showAttachmentOptions(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (_) =>
            SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: const Text('Pick Image'),
                    onTap: () async {
                      Navigator.pop(context);
                      final file = await FilePickerHelper.pickImage();
                      if (file != null) setState(() => attachments.add(file));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.videocam),
                    title: const Text('Pick Video'),
                    onTap: () async {
                      Navigator.pop(context);
                      final file = await FilePickerHelper.pickVideo();
                      if (file != null) setState(() => attachments.add(file));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Capture Photo'),
                    onTap: () async {
                      Navigator.pop(context);
                      final file = await FilePickerHelper.pickImage(
                          fromCamera: true);
                      if (file != null) setState(() => attachments.add(file));
                    },
                  ),
                ],
              ),
            ),
      );
    }
  }
