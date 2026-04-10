import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/vendor_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/material_category/new_bricks/new_request_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';

import '../../../utils/file_picker_helper.dart';
import '../../../utils/file_preview.dart';
import '../../../utils/res/colors.dart';
import '../../../utils/res/date_picker.dart';

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key,required this.type});

  final int type;

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final NewRequestController controller = Get.put(NewRequestController());
  final TextEditingController searchEditingController = TextEditingController();
  File? attachment;

  late String role ;
  late int type;
  late bool canShow;

  @override
  void initState() {
    super.initState();
    controller.materialUnitsListApi();


   role = controller.userDetails.data!.role!.toLowerCase();
    type = widget.type;

  canShow =
        (role == 'admin' && (type == 1 || type == 2)) ||
            (role == 'supervisor' && type == 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:CommonAppBar.appBar(
        title :  widget.type == 1 ? "Add ${controller.itemKey} Request" : "Add ${controller.itemKey} Order",
        onTap: () => Get.back(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              if (canShow) ...[
            _buildVendorDropdown(),
          _buildMobileNumberField(),
          _buildAddressField(),
          ],
              _buildQuantityField(),

              _buildCategoryDropdown(),
              _buildUnitDropdown(),
           //   _buildattachemnt(),

              _buildDate(),
               _buildAmountField(),
              _buildSupervisorNameField(),
              _buildSupervisorMobField(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }


  // 🔹 VENDOR DROPDOWN (Reactive)
  Widget _buildVendorDropdown() {
    return Obx(() {
      final vendorList = controller.getBricksLists;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Vendor", style: AppTextStyle.textFieldHeadingStyle),
          DropdownButtonFormField2<VendorData>(
            isExpanded: true,
            decoration: dropDownBoxDecoration(hint: "Select Vendor"),
            hint: Text('Select Vendor', style: AppTextStyle.textHintText),
            items: vendorList
                .map(
                  (item) => DropdownMenuItem<VendorData>(
                value: item,
                child: Text(item.name ?? "",
                    style: AppTextStyle.textFieldHeadingStyle),
              ),
            )
                .toList(),
            validator: (value) =>
            value == null ? 'Please select Vendor' : null,
            onChanged: (value) {
              if (value != null) {
                controller.selectedVendorData = value;
                controller.mobileNoController.text = value.mobileNo ?? '';
                controller.addressController.text = value.address ?? '';
                controller.update();
              }
print("CONTROLLER VENDOR ${controller.selectedVendorData.id}");
            },
            dropdownSearchData: DropdownSearchData(
              searchController: searchEditingController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  controller: searchEditingController,
                  decoration: textBoxDecoration(hint: "Search Vendor"),
                ),
              ),
              searchMatchFn: (item, searchValue) =>
                  item.value!.name!.toLowerCase().contains(searchValue.toLowerCase()),
            ),
          ),
          VerticalSpacing.d15px(),
        ],
      );
    });
  }

  Widget _buildMobileNumberField() => _textField(
    label: "Requestor Mobile No",
    controller: controller.mobileNoController,
    hint: "Mobile number",
    readOnly: true,
    validator: (text) {
      if (text == null || text.isEmpty) return 'Required';
      if (text.length != 10) return 'Mobile number must be 10 digits';
      return null;
    },
  );

  Widget _buildAddressField() => _textField(
    label: "Request Address",
    controller: controller.addressController,
    hint: "Address",
    readOnly: true,
    minLines: 2,
  );

  Widget _buildQuantityField() => _textField(
    label: "Quantity",
    controller: controller.quantityController,
    hint: "Enter quantity",
    keyboardType: TextInputType.number,
  );

  Widget _buildAmountField() => _textField(
    label: "Price",
    controller: controller.amountController,
    hint: "Enter Price",
    keyboardType: TextInputType.number,
  );

  Widget _buildRemarksField() => _textField(
    label: "Remarks",
    controller: controller.reMarksController,
    hint: "Enter remarks",
    minLines: 3,
  );



  Widget _buildDate(){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text("Date of Delivery",
          style: AppTextStyle.textFieldHeadingStyle,),

        TextFormField(
          controller: controller.dateController,
          decoration:textBoxDecoration(hint:"dd-MM-yyyy",
              suffixIcon: Icon(Icons.calendar_month,color: Colors.grey,)),
          readOnly: true,

          onTap: () async {
            String pickedDate = await selectDate(context);
            if (pickedDate.isNotEmpty) {
              controller.dateController.text = pickedDate;
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
      ],
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    int? minLines,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.textFieldHeadingStyle),
        VerticalSpacing.d5px(),
        TextFormField(
          readOnly: readOnly,
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: minLines != null ? null : 1,
          decoration: textBoxDecoration(hint: hint),
          validator: validator ??
                  (text) => (text == null || text.isEmpty) ? 'Required' : null,
        ),
        VerticalSpacing.d15px(),
      ],
    );
  }

  // 🔹 CATEGORY DROPDOWN
  Widget _buildCategoryDropdown() {
    return GetBuilder<NewRequestController>(builder: (ctrl) {
      if (ctrl.categories.isEmpty) return const SizedBox.shrink();
      return _dropDown(
        label: "Category",
        items: ctrl.categories,
        hint: "Select Category",
        onChanged: (value) => ctrl.selectedCategory.value = value,
      );
    });
  }

 // 🔹 UNIT DROPDOWN
  Widget _buildUnitDropdown() {
    return  GetBuilder<NewRequestController>(builder: (ctrl) {
      if (ctrl.units.isEmpty) return const SizedBox.shrink();
      return _dropDown(
        label: "Unit",
        items: ctrl.units,
        hint: "Select Unit",
        onChanged: (value) => ctrl.selectedUnit.value = value!,
      );
    });
  }

  // 🔹 VENDOR DROPDOWN (Reactive)
  Widget _buildattachemnt() {
    return  GetBuilder<NewRequestController>(builder: (ctrl) {
      if (ctrl.units.isNotEmpty) return const SizedBox.shrink();
      return  Column(
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
                },), VerticalSpacing.d5px(),

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
                  Text("Upload Drawing Image / Video"),
                ],
              ),
            ),


            VerticalSpacing.d15px(),
          ],
        );
    });
  }

  // 🔹 DELIVERY DROPDOWN
  Widget _buildDeliveryDropdown() {
    return _dropDown(
      label: "Delivery Needed By",
      items: ConstantData.deliveryNeededBy,
      hint: "Select Delivery Needed By",
      onChanged: (value) => controller.selectedDeliveryNeeded.value = value!,
    );
  }

  Widget _dropDown({
    required String label,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.textFieldHeadingStyle),
        VerticalSpacing.d5px(),
        DropdownButtonFormField2<String>(
          isExpanded: true,
          decoration: dropDownBoxDecoration(),
          hint: Text(hint, style: AppTextStyle.textHintText),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          validator: (value) => value == null ? 'Required' : null,
          onChanged: onChanged,
        ),
        VerticalSpacing.d15px(),
      ],
    );
  }


  Widget _buildSupervisorNameField() => _textField(
    label: "Supervisor Name",
    controller: controller.supervisorNameController,
    hint: "Supervisor Name",
    readOnly: true,
  );

  Widget _buildSupervisorMobField() => _textField(
    label: "Supervisor Mobile Num",
    controller: controller.supervisorMobController,
    hint: "Supervisor Mobile Num",
    readOnly: true,
  );


  Widget _buildSubmitButton() {
    return CommonButton(
      onTap: () {
        if (_formKey.currentState!.validate()) {
          controller.addMaterialApi(attachment,widget.type);
        }
      },
      text: "Submit",
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
