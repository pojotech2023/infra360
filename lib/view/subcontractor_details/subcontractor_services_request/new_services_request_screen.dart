import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/material_details_argument_model.dart';
import '../../../model/subcontractor_list_model.dart';
import '../../../utils/app_text_style.dart';
import '../../../utils/res/spacing.dart';
import '../../../utils/text_form_style.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/common_button.dart';
import 'new_services_request_controller.dart';

class NewServiceRequestScreen extends StatelessWidget {
  NewServiceRequestScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController searchEditingController = TextEditingController();
  final SubcontracorDetailsArgs args = Get.arguments as SubcontracorDetailsArgs;
  final NewServicesRequestController controller =
  Get.put(NewServicesRequestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: "Add Request",
        onTap: () => Get.back(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===============================
              /// SUBCONTRACTOR DROPDOWN
              /// ===============================
              Text("Subcontractor Name",
                  style: AppTextStyle.textFieldHeadingStyle),
              Obx(
                    () => DropdownButtonFormField2<Subcontractor>(
                  isExpanded: true,
                  decoration: dropDownBoxDecoration(
                    hint: "Select Subcontractor Name",
                  ),
                  hint: Text(
                    'Select Subcontractor Name',
                    style: AppTextStyle.textHintText,
                  ),
                  value: controller.selectedSubContractorData.value, // ✅ Keeps selected item

                  items: controller.getLists.map((item) {
                    return DropdownMenuItem<Subcontractor>(
                      value: item,
                      child: Text(
                        item.name,
                        style: AppTextStyle.textFieldHeadingStyle,
                      ),
                    );
                  }).toList(),

                  validator: (value) {
                    if (value == null) {
                      return 'Please select Vendor';
                    }
                    return null;
                  },

                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedSubContractorData.value = value;
                      controller.mobileNoController.text = value.mobileNo;
                      controller.addressController.text = value.address;
                    }
                  },

                  dropdownSearchData: DropdownSearchData(
                    searchController: searchEditingController,
                    searchInnerWidgetHeight: 50,
                    searchInnerWidget: Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: TextFormField(
                        controller: searchEditingController,
                        decoration:
                        textBoxDecoration(hint: "Search Subcontractor"),
                      ),
                    ),
                    searchMatchFn: (item, searchValue) {
                      return item.value!.name
                          .toLowerCase()
                          .contains(searchValue.toLowerCase());
                    },
                  ),

                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              /// ===============================
              /// MOBILE NUMBER
              /// ===============================
              VerticalSpacing.d15px(),
              Text("Requestor Mobile No",
                  style: AppTextStyle.textFieldHeadingStyle),
              VerticalSpacing.d5px(),
              TextFormField(
                readOnly: true,
                controller: controller.mobileNoController,
                keyboardType: TextInputType.number,
                decoration: textBoxDecoration(hint: "Mobile number"),
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

              /// ===============================
              /// ADDRESS
              /// ===============================
              VerticalSpacing.d15px(),
              Text("Requestor Address",
                  style: AppTextStyle.textFieldHeadingStyle),
              VerticalSpacing.d5px(),
              TextFormField(
                readOnly: true,
                controller: controller.addressController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 2,
                decoration: textBoxDecoration(hint: "Address"),
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),

              /// ===============================
              /// NO. OF COUNTS
              /// ===============================
              VerticalSpacing.d15px(),
              Text("No Of Counts", style: AppTextStyle.textFieldHeadingStyle),
              VerticalSpacing.d5px(),
              TextFormField(
                controller: controller.countController,
                keyboardType: TextInputType.number,
                decoration: textBoxDecoration(hint: "Enter No Of Counts"),
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),

              /// ===============================
              /// AMOUNT
              /// ===============================
              VerticalSpacing.d15px(),
              Text("Amount", style: AppTextStyle.textFieldHeadingStyle),
              VerticalSpacing.d5px(),
              TextFormField(
                controller: controller.amountController,
                keyboardType: TextInputType.number,
                decoration: textBoxDecoration(hint: "Enter amount"),
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),

              /// ===============================
              /// DATE
              /// ===============================
              VerticalSpacing.d15px(),
              Text("Date", style: AppTextStyle.textFieldHeadingStyle),
              VerticalSpacing.d5px(),
              TextFormField(
                controller: controller.dateController,
                decoration:textBoxDecoration(hint:"dd-MM-yyyy",
                    suffixIcon: Icon(Icons.calendar_month,color: Colors.grey,)),
                readOnly: true,
                onTap: () async {
                  // ✅ Proper date picker
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    controller.dateController.text =
                    "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                  }
                },
              ),

              /// ===============================
              /// SUBMIT BUTTON
              /// ===============================
              VerticalSpacing.d20px(),
             Obx(()=> controller.isLoading == true ? CircularProgressIndicator():  CommonButton(
               onTap: () {
                 if (_formKey.currentState!.validate()) {
                   // TODO: call controller.addMaterialApi()
                   controller.addServicesApi(args.id);
                 }
               },
               text: "Submit",
             ),)
            ],
          ),
        ),
      ),
    );
  }
}
