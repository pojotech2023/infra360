import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_dashboard/subcontractor_payment/subcontractor_payment_screen.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_dashboard/subcontractor_payment_history_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

class SubContractorPaymentHistoryScreen extends StatefulWidget {
  const SubContractorPaymentHistoryScreen({super.key});

  @override
  State<SubContractorPaymentHistoryScreen> createState() =>
      _SubContractorPaymentHistoryScreenState();
}

class _SubContractorPaymentHistoryScreenState
    extends State<SubContractorPaymentHistoryScreen> {
  final SubContractorPaymentHistoryController controller =
  Get.put(SubContractorPaymentHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: "Payment History",
        onTap: () => Get.back(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.buttonLightBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Get.to(
                () => AddSubContractorPaymentScreen(),
            arguments: controller.argData,
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTableHeader(),

            /// 🔹 Payment History List
            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: CommonLoader(),
                );
              }

              final list =
                  controller.subContractorData.value.paymentHistoryList;

              if (list == null || list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No payment history available",
                    style: AppTextStyle.textMedium
                        .copyWith(color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: list.map((item) {
                  return _buildTableRow({
                    'name': item.subcontractor!.name ?? '',
                    'date': item.date ?? '',
                    'payment': item.payment ?? '',
                    'mode': item.paymentMode ?? '',
                  });
                }).toList(),
              );
            }),

            /// 🔹 Total Amount
            Obx(() {
              return Container(
                height: 50,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Total Amount: ",
                      style: AppTextStyle.textMedium.copyWith(
                        color: AppColor.buttonLightBlue,
                      ),
                    ),
                    Text(
                      controller.subContractorData.value.totalPaidAmount
                          ?.toString() ??
                          "0",
                      style: AppTextStyle.textBold.copyWith(
                        color: AppColor.buttonLightBlue,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 🔹 Table Header
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      decoration: BoxDecoration(
        color: AppColor.tableBGColor,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          _buildCell('Name', bold: true),
          _buildCell('Date', bold: true),
          _buildCell('Payment', bold: true),
          _buildCell('Mode', bold: true),
        ],
      ),
    );
  }

  /// 🔹 Table Row
  Widget _buildTableRow(Map<String, String> item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      decoration: BoxDecoration(
        color: AppColor.tableBGColor,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          _buildCell(item['name']!),
          _buildCell(item['date']!),
          _buildCell(item['payment']!),
          _buildCell(item['mode']!),
        ],
      ),
    );
  }

  /// 🔹 Table Cell
  Widget _buildCell(String text, {bool bold = false}) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.w400,
          fontSize: 13,
          color: AppColor.black,
        ),
      ),
    );
  }
}
