import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/material_details_argument_model.dart';
import '../../../model/subcontractor_list_model.dart' as list_model;
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
        title: controller.isEditMode ? "Edit ${args.itemKey} Service" : "Add ${args.itemKey} Service",
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              /// SUBCONTRACTOR DROPDOWN
              Text("Subcontractor Name",
                  style: AppTextStyle.textFieldHeadingStyle),
              Obx(
                    () => DropdownButtonFormField2<list_model.Subcontractor>(
                  isExpanded: true,
                  decoration: dropDownBoxDecoration(
                    hint: "Select Subcontractor Name",
                  ),
                  hint: Text(
                    'Select Subcontractor Name',
                    style: AppTextStyle.textHintText,
                  ),
                  value: controller.selectedSubContractorData.value,

                  items: controller.getLists.map((item) {
                    return DropdownMenuItem<list_model.Subcontractor>(
                      value: item,
                      child: Text(
                        item.name,
                        style: AppTextStyle.textFieldHeadingStyle,
                      ),
                    );
                  }).toList(),

                  validator: (value) {
                    if (value == null) {
                      return 'Please select Subcontractor';
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
              Text("Subcontractor Mobile No",
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
              /// ADDRESS
              /// ===============================
              VerticalSpacing.d15px(),
              Text("Subcontractor Address",
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
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      controller.dateController.text =
                          "${pickedDate.day.toString().padLeft(2,'0')}-${pickedDate.month.toString().padLeft(2,'0')}-${pickedDate.year}";
                    }
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
              /// REMARKS
              /// ===============================
              VerticalSpacing.d15px(),
              Text("Remarks", style: AppTextStyle.textFieldHeadingStyle),
              VerticalSpacing.d5px(),
              TextFormField(
                controller: controller.remarksController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 2,
                decoration: textBoxDecoration(hint: "Enter remarks (optional)"),
              ),

              /// ===============================
              /// SUBMIT BUTTON
              /// ===============================
              VerticalSpacing.d20px(),
             Obx(()=> controller.isLoading.value ? Center(child: CircularProgressIndicator()) : SizedBox(
               width: double.infinity,
               child: ElevatedButton.icon(
                 onPressed: () {
                   if (_formKey.currentState!.validate()) {
                     if (controller.isEditMode) {
                       controller.updateServicesApi(args.id);
                     } else {
                       controller.addServicesApi(args.id);
                     }
                   }
                 },
                 icon: Icon(Icons.chat, color: Colors.white), // Using chat icon as a placeholder for WhatsApp if flutter_svg is not used
                 label: Text(
                   controller.isEditMode ? "Update Service\nWhatsApp" : "Send Service to SubContractor\nWhatsApp",
                   textAlign: TextAlign.center,
                   style: TextStyle(color: Colors.white, fontSize: 16),
                 ),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.blue, // WhatsApp color or use standard blue like the web image
                   padding: EdgeInsets.symmetric(vertical: 12),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(8),
                   ),
                 ),
               ),
             ))
            ],
          ),
        ),
      ),
      ),
    );
  }
}
