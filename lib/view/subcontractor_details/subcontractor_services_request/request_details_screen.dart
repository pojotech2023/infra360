import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';

import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/view/widgets/custom_date_picker.dart';

import '../../../model/subcontractor_amount_model.dart';
import '../../../model/subcontractor_list_model.dart';

import 'request_details_controller.dart';
import 'new_services_request_screen.dart';

class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({super.key});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {

  final SubcontracorDetailsArgs args = Get.arguments as SubcontracorDetailsArgs;

  final RequestDetailsController controller = Get.put(RequestDetailsController(materialDetailsArgs:Get.arguments));


  void _pickMonth() async {
    final result = await showCustomMonthPicker(context, controller.selectedYear.value,initialMonth:
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          Get.to(NewServiceRequestScreen(),arguments: args);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.buttonBlue.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7), // rounded corners
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        child: Text('Add Service',
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
                  )
                ],
              ),
            ),
            GetBuilder<RequestDetailsController>(builder: (controller) {
              if (controller.listModel.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text("No ${capitalize(args.itemKey)} list found this Site.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                  ),
                );
              }
              return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.listModel.length,
              itemBuilder: (context, index) {
                final item = controller.listModel[index];
                String formattedDate = '';
                try {
                  if (item.date != null && item.date!.isNotEmpty) {
                    final dt = DateTime.parse(item.date!);
                    formattedDate = DateFormat('dd-MM-yyyy').format(dt);
                  }
                } catch (_) {
                  formattedDate = item.date ?? '';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('S.NO: ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Subcontractor: ', style: TextStyle(fontWeight: FontWeight.w600)),
                            Expanded(child: Text(item.subcontractor?.name ?? item.subcontractorType ?? '')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Amount: ', style: TextStyle(fontWeight: FontWeight.w600)),
                            Expanded(child: Text('₹${item.amount?.toString() ?? "0"}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        if (item.remarks != null && item.remarks!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Remarks: ', style: TextStyle(fontWeight: FontWeight.w600)),
                              Expanded(child: Text(item.remarks!)),
                            ],
                          ),
                        ],
                        if (item.id != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    _showEditServiceDialog(context, item);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Confirm Delete"),
                                        content: const Text("Are you sure you want to delete this service record?"),
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
                                              controller.deleteService(item.id!);
                                            },
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            );
          }),

      GetBuilder<RequestDetailsController>(builder: (controllers){
             // final Subcontractor = controller.SubcontractorModel?.value;
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
                        Text('TOTAL AMOUNT',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.buttonBlue)),
                        Text('${controllers.model.totalAmount ?? "0"}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.buttonBlue)),
                      ],
                    ),
                  ),
                  // Settled Amount row

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
                controller.excelDownload(context, fromDate: fromDateCtrl.text, toDate: toDateCtrl.text);
              },
              child: Text("Download"),
            ),
          ],
        );
      },
    );
  }

  void _showEditServiceDialog(BuildContext context, Subcontractors item) {
    TextEditingController dateCtrl = TextEditingController(text: item.date);
    TextEditingController amountCtrl = TextEditingController(text: item.amount ?? '');
    TextEditingController remarksCtrl = TextEditingController(text: item.remarks ?? '');
    TextEditingController noCountsCtrl = TextEditingController(text: item.noCounts ?? '');

    Future<void> selectDate(TextEditingController ctrl) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.tryParse(item.date ?? '') ?? DateTime.now(),
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
          title: Text("Edit Service"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dateCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Date",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => selectDate(dateCtrl),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Amount"),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: noCountsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "No. of Workers"),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: remarksCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: "Remarks"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(backgroundColor: Colors.indigo.shade400),
              child: Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> data = {
                  "date": dateCtrl.text,
                  "amount": amountCtrl.text,
                  "remarks": remarksCtrl.text,
                  "no_counts": noCountsCtrl.text,
                  "site_id": controller.materialDetailsArgs?.id.toString() ?? '',
                  "subcontractor_id": item.subcontractorId?.toString() ?? '',
                  "subcontractor_type": item.subcontractorType ?? '',
                };
                Navigator.pop(dialogContext);
                controller.updateService(item.id!, data);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTableHeader() {
    return Container(
      width: 800,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      decoration: BoxDecoration(
          color: AppColor.tableBGColor,
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          )),
      child: Row(
        children: [
          _buildCell('S.NO', bold: true),
          _buildCell('DATE', flex: 2, bold: true),
          _buildCell('SUBCONTRACTOR', flex: 3, bold: true),
          _buildCell('AMOUNT', flex: 2, bold: true, align: TextAlign.center),
          _buildCell('REMARKS', flex: 3, bold: true),
          _buildCell('ACTION', flex: 2, bold: true, align: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, String> item, {Subcontractors? serviceItem}) {
    return Container(
      width: 800,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        color: AppColor.tableBGColor,
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      child: Row(
        children: [
          _buildCell(item['id']!),
          _buildCell(item['date']!, flex: 2),
          _buildCell(item['subcontractor']!.isEmpty ? "N/A" : item['subcontractor']!, flex: 3),
          _buildCell(item['amount']!, flex: 2, align: TextAlign.center, bold: true),
          _buildCell(item['remarks']!.isEmpty ? "N/A" : item['remarks']!, flex: 3),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    if (serviceItem != null) {
                      _showEditServiceDialog(context, serviceItem);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Icon(Icons.edit, size: 16, color: Colors.blue),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    if (serviceItem?.id != null) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text("Confirm Delete"),
                          content: Text("Are you sure you want to delete this service record?"),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue.shade400,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                controller.deleteService(serviceItem!.id!);
                              },
                              child: Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Icon(Icons.delete, size: 16, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {int flex = 1, bool bold = false, TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          textAlign: align,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w400,
              color: AppColor.black,
              fontSize: 13),
        ),
      ),
    );
  }
}
