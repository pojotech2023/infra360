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
    // TODO: implement initState
    if (isEditMode) {
      controller.preFillData(widget.siteData!);
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
                          if (text == null || text.isEmpty) {
                            return 'Required';
                          }
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
                          if (text == null || text.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      VerticalSpacing.d15px(),
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
                          if (text == null || text.isEmpty) {
                            return 'Required';
                          }

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
                        decoration: textBoxDecoration(hint: "Pending Amount"),
                        onChanged: (value) {
                          print("value");
                        },
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Required';
                          }

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
                          if (value == null) return 'Please select Supervisor';
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
                                  if (_formKey.currentState!.validate()) {
                                    if (isEditMode) {
                                      controller.updateSiteApi(
                                          files: attachment); // ✅ optional
                                    } else {
                                      controller.addSiteApi(
                                          files: attachment!); // ✅ required
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VerticalSpacing.d20px(),
        Text(
          "Customer Detail",
          style: AppTextStyle.textFieldHeadingStyle.copyWith(fontSize: 18),
        ),
        VerticalSpacing.d20px(),
        Text(
          "Name",
          style: AppTextStyle.textFieldHeadingStyle,
        ),
        TextFormField(
          controller: controller.nameEditingController,
          decoration: textBoxDecoration(hint: "Enter Customer name"),
          validator: (text) {
            if (text == null || text.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
        VerticalSpacing.d15px(),
        Text(
          "Mobile Number",
          style: AppTextStyle.textFieldHeadingStyle,
        ),
        TextFormField(
          controller: controller.mobileNumberEditingController,
          keyboardType: TextInputType.number,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          inputFormatters: tenDigitPhoneFormatter(),
          decoration: textBoxDecoration(hint: "Enter Customer Mobile Number"),
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
        Text(
          "Email Id",
          style: AppTextStyle.textFieldHeadingStyle,
        ),
        TextFormField(
          controller: controller.emailEditingController,
          decoration: textBoxDecoration(hint: "Enter Customer Email"),
          validator: (text) {
            if (text == null || text.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
        VerticalSpacing.d15px(),
        Text(
          "Date of Birth",
          style: AppTextStyle.textFieldHeadingStyle,
        ),
        TextFormField(
          controller: controller.dobPickerController,
          decoration: textBoxDecoration(
              hint: "dd-MM-yyyy",
              suffixIcon: Icon(
                Icons.calendar_month,
                color: Colors.grey,
              )),
          readOnly: true,
          onTap: () async {
            String date = await selectDate(context); // 👈 wait for result
            if (date.isNotEmpty) {
              controller.dobPickerController.text = date; // 👈 assign here
            }
          },
          validator: (text) {
            if (text == null || text.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
        VerticalSpacing.d10px(),
        Text(
          "Address",
          style: AppTextStyle.textFieldHeadingStyle,
        ),
        TextFormField(
          controller: controller.addressEditingController,
          minLines: 3,
          maxLines: 5,
          decoration: textBoxDecoration(hint: "Enter Customer Address"),
          validator: (text) {
            if (text == null || text.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
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
          validator: (value) => value == null ? 'Select Site Status' : null,
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
