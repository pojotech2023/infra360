import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/model/other_utilities_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/material_category/other_material/others_material_controller.dart';
import 'package:raptor_pro/view/subcontractor_details/other_subcontractor_screen/others_subcontractor_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';

class OtherSubcontractorView extends StatefulWidget{
  @override
  State<OtherSubcontractorView> createState() => _OtherSubcontractorViewState();
}

class _OtherSubcontractorViewState extends State<OtherSubcontractorView> {
 var controller = Get.find<OthersSubcontractorController>();
 int ?siteId;
  @override
  void initState() {
    // TODO: implement initState
    siteId =Get.arguments;
    controller.otherUtilitiesView(siteId!);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Others",
          onTap: () {
            Get.back();
          }),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.otherUtilitiesExcelDownload(context, siteId!);
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
            VerticalSpacing.d20px(),
            Obx(() {
              return ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: controller.otherUtilitiesData.length,
                itemBuilder: (context, index) {
                  final data = controller.otherUtilitiesData[index];
                  return _buildCard(
                    id: (index + 1).toString(),
                    date: data.createdAt != null ? data.createdAt!.split('T').first : '',
                    amount: data.amount ?? '0',
                    remarks: data.remarks ?? '',
                    imageUrl: data.image,
                    dataItem: data,
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      width: 800, // wider for more columns including image
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
          _buildCell('S.No', flex: 1, bold: true),
          _buildCell('Date', flex: 2, bold: true),
          _buildCell('Amount', flex: 2, bold: true, align: TextAlign.center),
          _buildCell('Remarks', flex: 3, bold: true),
          _buildCell('Image', flex: 2, bold: true, align: TextAlign.center),
          _buildCell('Action', flex: 2, bold: true, align: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    required String id,
    required String date,
    required String amount,
    required String remarks,
    String? imageUrl,
    bool isEven = false,
    OtherUtilitiesData? dataItem,
  }) {
    return Container(
      width: 800,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        color: isEven ? AppColor.white : AppColor.tableBGColor,
      ),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCell(id, flex: 1),
          _buildCell(date, flex: 2),
          _buildCell(amount, flex: 2, align: TextAlign.center, bold: true),
          _buildCell(remarks.isEmpty ? "N/A" : remarks, flex: 3),
          Expanded(
            flex: 2,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        // View Image logic if needed
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          Uri.encodeFull( "${baseUrl}images/${imageUrl}"),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 24),
                        ),
                      ),
                    ),
                  )
                : Text("No Image", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    if (dataItem != null) {
                      final amountCtrl = TextEditingController(text: dataItem.amount);
                      final remarksCtrl = TextEditingController(text: dataItem.remarks);
                      final dateCtrl = TextEditingController(text: dataItem.createdAt?.split('T').first ?? '');
                      
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text("Edit Record"),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(controller: dateCtrl, decoration: InputDecoration(labelText: "Date (YYYY-MM-DD)")),
                                TextField(controller: amountCtrl, decoration: InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
                                TextField(controller: remarksCtrl, decoration: InputDecoration(labelText: "Remarks"), maxLines: 3),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text("Cancel")),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                controller.updateOtherUtility(dataItem.id!, siteId!, amountCtrl.text, remarksCtrl.text, dateCtrl.text);
                              }, 
                              child: Text("Save")
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)),
                    child: Icon(Icons.edit, size: 16, color: Colors.blue),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    if (dataItem?.id != null) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text("Confirm Delete"),
                          content: Text("Are you sure you want to delete this record?"),
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
                                controller.deleteOtherUtility(dataItem!.id!, siteId!);
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
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)),
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
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          text,
          textAlign: align,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w400,
              color: AppColor.black,
              fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String id,
    required String date,
    required String amount,
    required String remarks,
    String? imageUrl,
    OtherUtilitiesData? dataItem,
  }) {
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
                'S.No: $id',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF252C58),
                  fontSize: 14,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: Color(0xFF6E6B7B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildCardRow('Amount', amount),
          SizedBox(height: 8),
          _buildCardRow('Remarks', remarks.isEmpty ? 'N/A' : remarks),
          SizedBox(height: 12),
          if (imageUrl != null && imageUrl.isNotEmpty)
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  Uri.encodeFull("${baseUrl}images/${imageUrl}"),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
          if (imageUrl != null && imageUrl.isNotEmpty) SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  if (dataItem != null) {
                    final amountCtrl = TextEditingController(text: dataItem.amount);
                    final remarksCtrl = TextEditingController(text: dataItem.remarks);
                    final dateCtrl = TextEditingController(text: dataItem.createdAt?.split('T').first ?? '');
                    
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("Edit Record"),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(controller: dateCtrl, decoration: InputDecoration(labelText: "Date (YYYY-MM-DD)")),
                              TextField(controller: amountCtrl, decoration: InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
                              TextField(controller: remarksCtrl, decoration: InputDecoration(labelText: "Remarks"), maxLines: 3),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text("Cancel")),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              controller.updateOtherUtility(dataItem.id!, siteId!, amountCtrl.text, remarksCtrl.text, dateCtrl.text);
                            }, 
                            child: Text("Save")
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.edit, size: 18, color: Colors.blue),
                ),
              ),
              SizedBox(width: 12),
              InkWell(
                onTap: () {
                  if (dataItem?.id != null) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("Confirm Delete"),
                        content: Text("Are you sure you want to delete this record?"),
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
                              controller.deleteOtherUtility(dataItem!.id!, siteId!);
                            },
                            child: Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.delete, size: 18, color: Colors.red),
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
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF252C58),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}