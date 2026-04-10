
import 'package:flutter/material.dart';

import '../../utils/app_text_style.dart';
import '../../utils/const_data.dart';
import '../../utils/res/date_picker.dart';
import '../../utils/res/spacing.dart';
import '../../utils/text_form_style.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_button.dart';
import '../widgets/common_loader.dart';
import 'customer_Management_controller.dart';
import 'customer_list_controller.dart';
import 'package:get/get.dart';


class CustomerMangementScreen extends StatelessWidget {
  CustomerMangementScreen({super.key});

  CustomerManagementController controller = Get.put(
      CustomerManagementController());


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Edit Customer",
          onTap: () {
            Get.back();
          }),
      body: GetBuilder<CustomerManagementController>(builder: (controller) =>
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("Name", style: AppTextStyle.textFieldHeadingStyle,),
                  VerticalSpacing.d5px(),
                  TextFormField(
                    controller: controller.nameEditingController,
                    decoration: textBoxDecoration(hint: "Enter your name"),
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },


                  ),

                  VerticalSpacing.d15px(),
                  Text("Mobile Number",
                    style: AppTextStyle.textFieldHeadingStyle,),

                  TextFormField(
                    controller: controller.mobileNumberEditingController,
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: tenDigitPhoneFormatter(),

                    decoration: textBoxDecoration(
                        hint: "Enter your mobile number"),
                    validator: (text) {
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
                  Text("Email Id", style: AppTextStyle.textFieldHeadingStyle,),

                  TextFormField(
                    controller: controller.emailEditingController,
                    decoration: textBoxDecoration(hint: "Enter your email"),
                    // validator: (text){
                    //   if (text == null || text.isEmpty) {
                    //     return 'Required';
                    //   }
                    //   return null;
                    // },
                  ),
                  VerticalSpacing.d15px(),
                  Text("Date Of Birth",
                    style: AppTextStyle.textFieldHeadingStyle,),

                  TextFormField(
                    controller: controller.dobEditingController,
                    decoration:textBoxDecoration(hint:"dd-MM-yyyy",
                        suffixIcon: Icon(Icons.calendar_month,color: Colors.grey,)),
                    readOnly: true,

                    onTap: () async {
                      String pickedDate = await selectDate(context);
                      if (pickedDate.isNotEmpty) {
                        controller.dobEditingController.text = pickedDate;
                      }
                    },
                    validator: (text){
                      if (text == null || text.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },



                  ),
                  VerticalSpacing.d15px(),
                 /* Text("Marriage Date",
                    style: AppTextStyle.textFieldHeadingStyle,),

                  TextFormField(
                    controller: controller.marrageDateEditingController,
                    decoration:textBoxDecoration(hint:"dd-MM-yyyy",
                        suffixIcon: Icon(Icons.calendar_month,color: Colors.grey,)),
                    readOnly: true,

                    onTap: () async {
                      String pickedDate = await selectDate(context);
                      if (pickedDate.isNotEmpty) {
                        controller.marrageDateEditingController.text = pickedDate;
                      }
                    },
                    validator: (text){
                      if (text == null || text.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },



                  ),*/

                  VerticalSpacing.d15px(),
                  Text("Address", style: AppTextStyle.textFieldHeadingStyle,),

                  TextFormField(
                    controller: controller.addressEditingController,
                    decoration: textBoxDecoration(hint: "Enter Address"),
                    minLines: 3,
                    maxLines: 5,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Required';
                      }

                      return null;

                      return null;
                    },
                  ),

                  VerticalSpacing.d30px(),

                  Obx(() {
                    return
                      controller.isSaveLoading.value ? Center(
                          child: CommonLoader()) : CommonButton(onTap: () {
                        if (_formKey.currentState!.validate()) {
                          controller.updateCustomer();
                          /* if(Get.arguments==null){
                         controller.addSupervisor(nameEditingController.text, mobileNumberEditingController.text,
                             emailEditingController.text,passwordEditingController.text,confirmPasswordEditingController.text);
                       }
                       else{
                         SuperVisorData ?superVisorData = Get.arguments;

                         controller.updateSupervisor(
                             superVisorData!.id!,
                             nameEditingController.text, mobileNumberEditingController.text,
                             emailEditingController.text,passwordEditingController.text,confirmPasswordEditingController.text);
                       }*/
                        }
                      }, text: Get.arguments == null ? "Save" : "Update");
                  }
                  ),
                ],
              ),
            ),
          )),

    );
  }
}