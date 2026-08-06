import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';

import 'subcontractor_material_orders_controller.dart';
import 'subcontractor_payment_details.dart';
import 'subcontractor_payment_history/subcontractor_payment_history_screen.dart';
import 'package:raptor_pro/view/dashboard/dashboard_controller.dart';

class SubcontractorMaterialOrdersScreen extends StatefulWidget {
  const SubcontractorMaterialOrdersScreen({Key? key}) : super(key: key);

  @override
  State<SubcontractorMaterialOrdersScreen> createState() => _SubcontractorMaterialOrdersScreenState();
}

class _SubcontractorMaterialOrdersScreenState extends State<SubcontractorMaterialOrdersScreen> {
  final int subcontractorId = Get.arguments as int;
  late final SubcontractorMaterialOrdersController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SubcontractorMaterialOrdersController(subcontractorId: subcontractorId));
  }

  bool canViewPayment() {
    DashboardController dashboardController = Get.find<DashboardController>();
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.subcontractorManagement?.viewAmount == 1;
  }

  bool canViewPaymentHistory() {
    DashboardController dashboardController = Get.find<DashboardController>();
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.subcontractorManagement?.paymentHistory == 1;
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
                  //     "Subcontractor Dashboard > ${data?.materialType ?? 'Material'} > ${data?.subcontractorName ?? 'Subcontractor'}",
                  //     style: AppTextStyle.textMedium.copyWith(color: AppColor.black, fontSize: 14),
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ),
                  Row(
                    children: [
                      if (canViewPayment())
                        ElevatedButton(
                          onPressed: () {
                            Get.to(() => SubcontractorPaymentDetails(), arguments: subcontractorId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.buttonGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text('Payment', style: AppTextStyle.textMedium.copyWith(color: AppColor.white)),
                        ),
                      if (canViewPayment()) HorizontalSpacing.d10px(),
                      if (canViewPaymentHistory())
                        ElevatedButton(
                          onPressed: () {
                            Get.to(() => SubcontractorPaymentHistoryScreen(), arguments: subcontractorId);
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

              // Card List
              if (orders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("No material orders found"),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  primary: false,
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

                    return _buildCard(item, formattedDate, index + 1);
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
                      Text('${data?.totalUnits ?? "0"} Counts', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildTableHeader() {
    return Container(
      width: 600,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      decoration: BoxDecoration(
          color: AppColor.tableBGColor,
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Row(
        children: [
          _buildCell('S.NO', flex: 1, bold: true),
          _buildCell('DATE', flex: 2, bold: true),
          _buildCell('SITE NAME', flex: 3, bold: true),
          _buildCell('COUNTS', flex: 2, bold: true, align: TextAlign.center),
          _buildCell('AMOUNT', flex: 2, bold: true, align: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, String> item, {bool isEven = false}) {
    return Container(
      width: 600,
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
          _buildCell(item['siteName']!.isEmpty ? "N/A" : item['siteName']!, flex: 3),
          _buildCell(item['quantity']!, flex: 2, align: TextAlign.center, bold: true),
          _buildCell(item['amount']!, flex: 2, align: TextAlign.right, bold: true),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w400, color: AppColor.black, fontSize: 12),
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
          _buildCardRow('Site Name', item.siteName?.isEmpty == true ? 'N/A' : item.siteName ?? 'N/A'),
          SizedBox(height: 8),
          _buildCardRow('Counts', item.quantity ?? '0'),
          SizedBox(height: 8),
          _buildCardRow('Amount', item.amount ?? '0'),
          SizedBox(height: 8),
          _buildCardRow('GST', item.gst ?? '0'),
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
