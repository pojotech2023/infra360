import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/video_player.dart';

import '../../base_url.dart';
import '../../model/checklist_model.dart';
import '../../utils/app_text_style.dart';
import '../../utils/const_data.dart';
import '../../utils/file_picker_helper.dart';
import '../../utils/res/colors.dart';
import '../../utils/res/spacing.dart';
import '../../utils/text_form_style.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_button.dart';
import '../widgets/common_loader.dart';
import '../../utils/file_download.dart';
import 'check_list_controller.dart';

class ChecklistDetailScreen extends StatefulWidget {
  const ChecklistDetailScreen({
    super.key,
    required this.siteID,
    required this.tasks,
    this.isShowFrom = true,
  });

  final int siteID;
  final Tasks tasks;
  final bool isShowFrom;

  @override
  State<ChecklistDetailScreen> createState() => _ChecklistDetailScreenState();
}

class _ChecklistDetailScreenState extends State<ChecklistDetailScreen> {
  final TextEditingController supervisorRemarkController = TextEditingController();
  final TextEditingController supervisorViewRemarkController = TextEditingController();
  final TextEditingController adminRemarkController = TextEditingController();

  final GlobalKey<FormState> supervisorFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> adminFormKey = GlobalKey<FormState>();

  final List<File> attachments = [];


  @override
  void dispose() {
    supervisorRemarkController.dispose();
    adminRemarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: "Check List Detail",
        onTap: () => Get.back(),
      ),
      body: GetBuilder<CheckListController>(
          builder: (controller) =>
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [




                    controller.userDetails.data!.role!.toLowerCase() ==
                        'supervisor' ?    widget.tasks.status == -1  ?  _supervisorForm() :

                    widget.tasks.status == 2 ? Column(children: [Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red.shade100
                      ),
                      child: _ticketView(),
                    ),SizedBox(height: 40,), _supervisorForm() ],) :
                    _ticketView(): SizedBox(),
                    const SizedBox(height: 20),
                    controller.userDetails.data!.role!.toLowerCase() == 'admin'
                        ?   (widget.tasks.status == -1 || widget.tasks.status ==1) ?  _ticketView(): _adminForm()
                        : SizedBox(),


                  ],
                ),
              )),
    );
  }


  Widget _ticketView(){


    var setText = widget.tasks.supervisorRemarks ??'';
    supervisorViewRemarkController.text = setText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //
        // if(widget.tasks.status == 2){
        //   Text("Supervisor Remark",
        //       style: AppTextStyle.textFieldHeadingStyle),
        //   VerticalSpacing.d5px(),
        //   Text(setText),
        //
        // }


        Text("Supervisor Remark",
            style: AppTextStyle.textFieldHeadingStyle),
        VerticalSpacing.d5px(),
        TextFormField(
          controller: supervisorViewRemarkController,
          minLines: 3,
          maxLines: 5,
          readOnly: true,
          decoration: textBoxDecoration(hint: "Enter your remarks"),
        ),

        VerticalSpacing.d15px(),
        Text("Supervisor Attached",
            style: AppTextStyle.textFieldHeadingStyle),
        VerticalSpacing.d5px(),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if(widget.tasks.images != null)
            ...widget.tasks.images!.map((img) => img.isNotEmpty ? _imagePreview(img) : const SizedBox()),
          if(widget.tasks.videos != null)
            ...widget.tasks.videos!.map((vid) => vid.isNotEmpty ? _videoPreview(vid) : const SizedBox()),
        ],
      ),
        VerticalSpacing.d15px(),
        widget.tasks.status == 1  ||  widget.tasks.status == 2  ?  Text("Admin Status  : ${widget.tasks.statusLabel}",
            style: AppTextStyle.textFieldHeadingStyle): SizedBox(),

        widget.tasks.status == 1  ||  widget.tasks.status == 2  ?  Text("Admin Remarks  : ${widget.tasks.adminRemarks}",
            style: AppTextStyle.textFieldHeadingStyle): SizedBox(),

        widget.tasks.status == 1  ||  widget.tasks.status == 2  ?  Text("${widget.tasks.statusLabel} By  : ${widget.tasks.updateBy}",
            style: AppTextStyle.textFieldHeadingStyle): SizedBox(),
      ],
    );

  }

  /// ✅ Supervisor Form
  Widget _supervisorForm() {

    var setText = widget.tasks.supervisorRemarks ??'';
    supervisorRemarkController.text = setText;
    return Form(
      key: supervisorFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Remark", style: AppTextStyle.textFieldHeadingStyle),
          VerticalSpacing.d5px(),
          TextFormField(
            controller: supervisorRemarkController,
            minLines: 3,
            maxLines: 5,
            decoration: textBoxDecoration(hint: "Enter your remarks"),
            validator: (text) =>
            text == null || text.isEmpty
                ? 'Required'
                : null,
          ),
          VerticalSpacing.d15px(),
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
                Text("Upload Task Image / Video"),
              ],
            ),
          ),
          VerticalSpacing.d20px(),
          GetBuilder<CheckListController>(
            builder: (controller) =>
            controller.isLoading.value
                ? const Center(child: CommonLoader())
                : CommonButton(
              text: 'Submit',
              onTap: () {
                if (supervisorFormKey.currentState!.validate()) {
                  print("🚀 Submitting checklist with ${attachments.length} attachments");
                  controller.supervisorAprroved(
                    tasks:widget.tasks,
                    taskId: widget.tasks.taskId ?? 0,
                    remarks: supervisorRemarkController.text,
                    files: attachments,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Admin Form
  Widget _adminForm() {

    var setText = widget.tasks.supervisorRemarks ??'';
    supervisorRemarkController.text = setText;

    return GetBuilder<CheckListController>(
      builder: (controller) {
       return Form(
          key: adminFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text("Supervisor Remark",
                  style: AppTextStyle.textFieldHeadingStyle),
              VerticalSpacing.d5px(),
              TextFormField(
                controller: supervisorRemarkController,
                minLines: 3,
                maxLines: 5,
                readOnly: true,
                decoration: textBoxDecoration(hint: "Enter your remarks"),
              ),

              VerticalSpacing.d15px(),
              Text("Supervisor Attached",
                  style: AppTextStyle.textFieldHeadingStyle),
              VerticalSpacing.d5px(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if(widget.tasks.images != null)
                    ...widget.tasks.images!.map((img) => img.isNotEmpty ? _imagePreview(img) : const SizedBox()),
                  if(widget.tasks.videos != null)
                    ...widget.tasks.videos!.map((vid) => vid.isNotEmpty ? _videoPreview(vid) : const SizedBox()),
                ],
              ),
              VerticalSpacing.d15px(),

              Text("Checklist Request",
                  style: AppTextStyle.textFieldHeadingStyle),
              const SizedBox(height: 5),
              DropdownButtonFormField2<String>(
                isExpanded: true,
                value: controller.selectedreqest,
                decoration: dropDownBoxDecoration(),
                hint: Text(
                    'Checklist Request', style: AppTextStyle.textHintText),
                items: ConstantData.approveRequest
                    .map((item) =>
                    DropdownMenuItem<String>(
                      value: item,
                      child: Text(capitalize(item),
                          style: AppTextStyle.textFieldHeadingStyle),
                    ))
                    .toList(),
                validator: (value) =>
                value == null
                    ? 'Select Checklist Request'
                    : null,
                onChanged: (value) => controller.selectedreqest = value,
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),
              Text("Remark", style: AppTextStyle.textFieldHeadingStyle),
              const SizedBox(height: 5),
              TextFormField(
                controller: adminRemarkController,
                minLines: 3,
                maxLines: 5,
                decoration: textBoxDecoration(hint: "Enter your remarks"),
                validator: (text) =>
                text == null || text.isEmpty
                    ? 'Required'
                    : null,
              ),
              VerticalSpacing.d20px(),
              controller.isLoading.value
                  ? const Center(child: CommonLoader())
                  : CommonButton(
                text: 'Submit',
                onTap: () {
                  if (adminFormKey.currentState!.validate()) {
                    controller.adminAprroved(
                      tasks:widget.tasks,
                      taskId: widget.tasks.taskId ?? 0,
                      remarks: adminRemarkController.text,
                    );
                  }
                },
              ),
            ],
          ),
        );
      }
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
              final ext = file.path.split('.').last.toLowerCase();
              final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
              return _filePreview(file, isImage: isImage);
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

  /// ✅ Image Preview (from network)
  Widget _imagePreview(String url) {
    String fullImageUrl = '$imageUrl/$url';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showZoomedImage(fullImageUrl),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                fullImageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  print("❌ IMAGE LOAD FAILED → $error");
                  return placeHolder();
                },
              ),
            ),
          ),
        ),
        VerticalSpacing.d5px(),
        ElevatedButton.icon(
          onPressed: () {
            CommonFileDownloader.downloadAndOpen(
              urls: fullImageUrl,
              context: context,
            );
          },
          icon: const Icon(Icons.download, size: 16, color: Colors.white),
          label: const Text("Download", style: TextStyle(fontSize: 12, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ],
    );
  }

  void _showZoomedImage(String imageUrl) {
    Get.to(() => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text("Error loading image", style: TextStyle(color: Colors.white)),
              );
            },
          ),
        ),
      ),
    ));
  }

  /// ✅ Image Preview (from network)
  Widget _videoPreview(String url) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
    onTap: () {
  Get.to(()=>NetworkVideoPlayer(videoUrl: url));
    },
    child: Container(
    decoration: BoxDecoration(
    color: Colors.grey.shade900,
    borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(
    child: Icon(
    Icons.play_circle_fill,
    color: Colors.white,
    size: 60,
    shadows: [
    Shadow(color: Colors.black54, blurRadius: 8),
    ],
    ),
    ),
    )),
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
                    final files = await FilePickerHelper.pickMultiImage();
                    if (files.isNotEmpty) {
                      setState(() => attachments.addAll(files));
                    }
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

  Widget placeHolder(){
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_a_photo, size: 30, color: Colors.grey),
        VerticalSpacing.d5px(),
        const Text(
          'Add Profile Image',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
