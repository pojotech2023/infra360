import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/view/vendor/vendor_dashboard/vendor_payment_history/vendor_payment_history_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/view/vendor/vendor_dashboard/vendor_payment_history/add_vendor_payment_screen/add_vendor_payment_screen.dart';
import 'package:raptor_pro/view/widgets/log_out.dart';

class VendorPaymentHistoryScreen extends StatefulWidget {
  const VendorPaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<VendorPaymentHistoryScreen> createState() => _VendorPaymentHistoryScreenState();
}

class _VendorPaymentHistoryScreenState extends State<VendorPaymentHistoryScreen> {

  VendorPaymentHistoryController controller = Get.put(VendorPaymentHistoryController());

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
            padding: const EdgeInsets.all(16),
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
                        : () => controller.vendorPaymentHistoryExport(context),
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

              // Table
              // Table
              if (historyList.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text("No payment history found")),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                                const Text('Total Payment: ', style: TextStyle(fontWeight: FontWeight.w600)),
                                Expanded(child: Text('₹${item.payment ?? "0"}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Payment Mode: ', style: TextStyle(fontWeight: FontWeight.w600)),
                                Expanded(child: Text((item.paymentMode == null || item.paymentMode!.isEmpty) ? "N/A" : item.paymentMode!)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Remarks: ', style: TextStyle(fontWeight: FontWeight.w600)),
                                Expanded(child: Text((item.remarks == null || item.remarks!.isEmpty) ? "-" : item.remarks!)),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    final result = await Get.to(() => AddVendorPaymentScreen(), arguments: {
                                      'isEditMode': true, 
                                      'item': item, 
                                      'vendorId': Get.arguments
                                    });
                                    if (result == true) {
                                      controller.init(); // Refresh list on return
                                    }
                                  },
                                  child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                ),
                                const SizedBox(width: 16),
                                InkWell(
                                  onTap: () {
                                    deleteDialog(context, () {
                                      controller.deletePayment(item.id!);
                                    });
                                  },
                                  child: const Icon(Icons.delete, color: Colors.red, size: 20),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
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


}