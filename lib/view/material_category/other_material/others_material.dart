import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/material_category/other_material/other_materials_view.dart';
import 'package:raptor_pro/view/material_category/other_material/others_material_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

import '../../../utils/file_picker_helper.dart';
import '../../../utils/file_preview.dart';

class OtherMaterialScreen extends StatefulWidget{
  @override
  State<OtherMaterialScreen> createState() => _OtherMaterialScreenState();
}

class _OtherMaterialScreenState extends State<OtherMaterialScreen> {

  var otherMaterialController = Get.put(OthersMaterialController());
  File? attachment;
  int ?siteId;

  @override
  void initState() {
    // TODO: implement initState
    siteId= Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Others",
          onTap: () {
            Get.back();
          }),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if ( attachment != null)
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
                  Text("Upload Image"),
                ],
              ),
            ),
            VerticalSpacing.d20px(),


            Text("Amount",style: AppTextStyle.textFieldHeadingStyle,),
            VerticalSpacing.d5px(),
            TextFormField(
              controller: otherMaterialController.amountController,
              keyboardType: TextInputType.number,
              decoration:textBoxDecoration(hint:"Enter amount"),
              validator: (text){
                if (text == null || text.isEmpty) {
                  return 'Required';
                }
                return null;
              },



            ),

            VerticalSpacing.d16px(),

            Text("Remarks",style: AppTextStyle.textFieldHeadingStyle,),
            VerticalSpacing.d5px(),
            TextFormField(
              controller: otherMaterialController.reMarksController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 3,//Normal textInputField will be displayed
              decoration:textBoxDecoration(hint:"Enter remarks"),
              // validator: (text){
              //   if (text == null || text.isEmpty) {
              //     return 'Required';
              //   }
              //   return null;
              // },



            ),

            VerticalSpacing.d16px(),

            Obx((){
               return
                 otherMaterialController.isButtonLoading.value?
                 Center(child: CommonLoader(),):
                 CommonButton(onTap: () async {

                  await otherMaterialController.otherSave(siteId!,attachment!);
                   attachment = null;
                   setState(() {

                   });

            }, text: "Save");}),

            VerticalSpacing.d20px(),

            CommonButton(
              customColor: AppColor.buttonLightBlue,
                onTap: (){
                Get.to(OtherMaterialView(),arguments: siteId!);

                },
                text: "View Details"),
          ],
        ),
      ),
    );
  }

  /// ✅ Multiple Attachments Preview
  Widget _attachmentsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ( attachment != null)
          FilePreview(
            file: attachment!,
            isImage: true,
            onRemove: () {
              setState(() {
                attachment = null;
              });
            },
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
                    if (file != null) setState(() => attachment = file);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Capture Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    final file = await FilePickerHelper.pickImage(
                        fromCamera: true);
                    if (file != null) setState(() => attachment = file);
                  },
                ),
              ],
            ),
          ),
    );
  }
}