import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../utils/res/spacing.dart';
import '../../utils/text_form_style.dart';
import '../widgets/common_app_bar.dart';
import 'purchase_bill_history_controller.dart';
import '../widgets/log_out.dart';

class PurchaseBillHistoryScreen extends StatelessWidget {
  PurchaseBillHistoryScreen({super.key});

  final ctrl = Get.put(PurchaseBillHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => CommonAppBar.appBar(
          title: ctrl.siteName.value.isNotEmpty
              ? 'Purchase Bill History - ${ctrl.siteName.value}'
              : 'Purchase Bill History',
          onTap: () => Get.back(),
        )),
      ),
      body: SafeArea(
        child: GetBuilder<PurchaseBillHistoryController>(
          builder: (controller) {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.historyList.isEmpty) {
              return const Center(child: Text("No history available."));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.historyList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = controller.historyList[index];
                String displayDate = '-';
                if (item.date != null && item.date!.isNotEmpty) {
                  try {
                    displayDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(item.date!));
                  } catch (e) {
                    displayDate = item.date!;
                  }
                }
                
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "#${index + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                          ),
                          Text(
                            displayDate,
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      _cardRow("Vendor", item.vendorName ?? '-'),
                      const SizedBox(height: 6),
                      _cardRow("Subject", item.subject ?? '-'),
                      const SizedBox(height: 6),
                      _cardRow(
                        "Total (₹)",
                        item.totalAmount?.toString() ?? '0.00',
                        valueColor: Colors.green.shade700,
                        bold: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // View PDF
                          _actionButton(
                            color: Colors.blue,
                            icon: Icons.description,
                            label: 'View',
                            onTap: () => controller.openPdf(item.pdfUrl),
                          ),
                          const SizedBox(width: 8),
                          // WhatsApp
                          _actionButton(
                            color: Colors.green,
                            icon: Icons.chat,
                            label: 'WhatsApp',
                            onTap: () => controller.shareWhatsapp(item.whatsappUrl),
                          ),
                          const SizedBox(width: 8),
                          // Delete
                          _actionButton(
                            color: Colors.redAccent,
                            icon: Icons.delete,
                            label: 'Delete',
                            onTap: () {
                              deleteDialog(context, () {
                                if (item.id != null) {
                                  controller.deleteBill(item.id!);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _cardRow(String label, String value, {Color? valueColor, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? Colors.black87,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({required Color color, required IconData icon, String? label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }
}
