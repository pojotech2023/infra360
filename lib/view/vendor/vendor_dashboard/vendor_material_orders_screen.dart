import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';

import 'vendor_material_orders_controller.dart';
import 'vendor_payment_details.dart';
import 'vendor_payment_history/vendor_payment_history_screen.dart';

class VendorMaterialOrdersScreen extends StatefulWidget {
  const VendorMaterialOrdersScreen({Key? key}) : super(key: key);

  @override
  State<VendorMaterialOrdersScreen> createState() => _VendorMaterialOrdersScreenState();
}

class _VendorMaterialOrdersScreenState extends State<VendorMaterialOrdersScreen> {
  final int vendorId = Get.arguments as int;
  late final VendorMaterialOrdersController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(VendorMaterialOrdersController(vendorId: vendorId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Material Order Details",
          onTap: () {
            Get.back();
          }),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = controller.ordersData.value;
          final orders = data?.orders ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Breadcrumbs & Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Breadcrumb hidden as per requirements
                  // Expanded(
                  //   child: Text(
                  //     "Vendor Dashboard > ${data?.materialType ?? 'Material'} > ${data?.vendorName ?? 'Vendor'}",
                  //     style: AppTextStyle.textMedium.copyWith(color: AppColor.black, fontSize: 14),
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Get.to(() => VendorPaymentDetails(), arguments: vendorId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.buttonGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Text('Payment', style: AppTextStyle.textMedium.copyWith(color: AppColor.white)),
                      ),
                      HorizontalSpacing.d10px(),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(() => const VendorPaymentHistoryScreen(), arguments: vendorId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.buttonBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Text('Payment History', style: AppTextStyle.textMedium.copyWith(color: AppColor.white)),
                      ),
                    ],
                  ),
                ],
              ),
              VerticalSpacing.d20px(),

              // Table
              if (orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text("No material orders found")),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final item = orders[index];
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
                                const Text('Site Name: ', style: TextStyle(fontWeight: FontWeight.w600)),
                                Expanded(child: Text(item.siteName?.isNotEmpty == true ? item.siteName! : "N/A")),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Quantity: ', style: TextStyle(fontWeight: FontWeight.w600)),
                                Expanded(child: Text(item.quantity ?? "0")),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Amount: ', style: TextStyle(fontWeight: FontWeight.w600)),
                                Expanded(child: Text('₹${item.amount ?? "0"}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Bottom Totals
              Container(
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: const BoxDecoration(
                    color: AppColor.totalBGColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${data?.totalUnits ?? "0"} Unit', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(data?.totalAmount ?? "0", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }),
      ),
    );
  }


}
