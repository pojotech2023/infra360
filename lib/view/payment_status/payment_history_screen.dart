import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/payment_status/payment_status_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

class PaymentHistoryScreen extends GetView<PaymentStatusController> {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.getPaymentHistory();
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: CommonAppBar.appBar(
        title: "Site Payment History",
        onTap: () => Get.back(),
      ),
      body: Obx(() {
        if (controller.isHistoryLoading.value) {
          return const Center(child: CommonLoader());
        }

        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Budget: ${controller.budgetAmount.value}",
                        style: const TextStyle(
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 600, // Fixed width to ensure all columns have enough space
                        child: Column(
                          children: [
                            Container(
                              color: const Color(0xFFF8F9FA),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                              child: Row(
                                children: const [
                                  _HeaderCell("S.N", flex: 1),
                                  _HeaderCell("DATE", flex: 4),
                                  _HeaderCell("AMOUNT", flex: 4),
                                  _HeaderCell("MODE", flex: 3),
                                  _HeaderCell("REMARKS", flex: 5),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            Expanded(
                              child: controller.historyList.isEmpty
                                  ? const Center(child: Text("No history available"))
                                  : ListView.separated(
                                      itemCount: controller.historyList.length,
                                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F1F1)),
                                      itemBuilder: (context, index) {
                                        final item = controller.historyList[index];
                                        return _buildTableRow(index + 1, item);
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildBalanceFooter(),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTableRow(int index, dynamic item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: [
          _DataCell(index.toString(), flex: 1),
          _DataCell(item.date ?? "-", flex: 4, preventWrap: true),
          _DataCell(item.payment ?? "0.00", flex: 4, isBold: true, preventWrap: true),
          _DataCell(item.paymentMode ?? "-", flex: 3),
          _DataCell(item.remarks ?? "-", flex: 5),
        ],
      ),
    );
  }

  Widget _buildBalanceFooter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "BALANCE AMOUNT",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            controller.balanceAmount.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _HeaderCell(this.label, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF8B94A7),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isBold;
  final bool preventWrap;
  const _DataCell(this.text, {this.flex = 1, this.isBold = false, this.preventWrap = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: preventWrap ? 1 : 2,
        overflow: preventWrap ? TextOverflow.visible : TextOverflow.ellipsis,
        softWrap: !preventWrap,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: const Color(0xFF2D3243),
        ),
      ),
    );
  }
}
