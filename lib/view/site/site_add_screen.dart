import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/view/site/site_controller.dart';
import '../../base_url.dart';
import '../../utils/url_helper.dart';
import '../../model/employee_list_model.dart';
import '../../model/site_management_model.dart';
import '../../utils/app_text_style.dart';
import '../../utils/const_data.dart';
import '../../utils/file_picker_helper.dart';
import '../../utils/res/colors.dart';
import '../../utils/res/spacing.dart';
import '../../utils/text_form_style.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_button.dart';
import '../widgets/common_loader.dart';

class SiteAddScreen extends StatefulWidget {
  SiteAddScreen({super.key, this.siteData});

  final SiteManagementList? siteData;
  @override
  State<SiteAddScreen> createState() => _SiteAddScreenState();
}

class _SiteAddScreenState extends State<SiteAddScreen> {
  final SiteController controller = Get.put(SiteController());
  bool get isEditMode => widget.siteData != null;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File? attachment;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      controller.preFillData(widget.siteData!);
    } else {
      // Reset site form and customer state for Add mode
      controller.clearSiteForm();
      controller.customerType.value = 'new';
      controller.searchMobileController.clear();
      controller.searchStatusMessage.value = '';
      controller.searchStatusIsError.value = false;
      controller.existingCustomerId.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: isEditMode ? "Edit Site" : "Add Site",
          onTap: () {
            Get.back();
          }),
      body: SafeArea(child:GetBuilder<SiteController>(
          builder: (controller) => Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Site Detail",
                        style: AppTextStyle.textFieldHeadingStyle
                            .copyWith(fontSize: 18),
                      ),
                      VerticalSpacing.d20px(),
                      Center(
                        child: InkWell(
                          onTap: () => _showAttachmentOptions(context),
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColor.textFieldBorder, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Builder(
                              builder: (context) {
                                // ✅ Safely handle null siteData (for Add mode)
                                final String? apiImageUrl =
                                    widget.siteData?.siteImg;

                                if (attachment != null) {
                                  // ✅ If user selected new image
                                  return Image.file(
                                    File(attachment!.path),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            placeHolder(),
                                  );
                                } else if (apiImageUrl != null &&
                                    apiImageUrl.isNotEmpty) {
                                  // ✅ If editing and API image exists
                                  return Image.network(
                                    UrlHelper.getFullImageUrl(apiImageUrl),
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            placeHolder(),
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

                      /*    Center(
                child: InkWell(
                  onTap:()=> _showAttachmentOptions(context),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColor.textFieldBorder, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: attachment != null
                        ? Image.file(
                      File(attachment!.path),
                      fit: BoxFit.cover,
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo, size: 30, color: Colors.grey),
                        VerticalSpacing.d5px(),
                        const Text(
                          'Add Site Image',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )

                ),
                ),
*/

                      VerticalSpacing.d10px(),
                      Text(
                        "Site Name",
                        style: AppTextStyle.textFieldHeadingStyle,
                      ),
                      TextFormField(
                        controller: controller.siteNameEditingController,
                        decoration: textBoxDecoration(hint: "Enter Site Name"),
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      VerticalSpacing.d15px(),
                      Text(
                        "Duration",
                        style: AppTextStyle.textFieldHeadingStyle,
                      ),
                      TextFormField(
                        controller: controller.durationEditingController,
                        decoration: textBoxDecoration(hint: "Enter Duration"),
                        validator: (text) {
                          return null;
                        },
                      ),
                      VerticalSpacing.d15px(),
                      Text(
                        "Location",
                        style: AppTextStyle.textFieldHeadingStyle,
                      ),
                      TextFormField(
                        controller: controller.locationEditingController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: textBoxDecoration(hint: "Enter Location"),
                        validator: (text) {
                          return null;
                        },
                      ),
                      VerticalSpacing.d15px(),
                      Text(
                        "Contract Value",
                        style: AppTextStyle.textFieldHeadingStyle,
                      ),
                      TextFormField(
                        controller: controller.contractValueController,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: textBoxDecoration(hint: "Contract Value"),
                        validator: (text) {
                          return null;
                        },
                      ),
                      VerticalSpacing.d15px(),
                      Text(
                        "Built-up Area",
                        style: AppTextStyle.textFieldHeadingStyle,
                      ),
                      TextFormField(
                        controller: controller.builtupAreaController,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: textBoxDecoration(hint: "Built-up Area"),
                        onChanged: (value) {
                          print("value");
                        },
                        validator: (text) {
                          return null;
                        },
                      ),
                      VerticalSpacing.d15px(),
                      Text(
                        "Flat Area",
                        style: AppTextStyle.textFieldHeadingStyle,
                      ),
                      TextFormField(
                        controller: controller.flatAreaController,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: textBoxDecoration(hint: "Flat Area"),
                        onChanged: (value) {
                          print("value");
                        },
                        validator: (text) {
                          return null;
                        },
                      ),
                      VerticalSpacing.d15px(),
                      Text(
                        "Assigned by Supervisor",
                        style: AppTextStyle.textFieldHeadingStyle,
                      ),
                      DropdownButtonFormField2<EmployeeListData>(
                        isExpanded: true,
                        value: controller.selectedEmployeeData
                            .value, // ✅ Preselect in Edit mode
                        decoration:
                            dropDownBoxDecoration(hint: "Select Supervisor"),
                        hint: Text(
                          'Select Supervisor',
                          style: AppTextStyle.textHintText,
                        ),
                        items: controller.employeeList
                            .map((item) => DropdownMenuItem<EmployeeListData>(
                                  value: item,
                                  child: Text(
                                    item.name ?? "",
                                    style: AppTextStyle.textFieldHeadingStyle,
                                  ),
                                ))
                            .toList(),
                        validator: (value) {
                          return null;
                        },
                        onChanged: (value) {
                          controller.selectedEmployeeData.value = value;
                        },
                        onSaved: (value) {},
                        dropdownSearchData: DropdownSearchData(
                          searchController:
                              controller.employeeEditingController,
                          searchInnerWidgetHeight: 50,
                          searchInnerWidget: Container(
                            height: 55,
                            padding: const EdgeInsets.all(8),
                            child: TextFormField(
                              controller: controller.employeeEditingController,
                              decoration:
                                  textBoxDecoration(hint: "Search Supervisor"),
                            ),
                          ),
                          searchMatchFn: (item, searchValue) => item
                              .value!.name!
                              .toLowerCase()
                              .contains(searchValue.toLowerCase()),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      isEditMode
                          ? statusDetailForm(context)
                          : customerDetailForm(context),
                      VerticalSpacing.d30px(),
                      Obx(() {
                        return controller.isSaveLoading.value
                            ? Center(child: CommonLoader())
                            : CommonButton(
                                onTap: () {
                                  // Guard against double-tap
                                  if (controller.isSaveLoading.value) return;
                                  if (_formKey.currentState!.validate()) {
                                    if (isEditMode) {
                                      controller.updateSiteApi(
                                          files: attachment);
                                    } else {
                                      controller.addSiteApi(
                                          files: attachment);
                                    }
                                  }
                                },
                                text: (isEditMode) ? "Update" : "Save",
                              );
                      }),
                    ],
                  ),
                ),
              ))),
    );
  }

  Future<String> selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      return formattedDate;
    } else {
      return '';
    }
  }

  customerDetailForm(BuildContext context) {
    final bool isExisting = controller.customerType.value == 'existing';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VerticalSpacing.d20px(),
        Text(
          "Customer Detail",
          style: AppTextStyle.textFieldHeadingStyle.copyWith(fontSize: 18),
        ),
        VerticalSpacing.d15px(),
        // ── Customer Type Radio ──
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Customer Type",
              style: AppTextStyle.textFieldHeadingStyle,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRadioOption('new', 'New Customer'),
                const SizedBox(width: 24),
                _buildRadioOption('existing', 'Existing Customer'),
              ],
            ),
          ],
        ),
        // ── Search by Mobile (Existing only) ──
        if (isExisting) ..._buildExistingCustomerSearchRow(context),
        VerticalSpacing.d15px(),
        Text(
          "Name",
          style: AppTextStyle.textFieldHeadingStyle,
        ),
        TextFormField(
          controller: controller.nameEditingController,
          readOnly: isExisting,
          decoration: textBoxDecoration(hint: "Enter Customer name"),
          validator: (text) => null,
        ),
        VerticalSpacing.d15px(),
        Text(
          "Mobile Number",
          style: AppTextStyle.textFieldHeadingStyle,
        ),
        TextFormField(
          controller: controller.mobileNumberEditingController,
          readOnly: isExisting,
          keyboardType: TextInputType.number,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          inputFormatters: isExisting ? [] : tenDigitPhoneFormatter(),
          decoration: textBoxDecoration(hint: "Enter Customer Mobile Number"),
          validator: (text) {
            if (!isExisting &&
                text != null &&
                text.isNotEmpty &&
                text.length != 10) {
              return 'Mobile number must be 10 digits';
            }
            return null;
          },
        ),
        VerticalSpacing.d15px(),
        Text(
          "Email Id",
          style: AppTextStyle.textFieldHeadingStyle,
        ),
        TextFormField(
          controller: controller.emailEditingController,
          readOnly: isExisting,
          decoration: textBoxDecoration(hint: "Enter Customer Email"),
          validator: (text) => null,
        ),
        VerticalSpacing.d15px(),
        Text(
          "Date of Birth",
          style: AppTextStyle.textFieldHeadingStyle,
        ),
        TextFormField(
          controller: controller.dobPickerController,
          readOnly: true,
          decoration: textBoxDecoration(
            hint: "dd-MM-yyyy",
            suffixIcon: isExisting
                ? null
                : const Icon(Icons.calendar_month, color: Colors.grey),
          ),
          onTap: isExisting
              ? null
              : () async {
                  String date = await selectDate(context);
                  if (date.isNotEmpty) {
                    controller.dobPickerController.text = date;
                  }
                },
          validator: (text) => null,
        ),
        VerticalSpacing.d10px(),
        Text(
          "Address",
          style: AppTextStyle.textFieldHeadingStyle,
        ),
        TextFormField(
          controller: controller.addressEditingController,
          readOnly: isExisting,
          minLines: 3,
          maxLines: 5,
          decoration: textBoxDecoration(hint: "Enter Customer Address"),
          validator: (text) => null,
        ),
      ],
    );
  }

  /// Builds a single radio button option for Customer Type
  Widget _buildRadioOption(String value, String label) {
    return Obx(() {
      final bool isSelected = controller.customerType.value == value;
      return GestureDetector(
        onTap: () => controller.setCustomerType(value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColor.buttonBlue : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.buttonBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyle.textFieldHeadingStyle),
          ],
        ),
      );
    });
  }

  /// Builds the Search by Mobile Number row for Existing Customer mode
  List<Widget> _buildExistingCustomerSearchRow(BuildContext context) {
    return [
      VerticalSpacing.d15px(),
      Text(
        "Search by Mobile Number",
        style: AppTextStyle.textFieldHeadingStyle,
      ),
      const SizedBox(height: 8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller.searchMobileController,
              keyboardType: TextInputType.number,
              inputFormatters: tenDigitPhoneFormatter(),
              decoration: textBoxDecoration(
                hint: "Enter 10 digit mobile number",
              ),
              validator: (text) => null,
            ),
          ),
          const SizedBox(width: 10),
          Obx(() => controller.isSearchLoading.value
              ? const SizedBox(
                  width: 42,
                  height: 42,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : ElevatedButton(
                  onPressed: () => controller.searchCustomerByMobile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
        ],
      ),
      Obx(() {
        final msg = controller.searchStatusMessage.value;
        if (msg.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            msg,
            style: TextStyle(
              color: controller.searchStatusIsError.value
                  ? Colors.red
                  : Colors.green,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }),
    ];
  }


  statusDetailForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VerticalSpacing.d20px(),
        Text(
          "Site Status Detail",
          style: AppTextStyle.textFieldHeadingStyle.copyWith(fontSize: 18),
        ),
        VerticalSpacing.d20px(),
        Text(
          "Status",
          style: AppTextStyle.textFieldHeadingStyle,
        ),
        DropdownButtonFormField2<String>(
          isExpanded: true,
          value: ConstantData.siteStatus.contains(
            controller.isEditForm.value
                ? controller.status.value.trim()
                : controller.selectedStatus.value.trim(),
          )
              ? (controller.isEditForm.value
                  ? controller.status.value.trim()
                  : controller.selectedStatus.value.trim())
              : null,
          decoration: dropDownBoxDecoration(),
          hint: Text('Site Status', style: AppTextStyle.textHintText),
          items: ConstantData.siteStatus
              .map((item) => DropdownMenuItem<String>(
                    value: item.trim(),
                    child: Text(
                      capitalize(item),
                      style: AppTextStyle.textFieldHeadingStyle,
                    ),
                  ))
              .toList(),
          validator: (value) => null,
          onChanged: (value) {
            controller.selectedStatus.value = value ?? '';
            controller.status.value = value ?? '';
          },
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        )
      ],
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
                  final file =
                      await FilePickerHelper.pickImage(fromCamera: true);
                  if (file != null) setState(() => attachment = file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget placeHolder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_a_photo, size: 30, color: Colors.grey),
        VerticalSpacing.d5px(),
        const Text(
          'Add Site Image',
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
