import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/site_payment_history_model.dart';
import 'package:raptor_pro/model/site_payment_summary_model.dart';

class PaymentStatusController extends GetxController {
  var isLoading = false.obs;
  var isHistoryLoading = false.obs;
  var siteId = 0.obs;

  var summaryData = Rxn<SitePaymentSummaryData>();
  var historyList = <PaymentHistory>[].obs;
  var budgetAmount = "0".obs;
  var balanceAmount = "0".obs;

  // Form controllers
  final paymentController = TextEditingController();
  final remarksController = TextEditingController();
  var selectedDate = DateTime.now().obs;
  var selectedPaymentMode = "Select Payment Mode".obs;
  final List<String> paymentModes = ["Online", "Cheque", "Net Banking", "Cash"];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      siteId.value = Get.arguments;
      getPaymentSummary();
    }
  }

  Future<void> getPaymentSummary() async {
    isLoading.value = true;
    try {
      final response = await ApiData().sitePaymentSummaryApi(siteId.value);
      print("Controller: Fetched Summary for site ${siteId.value}");
      if (response != null && response.status == true) {
        summaryData.value = response.data;
        budgetAmount.value = response.data?.budgetAmount ?? "0";
        balanceAmount.value = response.data?.balanceAmount ?? "0";
        print("Controller: Summary Data updated. Budget: ${budgetAmount.value}");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getPaymentHistory() async {
    isHistoryLoading.value = true;
    try {
      final response = await ApiData().sitePaymentHistoryApi(siteId.value);
      print("Controller: Fetched History for site ${siteId.value}");
      if (response != null && response.status == true) {
        historyList.value = response.data ?? [];
        print("Controller: History items: ${historyList.length}");
      }
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<void> addPayment() async {
    if (paymentController.text.isEmpty) {
      Get.snackbar("Error", "Please enter payment amount");
      return;
    }
    if (selectedPaymentMode.value == "Select Payment Mode") {
      Get.snackbar("Error", "Please select payment mode");
      return;
    }

    isLoading.value = true;
    try {
      Map<String, dynamic> postData = {
        "site_id": siteId.value,
        "payment": paymentController.text,
        "date": "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}",
        "payment_mode": selectedPaymentMode.value,
        "remarks": remarksController.text,
      };

      final response = await ApiData().sitePaymentAddApi(postData);
      if (response != null && response.status == true) {
        Get.back(); // Close form
        Get.snackbar("Success", response.message ?? "Payment added successfully");
        // Clear form
        paymentController.clear();
        remarksController.clear();
        selectedPaymentMode.value = "Select Payment Mode";
        // Refresh summary and history
        getPaymentSummary();
        getPaymentHistory();
      } else {
        Get.snackbar("Error", response?.message ?? "Failed to add payment");
      }
    } finally {
      isLoading.value = false;
    }
  }
}
