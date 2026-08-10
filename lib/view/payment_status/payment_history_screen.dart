import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/payment_status/payment_status_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/view/widgets/log_out.dart';

class PaymentHistoryScreen extends GetView<PaymentStatusController> {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get customer contact info from arguments
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      controller.setCustomerContact(
        args['customerPhone'] ?? '',
        args['customerEmail'] ?? '',
      );
    }
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.exportPaymentHistoryExcel(context);
                      },
                      icon: const Icon(Icons.file_download, size: 18),
                      label: const Text("Export Excel"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                    child: controller.historyList.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text("No history available"),
                            ),
                          )
                        : ListView.builder(
                            itemCount: controller.historyList.length,
                            itemBuilder: (context, index) {
                              final item = controller.historyList[index];
                              return _buildTableRow(context, index + 1, item);
                            },
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

  Widget _buildTableRow(BuildContext context, int index, dynamic item) {
    String formattedDate = item.date ?? "-";
    if (formattedDate != "-" && formattedDate.contains("-")) {
      final parts = formattedDate.split("-");
      if (parts.length == 3 && parts[0].length == 4) {
        formattedDate = "${parts[2]}-${parts[1]}-${parts[0]}";
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8, top: 4),
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
                Text('S.NO: $index', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Amount: ', style: TextStyle(fontWeight: FontWeight.w600)),
                Expanded(child: Text('₹${item.payment ?? "0.00"}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mode: ', style: TextStyle(fontWeight: FontWeight.w600)),
                Expanded(child: Text(item.paymentMode ?? "-")),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Remarks: ', style: TextStyle(fontWeight: FontWeight.w600)),
                Expanded(child: Text(item.remarks ?? "-")),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.arrow_downward,
                  label: "PDF",
                  color: const Color(0xFFE53935),
                  tooltip: "Download PDF",
                  onTap: () {
                    if (item.id != null) {
                      controller.downloadPaymentReceiptPdf(context, item.id);
                    }
                  },
                ),
                _ActionButton(
                  icon: Icons.message,
                  label: "WhatsApp",
                  color: const Color(0xFF25D366),
                  tooltip: "Send via WhatsApp",
                  onTap: () {
                    if (item.id != null) {
                      controller.sendPaymentReceiptWhatsApp(item.id);
                    }
                  },
                ),
                _ActionButton(
                  icon: Icons.email,
                  label: "Mail",
                  color: const Color(0xFF1976D2),
                  tooltip: "Send via Email",
                  onTap: () {
                    if (item.id != null) {
                      controller.sendPaymentReceiptEmail(item.id);
                    }
                  },
                ),
                _ActionButton(
                  icon: Icons.edit,
                  label: "",
                  color: Colors.blue,
                  tooltip: "Edit Payment",
                  onTap: () {
                    controller.openEditMode(item);
                  },
                ),
                _ActionButton(
                  icon: Icons.delete,
                  label: "",
                  color: Colors.red,
                  tooltip: "Delete Payment",
                  onTap: () {
                    if (item.id != null) {
                      deleteDialog(context, () {
                        controller.deletePayment(item.id!);
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPdf = label == "PDF";
    final Color bgColor = isPdf ? Colors.white : color;
    final Color textColor = isPdf ? color : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: label.isEmpty ? 6 : 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: label.isEmpty ? 16 : 14,
              color: textColor,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
