import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/model/subcontractor_payment_history_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/view/subcontractor_details/site_payment_history/site_payment_history_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/view/widgets/log_out.dart';
import 'package:raptor_pro/utils/res/date_picker.dart';

class SitePaymentHistoryScreen extends StatelessWidget {
  const SitePaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SitePaymentHistoryController());

    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: "${controller.args.type} Payment Detail",
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CommonLoader());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Action Buttons ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.resetForm();
                      _showAddPaymentDialog(context, controller);
                    },
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text("+ Add Payment", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Obx(() => ElevatedButton.icon(
                    onPressed: controller.isExporting.value
                        ? null
                        : () => controller.exportHistory(context),
                    icon: controller.isExporting.value
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.file_download, color: Colors.white, size: 18),
                    label: Text(
                      controller.isExporting.value ? "Exporting..." : "Export",
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 16),

              // ─── Payment History Title ────────────────────────────────
              Text(
                "Payment History",
                style: AppTextStyle.textMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // ─── List ─────────────────────────────────────────────────
              Obx(() {
                final list = controller.historyList;
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        "No payment history found.",
                        style: AppTextStyle.textRegular15.copyWith(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildCard(item, index + 1, controller);
                  },
                );
              }),

              // ─── Total Payment ────────────────────────────────────────
              Obx(() => Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColor.tableBGColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TOTAL PAYMENT",
                      style: AppTextStyle.textMedium.copyWith(
                          color: AppColor.buttonLightBlue, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${controller.totalPaidAmount.value}",
                      style: AppTextStyle.textBold.copyWith(color: AppColor.buttonLightBlue),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
        }),
      ),
    );
  }

  Widget _buildCard(PaymentHistoryList item, int index, SitePaymentHistoryController controller) {
    String formattedDate = item.date ?? '';
    try {
      if (formattedDate.isNotEmpty) {
        formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(formattedDate));
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                "#$index",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          const Divider(height: 16),
          _cardRow("Payment Mode", item.paymentMode ?? "N/A"),
          const SizedBox(height: 6),
          _cardRow("Remarks", item.remarks?.isNotEmpty == true ? item.remarks! : "—"),
          const SizedBox(height: 6),
          _cardRow(
            "Payment",
            item.payment ?? "0",
            valueColor: Colors.green.shade700,
            bold: true,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  controller.openEditMode(item);
                  _showAddPaymentDialog(Get.context!, controller);
                },
                child: const Icon(Icons.edit, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  if (item.id != null) {
                    deleteDialog(Get.context!, () {
                      controller.deletePayment(item.id!);
                    });
                  }
                },
                child: const Icon(Icons.delete, color: Colors.red, size: 20),
              ),
            ],
          ),
        ],
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

  void _showAddPaymentDialog(BuildContext context, SitePaymentHistoryController controller) {

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Obx(() => Text(controller.isEditMode.value ? "Edit Payment" : "Add Payment")),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: controller.dateCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Date *",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          controller.dateCtrl.text =
                              "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controller.paymentCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Payment Amount *"),
                    ),
                    const SizedBox(height: 14),
                    Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedPaymentMode.value,
                      decoration: const InputDecoration(labelText: "Payment Mode *"),
                      items: const [
                        DropdownMenuItem(value: "Online", child: Text("Online")),
                        DropdownMenuItem(value: "Cheque", child: Text("Cheque")),
                        DropdownMenuItem(value: "Net Banking", child: Text("Net Banking")),
                        DropdownMenuItem(value: "Cash", child: Text("Cash")),
                      ],
                      onChanged: (val) => controller.selectedPaymentMode.value = val,
                    )),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controller.remarksCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "Remarks"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(backgroundColor: Colors.indigo.shade400),
                  child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                ),
                Obx(() => ElevatedButton(
                  onPressed: controller.isAddingPayment.value
                      ? null
                      : () async {
                          Navigator.pop(dialogContext);
                          await controller.addPayment();
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
                  child: controller.isAddingPayment.value
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(controller.isEditMode.value ? "Update" : "Save", style: const TextStyle(color: Colors.white)),
                )),
              ],
            );
          },
        );
      },
    );
  }
}
