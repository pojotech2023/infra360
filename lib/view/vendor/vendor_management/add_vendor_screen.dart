import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/supervisor_management/supervisor_management_controller.dart';
import 'package:raptor_pro/view/vendor/vendor_management/vendor_management_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

class AddVendorScreen extends StatefulWidget{
  const AddVendorScreen({super.key});

  @override
  State<AddVendorScreen> createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends State<AddVendorScreen> {



  VendorManagementController controller = Get.find<VendorManagementController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    // TODO: implement initState

    if(Get.arguments!=null){
      controller.preFillMethod();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Add Vendor",
          onTap: (){
            Get.back();

          }),
      body:  Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

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

              Text("Site Utilities",style: AppTextStyle.textFieldHeadingStyle,),
              VerticalSpacing.d5px(),
              DropdownButtonFormField2<String>(
                isExpanded: true,
                value:controller.selectedSiteUtilities==null?null: lowerCapitalize(controller.selectedSiteUtilities!),

                decoration: dropDownBoxDecoration(
                ),
                hint:  Text(
                  'Site Utilities',
                  style: AppTextStyle.textHintText,
                ),
                items: ConstantData.allMaterialKeys
                    .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                      capitalize(item),
                      style: AppTextStyle.textFieldHeadingStyle
                  ),
                ))
                    .toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Select Site Utilities';
                  }
                  return null;
                },
                onChanged: (value) {
                  controller.selectedSiteUtilities=value;

                  //Do something when selected item is changed.
                },
                onSaved: (value) {
                  // selectedValue = value.toString();
                },


                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

              ),

              VerticalSpacing.d15px(),


              Text("Mobile Number",style: AppTextStyle.textFieldHeadingStyle,),
              VerticalSpacing.d5px(),
              TextFormField(
                controller: controller.mobileController,
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
              VerticalSpacing.d5px(),
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
              VerticalSpacing.d15px(),
              Text("Address",style: AppTextStyle.textFieldHeadingStyle,),
              VerticalSpacing.d5px(),
              TextFormField(
                controller:controller.addressController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 3,//Normal textInputField will be displayed
                decoration:textBoxDecoration(hint:"Address"),
                // validator: (text){
                //   if (text == null || text.isEmpty) {
                //     return 'Required';
                //   }
                //   return null;
                // },

              ),
              VerticalSpacing.d15px(),
              Text("GST",style: AppTextStyle.textFieldHeadingStyle,),
              VerticalSpacing.d5px(),
              TextFormField(
                controller: controller.gstController,
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration:textBoxDecoration(hint:"Enter your GST"),
                validator: (text){
                  if (text == null || text.isEmpty) {
                    return 'Required';
                  }

                  return null;
                },



              ),

              VerticalSpacing.d30px(),

              Obx((){

                return
                  controller.isSaveLoading.value?Center(child: CommonLoader()):CommonButton(onTap: (){

                    if(_formKey.currentState!.validate()){

                      if(Get.arguments==null){
                        controller.addVendor();

                      }
                      else{
                        controller.updateVendor();

                      }


                    }



                  }, text: Get.arguments==null?"Save":"Update");
              }
              ),
            ],
          ),
        ),
      ),

    );
  }
}