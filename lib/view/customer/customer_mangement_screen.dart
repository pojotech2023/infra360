import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_text_style.dart';
import '../../utils/const_data.dart';
import '../../utils/res/date_picker.dart';
import '../../utils/res/spacing.dart';
import '../../utils/text_form_style.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_button.dart';
import '../widgets/common_loader.dart';
import 'customer_Management_controller.dart';

class CustomerMangementScreen extends StatelessWidget {
  CustomerMangementScreen({super.key});

  final CustomerManagementController controller = Get.put(
      CustomerManagementController());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Site Name", style: AppTextStyle.textFieldHeadingStyle,),
                  VerticalSpacing.d5px(),
                  Obx(() {
                    if (controller.siteList.isEmpty) {
                      return TextFormField(
                        controller: controller.siteNameEditingController,
                        readOnly: true,
                        decoration: textBoxDecoration(hint: "Site Name"),
                      );
                    }
                    return DropdownButtonFormField<int>(
                      value: controller.siteList.any((s) => s.id == controller.selectedSiteId.value)
                          ? controller.selectedSiteId.value
                          : null,
                      decoration: textBoxDecoration(hint: "Select Site"),
                      isExpanded: true,
                      items: controller.siteList.map((site) {
                        return DropdownMenuItem<int>(
                          value: site.id,
                          child: Text(site.siteName ?? "Site #${site.id}"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedSiteId.value = val;
                        final matched = controller.siteList.firstWhereOrNull((s) => s.id == val);
                        if (matched != null) {
                          controller.siteNameEditingController.text = matched.siteName ?? '';
                        }
                      },
                    );
                  }),

                  VerticalSpacing.d15px(),
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
                  ),
                  VerticalSpacing.d15px(),
                  Text("Date Of Birth",
                    style: AppTextStyle.textFieldHeadingStyle,),

                  TextFormField(
                    controller: controller.dobEditingController,
                    decoration: textBoxDecoration(hint: "dd-MM-yyyy",
                        suffixIcon: const Icon(Icons.calendar_month, color: Colors.grey,)),
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
                    },
                  ),

                  VerticalSpacing.d30px(),

                  Obx(() {
                    return controller.isSaveLoading.value
                        ? const Center(child: CommonLoader())
                        : CommonButton(onTap: () {
                            if (_formKey.currentState!.validate()) {
                              controller.updateCustomer();
                            }
                          }, text: Get.arguments == null ? "Save" : "Update");
                  }),
                ],
              ),
            ),
          )),
    );
  }
}