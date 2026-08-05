import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_dashboard/subcontractor_payment_history/subcontractor_payment_history_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/view/widgets/log_out.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_dashboard/subcontractor_payment_history/add_subcontractor_payment_screen/add_subcontractor_payment_screen.dart';

class SubcontractorPaymentHistoryScreen extends StatefulWidget {
  const SubcontractorPaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SubcontractorPaymentHistoryScreen> createState() => _SubcontractorPaymentHistoryScreenState();
}

class _SubcontractorPaymentHistoryScreenState extends State<SubcontractorPaymentHistoryScreen> {

  SubcontractorPaymentHistoryController controller = Get.put(SubcontractorPaymentHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Payment History",
          onTap: () {
            Get.back();
          }),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CommonLoader());
          }

          final historyList = controller.paymentHistoryData.value.paymentHistoryList ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Export Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() => ElevatedButton.icon(
                    onPressed: controller.isExporting.value
                        ? null
                        : () => controller.subcontractorPaymentHistoryExport(context),
                    icon: controller.isExporting.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.file_download, size: 18, color: Colors.white),
                    label: Text(
                      controller.isExporting.value ? 'Exporting...' : 'Export Excel',
                      style: AppTextStyle.textMedium.copyWith(color: AppColor.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 16),

              // Card List
              if (historyList.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("No payment history found", style: AppTextStyle.textRegular15),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final item = historyList[index];

                    String formattedDate = item.date ?? '';
                    try {
                      if (formattedDate.isNotEmpty) {
                        final dt = DateTime.parse(formattedDate);
                        formattedDate = DateFormat('dd-MM-yyyy').format(dt);
                      }
                    } catch (_) {}

                    return _buildCard(item, formattedDate, index + 1);
                  },
                ),

              // Total Amount
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColor.tableBGColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount",
                      style: AppTextStyle.textMedium.copyWith(
                          color: AppColor.buttonLightBlue, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${controller.paymentHistoryData.value.totalPaidAmount ?? "0"}",
                      style: AppTextStyle.textBold.copyWith(color: AppColor.buttonLightBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      width: 650,
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
          _buildCell('S.NO', flex: 1, bold: true),
          _buildCell('DATE', flex: 2, bold: true),
          _buildCell('TOTAL PAYMENT', flex: 2, bold: true, align: TextAlign.center),
          _buildCell('PAYMENT MODE', flex: 2, bold: true, align: TextAlign.center),
          _buildCell('REMARKS', flex: 2, bold: true),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, String> item, {bool isEven = false}) {
    return Container(
      width: 650,
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
          _buildCell(item['payment']!, flex: 2, align: TextAlign.center, bold: true),
          _buildCell(item['mode']!.isEmpty ? 'N/A' : item['mode']!, flex: 2, align: TextAlign.center),
          _buildCell(item['remarks']!.isEmpty ? '-' : item['remarks']!, flex: 2),
        ],
      ),
    );
  }

  Widget _buildCell(String text,
      {int flex = 1, bool bold = false, TextAlign align = TextAlign.left}) {
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

  Widget _buildCard(dynamic item, String formattedDate, int index) {
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
              Text(
                formattedDate,
                style: TextStyle(
                  color: Color(0xFF6E6B7B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildCardRow('Total Payment', item.payment ?? '0'),
          SizedBox(height: 8),
          _buildCardRow('Payment Mode', item.paymentMode?.isEmpty == true ? 'N/A' : item.paymentMode ?? 'N/A'),
          SizedBox(height: 8),
          _buildCardRow('Remarks', item.remarks?.isEmpty == true ? '-' : item.remarks ?? '-'),
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () async {
                  final result = await Get.to(() => AddSubcontractorPaymentScreen(), arguments: {
                    'isEditMode': true,
                    'item': item,
                    'subcontractorId': Get.arguments
                  });
                  if (result == true) {
                    controller.init(); // Refresh list on return
                  }
                },
                child: Icon(Icons.edit, color: Colors.blue, size: 20),
              ),
              SizedBox(width: 16),
              InkWell(
                onTap: () {
                  deleteDialog(Get.context!, () {
                    controller.deletePayment(item.id!);
                  });
                },
                child: Icon(Icons.delete, color: Colors.red, size: 20),
              ),
            ],
          )
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
