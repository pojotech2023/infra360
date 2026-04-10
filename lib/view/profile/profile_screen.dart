
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/view/profile/profile_controller.dart';

import '../../base_url.dart';
import '../../utils/app_text_style.dart';
import '../../utils/const_data.dart';
import '../../utils/file_picker_helper.dart';
import '../../utils/res/colors.dart';
import '../../utils/res/spacing.dart';
import '../../utils/text_form_style.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_button.dart';
import '../widgets/common_loader.dart';
import '../widgets/toast.dart';


class ProfileScreen extends StatefulWidget {
   ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
 final  ProfileController controller = Get.put(ProfileController());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
 File? attachment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title:
              "Edit Profile",
          onTap: (){
            Get.back();

          }),
      body:  Form(
        key: _formKey,
        child: GetBuilder<ProfileController>(builder: (controller){
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [



                Center(
                  child: InkWell(
                    onTap: () => _showAttachmentOptions(context),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.textFieldBorder, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Builder(
                        builder: (context) {
                          // ✅ Safely handle null siteData (for Add mode)
                          final String? apiImageUrl = controller.profileImage.value;

                          print("API IMAGE PROFILE ${apiImageUrl}");

                          if (attachment != null) {
                            // ✅ If user selected new image
                            return Image.file(
                              File(attachment!.path),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => placeHolder(),
                            );
                          } else if (apiImageUrl != null && apiImageUrl.isNotEmpty) {
                            // ✅ If editing and API image exists
                            return Image.network(
                              '$imageUrl/$apiImageUrl',
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) => placeHolder(),
                            );
                          } else {
                            // ✅ For Add mode or no image found
                            return placeHolder();
                          }
                        },
                      ),
                    ),
                  ),
                ),



                Text("Name",style: AppTextStyle.textFieldHeadingStyle,),
                VerticalSpacing.d5px(),
                TextFormField(
                  controller: controller.nameController,
                  decoration:textBoxDecoration(hint:"Enter your name"),
                  validator: (text){
                    if (text == null || text.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },



                ),

                VerticalSpacing.d15px(),
                Text("Mobile Number",style: AppTextStyle.textFieldHeadingStyle,),

                TextFormField(
                  controller: controller.mobileController,
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters:tenDigitPhoneFormatter(),

                  decoration:textBoxDecoration(hint:"Enter your mobile number"),
                  validator: (text){
                    if (text == null || text.isEmpty) {
                      return 'Required';
                    }
                    if (text.length != 10) {
                      return 'Mobile number must be 10 digits';
                    }
                    return null;
                  },



                ),


                VerticalSpacing.d15px(),
                Text("Email Id",style: AppTextStyle.textFieldHeadingStyle,),

                TextFormField(
                  controller: controller.emailController,
                  decoration:textBoxDecoration(hint:"Enter your email"),
                  // validator: (text){
                  //   if (text == null || text.isEmpty) {
                  //     return 'Required';
                  //   }
                  //   return null;
                  // },
                ),
/*
                VerticalSpacing.d15px(),
                Text("Password",style: AppTextStyle.textFieldHeadingStyle,),

                TextFormField(
                  controller: controller.passwordController,
                  decoration:textBoxDecoration(hint:"Enter Password"),
                  validator: (text){
                    if (text == null || text.isEmpty) {
                      return 'Required';
                    }

                    return null;
                  },



                ),
                VerticalSpacing.d15px(),
                Text("Confirm Password",style: AppTextStyle.textFieldHeadingStyle,),

                TextFormField(
                  controller: controller.confirmpasswordController,
                  decoration:textBoxDecoration(hint:"Enter  confirm Password"),
                  validator: (text){
                    if (text == null || text.isEmpty) {
                      return 'Required';
                    }
                    if (text != controller.passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;

                    return null;
                  },
                ),
*/


                VerticalSpacing.d30px(),

                Obx((){

                  return
                    controller.isSaveLoading.value?Center(child: CommonLoader()):CommonButton(onTap: (){

                      if(_formKey.currentState!.validate()){




                        if (attachment == null && (controller.profileImage.value == null || controller.profileImage.value.isEmpty)) {
                          showToastMessage("Please select a profile image");
                          return;
                        }

                        controller.updateProfileApi(files: attachment);

                      }





                    }, text: "Update");
                }
                ),
              ],
            ),
          );
        }),
      ),

    );
  }

   /// ✅ File Picker Bottom Sheet
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
