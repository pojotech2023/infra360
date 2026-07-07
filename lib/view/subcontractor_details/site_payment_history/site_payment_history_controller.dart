import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/subcontractor_payment_history_model.dart';
import 'package:raptor_pro/utils/file_download.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class SitePaymentArgs {
  final int siteId;
  final String type; // "Petty Cash" or "Rental Management"
  final String siteName;

  SitePaymentArgs({required this.siteId, required this.type, required this.siteName});
}

class SitePaymentHistoryController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool isExporting = false.obs;
  RxBool isAddingPayment = false.obs;

  var historyList = <PaymentHistoryList>[].obs;
  var totalPaidAmount = 0.obs;
  var subcontractorId = 0.obs;

  late SitePaymentArgs args;

  final TextEditingController paymentCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController remarksCtrl = TextEditingController();
  final RxnString selectedPaymentMode = RxnString();

  @override
  void onInit() {
    args = Get.arguments as SitePaymentArgs;
    fetchHistory();
    super.onInit();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    final model = await ApiData().siteSubcontractorPaymentHistoryApi(args.siteId, args.type);
    if (model != null && model.data != null) {
      historyList.assignAll(model.data!.paymentHistoryList ?? []);
      totalPaidAmount.value = model.data!.totalPaidAmount ?? 0;
      subcontractorId.value = model.data!.subcontractorId ?? 0;
    } else {
      historyList.clear();
      totalPaidAmount.value = 0;
      subcontractorId.value = 0;
    }
    isLoading.value = false;
  }

  Future<void> addPayment() async {
    if (paymentCtrl.text.isEmpty || dateCtrl.text.isEmpty || selectedPaymentMode.value == null) {
      showToastMessage("Please fill in all required fields.");
      return;
    }
    if (subcontractorId.value == 0) {
      showToastMessage("Subcontractor details not loaded. Cannot add payment.");
      return;
    }
    isAddingPayment.value = true;
    final data = {
      "subcontractor_id": subcontractorId.value,
      "payment": paymentCtrl.text,
      "date": dateCtrl.text,
      "payment_mode": selectedPaymentMode.value,
      "remarks": remarksCtrl.text,
    };
    final res = await ApiData().siteAddPaymentApi(data);
    if (res != null) {
      showToastMessage(res.message ?? "Payment added successfully");
      paymentCtrl.clear();
      dateCtrl.clear();
      remarksCtrl.clear();
      selectedPaymentMode.value = null;
      await fetchHistory();
    } else {
      showToastMessage("Failed to add payment. Please try again.");
    }
    isAddingPayment.value = false;
  }

  Future<void> exportHistory(BuildContext context) async {
    isExporting.value = true;
    final res = await ApiData().sitePaymentHistoryExportApi(args.siteId, args.type);
    if (res != null && res.downloadUrl != null) {
      CommonFileDownloader.downloadAndOpen(
        urls: res.downloadUrl ?? "",
        context: context,
        fileName: "${args.type.toLowerCase().replaceAll(' ', '_')}_payment_history.xlsx",
      );
    } else {
      showToastMessage("Failed to generate export URL.");
    }
    isExporting.value = false;
  }

  @override
  void onClose() {
    paymentCtrl.dispose();
    dateCtrl.dispose();
    remarksCtrl.dispose();
    super.onClose();
  }
}
