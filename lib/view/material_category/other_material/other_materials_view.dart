import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/utils/url_helper.dart';
import 'package:raptor_pro/model/other_utilities_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/material_category/other_material/others_material_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';

class OtherMaterialView extends StatefulWidget{
  @override
  State<OtherMaterialView> createState() => _OtherMaterialViewState();
}

class _OtherMaterialViewState extends State<OtherMaterialView> {
 var othersMaterialController = Get.find<OthersMaterialController>();
 int ?siteId;
  @override
  void initState() {
    // TODO: implement initState
    siteId =Get.arguments;
    othersMaterialController.otherUtilitiesView(siteId!);
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
                    othersMaterialController.otherUtilitiesExcelDownload(context, siteId!);
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
                itemCount: othersMaterialController.otherUtilitiesData.length,
                itemBuilder: (context, index) {
                  final data = othersMaterialController.otherUtilitiesData[index];
                  String displayDate = '';
                  if (data.createdAt != null) {
                    final raw = data.createdAt!.split('T').first;
                    final parts = raw.split('-');
                    if (parts.length == 3) {
                      displayDate = "${parts[2]}-${parts[1]}-${parts[0]}";
                    } else {
                      displayDate = raw;
                    }
                  }
                  
                  return _buildCard(
                    id: (index + 1).toString(),
                    date: displayDate,
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
                  UrlHelper.getFullImageUrl(imageUrl),
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
                    String editDate = dataItem.createdAt?.split('T').first ?? '';
                    if (editDate.contains('-')) {
                      final parts = editDate.split('-');
                      if (parts.length == 3) {
                        editDate = "${parts[2]}-${parts[1]}-${parts[0]}";
                      }
                    }
                    final dateCtrl = TextEditingController(text: editDate);
                    
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("Edit Record"),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(controller: dateCtrl, decoration: InputDecoration(labelText: "Date (DD-MM-YYYY)")),
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
                              othersMaterialController.updateOtherUtility(dataItem.id!, siteId!, amountCtrl.text, remarksCtrl.text, dateCtrl.text);
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
                              othersMaterialController.deleteOtherUtility(dataItem!.id!, siteId!);
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