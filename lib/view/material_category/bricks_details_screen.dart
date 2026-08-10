import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/model/login_response.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/model/bricks_model.dart';
import 'package:raptor_pro/service/shared_preference_service.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';

import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/view/widgets/custom_date_picker.dart';
import 'dart:io';
import '../../utils/file_picker_helper.dart';
import '../../utils/file_preview.dart';
import '../../utils/res/date_picker.dart';
import 'bricks_details_controller.dart';
import 'new_bricks/new_request_screen.dart';

class BricksDetailsScreen extends StatefulWidget {
  const BricksDetailsScreen({super.key});

  @override
  State<BricksDetailsScreen> createState() => _BricksDetailsScreenState();
}

class _BricksDetailsScreenState extends State<BricksDetailsScreen> {

  final MaterialDetailsArgs args = Get.arguments as MaterialDetailsArgs;

  final BricksDetailsController controller = Get.put(BricksDetailsController(materialDetailsArgs:Get.arguments));

  String _role = '';
  bool get _isSupervisor => _role == 'supervisor';

  @override
  void initState() {
    // Note: BricksDetailsController.onInit() already calls fetchData()
    // We only need to read the role here
    try {
      final data = jsonDecode(PreferenceUtils().getUserInfo());
      final userDetails = LoginResponse.fromJson(data);
      _role = userDetails.data?.role?.toLowerCase() ?? '';
      print("👤 [BricksDetailsScreen] role=$_role");
    } catch (e) {
      print("❌ [BricksDetailsScreen] Could not read role: $e");
    }
    super.initState();
  }


  void _pickMonth() async {
    final result = await showCustomMonthPicker(context, controller.selectedYear.value, initialMonth:
    controller.selectedMonth.value);
    if (result != null) {
      final parts = result.split("-");
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      controller.onMonthSelected(year, month);
    }
  }
  @override
  Widget build(BuildContext context) {



    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "${capitalize(args.itemKey)} Details",
          onTap: () {
            Get.back();
          }),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
            Obx((){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: ()async{
                      _pickMonth();
                    },
                    child: Container(
                        width: 150,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColor.materialCategoryBorderColor,
                              width: 1),
                        ),
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                controller.selectedMonthText.value ?? "Select Month",
                                style: TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down, size: 20)
                          ],
                        )
                    ),
                  ),
                  VerticalSpacing.custom(value: 12),
                  SizedBox(
                    height: 35,
                    child: ListView.separated(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context,int index){
                        return
                          Obx(()=>InkWell(
                            onTap: (){
                              controller.onWeekSelected(index + 1);
                            },
                            child: Container(
                              width: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color:
                                  controller.selectedWeek.value==index+1?
                                  AppColor.buttonBlue:AppColor.black,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child: Text("W${index+1}",
                                style: TextStyle(color: AppColor.white),),
                            ),
                          ));

                      }, separatorBuilder: (BuildContext context, int index) {
                      return Padding(padding: EdgeInsets.only(right: 8));
                    },),
                  ),
                ],
              );
            }),

            VerticalSpacing.d20px(),
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await Get.to(()=>NewRequestScreen(type: 1,),arguments: args);
                              controller.fetchData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.buttonBlue.withValues(alpha: 0.7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            child: Text('Request',
                                style: AppTextStyle.textMedium
                                    .copyWith(color: AppColor.white)),
                          ),

                          HorizontalSpacing.d5px(),

                          // Inward Order Button (Blue)
                          ElevatedButton(
                            onPressed: () async {
                              await Get.to(()=>NewRequestScreen(type: 2,),arguments: args);
                              controller.fetchData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.buttonBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            child: Text('Inward Order',
                                style: AppTextStyle.textMedium
                                    .copyWith(color: AppColor.white)),
                          ),

                          HorizontalSpacing.d5px(),

                          ElevatedButton(
                            onPressed: () {
                              _showExportDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            child: Text('Export', style: AppTextStyle.textMedium.copyWith(color: AppColor.white)),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Obx(() {
              final list = controller.getBricksLists;
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text("No ${capitalize(args.itemKey)} list found this Site.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  String formattedDate = '';
                  try {
                    if (item.date != null && item.date!.isNotEmpty) {
                      final dt = DateTime.parse(item.date!);
                      formattedDate = DateFormat('dd-MM-yyyy').format(dt);
                    }
                  } catch (_) {
                    formattedDate = item.date ?? '';
                  }
                  return _buildCard(item, formattedDate, index + 1);
                },
              );
            }),

            Obx((){
              final bricks = controller.bricksModel?.value;
            return  Container(
              margin: EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // TOTAL row
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColor.totalBGColor, // light blue background
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:  [
                        Text('TOTAL',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(' ${bricks?.totalUnits ?? "0"} Unit',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${bricks?.totalAmount ?? "0"}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // Settled Amount row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Settled Amount',
                            style: AppTextStyle.textRegular15
                                .copyWith(color: AppColor.buttonGreen)),
                        Text('${bricks?.settledAmount ?? "0"}',
                            style: AppTextStyle.textRegular15
                                .copyWith(color: AppColor.buttonGreen))
                      ],
                    ),
                  ),
                  // Pending Amount row
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColor.pendingBGColorr, // light background
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      border:
                          Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pending Amount',
                            style: AppTextStyle.textRegular15
                                .copyWith(color: AppColor.red)),
                        Text('${bricks?.pendingAmount ?? "0"}',
                            style: AppTextStyle.textRegular15
                                .copyWith(color: AppColor.red)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          ],
        ),
      ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    TextEditingController fromDateCtrl = TextEditingController();
    TextEditingController toDateCtrl = TextEditingController();

    Future<void> selectDate(TextEditingController ctrl) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        ctrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Export ${capitalize(args.itemKey)} Report"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: fromDateCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "From Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => selectDate(fromDateCtrl),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: toDateCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "To Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => selectDate(toDateCtrl),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (fromDateCtrl.text.isEmpty || toDateCtrl.text.isEmpty) {
                  Get.snackbar("Error", "Please select both From Date and To Date");
                  return;
                }
                Navigator.pop(dialogContext);
                controller.materialExcelDownload(context, fromDate: fromDateCtrl.text, toDate: toDateCtrl.text);
              },
              child: Text("Download"),
            ),
          ],
        );
      },
    );
  }

  void _showEditOrderDialog(BuildContext context, BricksList item) {
    TextEditingController dateCtrl = TextEditingController(text: formatDate(item.date ?? ''));
    TextEditingController quantityCtrl = TextEditingController(text: item.quantity);
    TextEditingController priceCtrl = TextEditingController(text: item.price?.toString() ?? '0');
    TextEditingController gstCtrl = TextEditingController(text: item.gst?.toString() ?? '0');
    File? attachment;
    bool removeExistingImage = false;

    Future<void> selectDate(TextEditingController ctrl) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.tryParse(item.date ?? '') ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        ctrl.text = DateFormat('dd-MM-yyyy').format(picked);
      }
    }

    void showAttachmentOptions(BuildContext ctx, StateSetter setState) {
      showModalBottomSheet(
        context: ctx,
        builder: (_) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Pick Image'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await FilePickerHelper.pickImage();
                  if (file != null) {
                    setState(() => attachment = file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Capture Photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await FilePickerHelper.pickImage(fromCamera: true);
                  if (file != null) {
                    setState(() => attachment = file);
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Order"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: dateCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Date",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => selectDate(dateCtrl),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Quantity"),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Price"),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: gstCtrl,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(labelText: "GST"),
                    ),
                    const SizedBox(height: 16),
                    if (attachment != null)
                      FilePreview(
                        file: attachment!,
                        isImage: true,
                        onRemove: () {
                          setState(() {
                            attachment = null;
                          });
                        },
                      )
                    else if (!removeExistingImage && item.imageUrl != null && item.imageUrl!.isNotEmpty)
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(item.imageUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                removeExistingImage = true;
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                              child: const Icon(Icons.cancel, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => showAttachmentOptions(context, setState),
                      child: const Text("Upload Image"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(backgroundColor: Colors.indigo.shade400),
                  child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Map<String, dynamic> data = {
                      "material_type": args.itemKey.toString().toLowerCase(),
                      "date": dateCtrl.text,
                      "quantity": quantityCtrl.text,
                      "price": priceCtrl.text,
                      "amount": priceCtrl.text, // Added to match some backend flows
                      "gst": gstCtrl.text.isNotEmpty ? gstCtrl.text : "0",
                      "gst_amount": gstCtrl.text.isNotEmpty ? gstCtrl.text : "0",
                      "vendor_gst": gstCtrl.text.isNotEmpty ? gstCtrl.text : "0",
                      "tax": gstCtrl.text.isNotEmpty ? gstCtrl.text : "0",
                      "site_id": controller.materialDetailsArgs?.id.toString() ?? '',
                      "vendor_id": item.vendorId?.toString() ?? '',
                      "unit": item.unit ?? '',
                      if (removeExistingImage) "remove_image": "1",
                    };
                    Navigator.pop(dialogContext);
                    controller.updateMaterial(item.id!, data, attachment: attachment);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
                  child: const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTableHeader() {
    return Container(
      width: _isSupervisor ? 600 : 700, // Fixed width for horizontal scrolling
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      decoration: BoxDecoration(
          color: AppColor.tableBGColor,
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          )),
      child: Row(
        children: [
          _buildCell('S.No', flex: 1, bold: true),
          _buildCell('Date', flex: 2, bold: true),
          _buildCell('Quantity', flex: 2, bold: true, align: TextAlign.center),
          _buildCell('Vendor', flex: 2, bold: true),
          _buildCell('Price', flex: 2, bold: true, align: TextAlign.right),
          _buildCell('GST', flex: 2, bold: true, align: TextAlign.right),
          _buildCell('Image', flex: 2, bold: true, align: TextAlign.center),
          _buildCell('Image', flex: 2, bold: true, align: TextAlign.center),
          if (_isSupervisor)
            _buildCell('Status', flex: 2, bold: true, align: TextAlign.center),
          _buildCell('Action', flex: 2, bold: true, align: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, String> item, {bool isEven = false, BricksList? bricksItem}) {
    return Container(
      width: _isSupervisor ? 600 : 700,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        color: isEven ? AppColor.white : AppColor.tableBGColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCell(item['id']!, flex: 1),
          _buildCell(item['date']!, flex: 2),
          _buildCell(item['unit']!, flex: 2, align: TextAlign.center, bold: true),
          _buildCell(item['vendor']!.isEmpty ? "N/A" : item['vendor']!, flex: 2),
          _buildCell(item['price']!, flex: 2, align: TextAlign.right, bold: true),
          _buildCell(item['gst'] ?? "0", flex: 2, align: TextAlign.right, bold: true),
          Expanded(
            flex: 2,
            child: Center(
              child: bricksItem?.imageUrl != null && bricksItem!.imageUrl!.isNotEmpty
                  ? Image.network(
                      bricksItem.imageUrl!,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                    )
                  : const Text('-', style: TextStyle(color: Colors.grey)),
            ),
          ),

          if (_isSupervisor)
            Expanded(
              flex: 2,
              child: Center(child: _buildStatusBadge(bricksItem?.status)),
            ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    if (bricksItem != null) _showEditOrderDialog(context, bricksItem);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    if (bricksItem?.id != null) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Confirm Delete"),
                          content: Text("Are you sure you want to delete this ${capitalize(args.itemKey)} record?"),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue.shade400,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                controller.deleteMaterial(bricksItem!.id!);
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.delete, size: 16, color: Colors.red),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    if (bricksItem?.id != null) {
                      controller.materialPdfDownload(context, bricksItem!.id!);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Status badge widget for supervisor view — accepts int or String status
  Widget _buildStatusBadge(dynamic status) {
    Color badgeColor;
    String label;

    // Normalize: int status (0=pending, 1=approved, 2=rejected) or string
    String statusStr = '';
    if (status is int) {
      statusStr = status == 1 ? 'approved' : status == 2 ? 'rejected' : 'pending';
    } else {
      statusStr = (status?.toString() ?? 'pending').toLowerCase().trim();
    }

    switch (statusStr) {
      case 'approved':
      case '1':
        badgeColor = Colors.green;
        label = 'Approved';
        break;
      case 'rejected':
      case '2':
        badgeColor = Colors.red;
        label = 'Rejected';
        break;
      default:
        badgeColor = Colors.orange;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCell(String text, {int flex = 1, bool bold = false, TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          text,
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w400,
              color: AppColor.black,
              fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCard(BricksList item, String formattedDate, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'S.No: $index',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF252C58),
                  fontSize: 14,
                ),
              ),
              if (_isSupervisor)
                _buildStatusBadge(item.status),
            ],
          ),
          SizedBox(height: 12),
          _buildCardRow('Date', formattedDate),
          SizedBox(height: 8),
          _buildCardRow('Quantity', item.quantity ?? '0'),
          SizedBox(height: 8),
          _buildCardRow('Vendor', item.vendorName?.isEmpty == true ? 'N/A' : item.vendorName ?? 'N/A'),
          SizedBox(height: 8),
          _buildCardRow('Price', item.price?.toString() ?? '0'),
          SizedBox(height: 8),
          _buildCardRow('GST', item.gst?.toString() ?? '0'),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Image',
                style: TextStyle(
                  color: Color(0xFF5E5873),
                  fontSize: 13,
                ),
              ),
              item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
                    )
                  : const Text('-', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () async {
                  _showEditOrderDialog(context, item);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.edit, size: 18, color: Colors.blue),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  if (item.id != null) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Confirm Delete"),
                        content: Text("Are you sure you want to delete this ${capitalize(args.itemKey)} record?"),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue.shade400,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              controller.deleteMaterial(item.id!);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.delete, size: 18, color: Colors.red),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  if (item.id != null) {
                    controller.materialPdfDownload(context, item.id!);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.picture_as_pdf, size: 18, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF5E5873),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF252C58),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

