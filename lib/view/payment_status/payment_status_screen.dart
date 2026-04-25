import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/payment_status/add_payment_screen.dart';
import 'package:raptor_pro/view/payment_status/payment_history_screen.dart';
import 'package:raptor_pro/view/payment_status/payment_status_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

class PaymentStatusScreen extends GetView<PaymentStatusController> {
  const PaymentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PaymentStatusController());
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: CommonAppBar.appBar(
        title: "Payment Detail",
        onTap: () => Get.back(),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CommonLoader());
        }

        final data = controller.summaryData.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const AddPaymentScreen()),
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text("Add Payment", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28C76F),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const PaymentHistoryScreen()),
                    icon: const Icon(Icons.history, color: Colors.white, size: 18),
                    label: const Text("Payment History", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ],
              ),
              VerticalSpacing.d20px(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                   _buildAmountRow("Budget Amount", data?.budgetAmount ?? "0.00"),
                   VerticalSpacing.d20px(),
                   _buildAmountRow("Paid Amount", data?.paidAmount ?? "0.00"),
                   VerticalSpacing.d20px(),
                   _buildAmountRow("Balance Amount", data?.balanceAmount ?? "0.00"),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAmountRow(String label, String amount) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5E5873),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F2F7),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6E6B7B),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
