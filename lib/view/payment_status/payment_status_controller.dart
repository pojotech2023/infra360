import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/site_payment_history_model.dart';
import 'package:raptor_pro/model/site_payment_summary_model.dart';
import 'package:raptor_pro/utils/file_download.dart';
import 'package:raptor_pro/view/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raptor_pro/view/payment_status/add_payment_screen.dart' as raptor_pro_add_payment;

class PaymentStatusController extends GetxController {
  var isLoading = false.obs;
  var isHistoryLoading = false.obs;
  var siteId = 0.obs;

  var summaryData = Rxn<SitePaymentSummaryData>();
  var historyList = <PaymentHistory>[].obs;
  var budgetAmount = "0".obs;
  var balanceAmount = "0".obs;

  // Customer contact info for WhatsApp/Email
  var customerPhone = "".obs;
  var customerEmail = "".obs;

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

  void setCustomerContact(String phone, String email) {
    customerPhone.value = phone;
    customerEmail.value = email;
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

  // Edit mode variables
  var isEditMode = false.obs;
  var editPaymentId = Rxn<int>();

  void openEditMode(PaymentHistory item) {
    isEditMode.value = true;
    editPaymentId.value = item.id;
    paymentController.text = item.payment ?? "";
    remarksController.text = item.remarks ?? "";
    
    if (item.paymentMode != null && paymentModes.contains(item.paymentMode)) {
      selectedPaymentMode.value = item.paymentMode!;
    }
    
    if (item.date != null && item.date!.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(item.date!);
        selectedDate.value = parsedDate;
      } catch (_) {}
    }
    
    Get.to(() => const raptor_pro_add_payment.AddPaymentScreen()); // Using alias for AddPaymentScreen to avoid conflict
  }

  void resetForm() {
    isEditMode.value = false;
    editPaymentId.value = null;
    paymentController.clear();
    remarksController.clear();
    selectedPaymentMode.value = "Select Payment Mode";
    selectedDate.value = DateTime.now();
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

      dynamic response;
      if (isEditMode.value && editPaymentId.value != null) {
        response = await ApiData().updateSitePaymentApi(editPaymentId.value!, postData);
      } else {
        response = await ApiData().sitePaymentAddApi(postData);
      }

      if (response != null && (response.status == true || response.status == 'success' || response.responseCode == 200 || response.success == true)) {
        Get.back(); // Close form
        Get.snackbar("Success", response.message ?? "Payment processed successfully");
        resetForm();
        // Refresh summary and history
        getPaymentSummary();
        getPaymentHistory();
      } else {
        Get.snackbar("Error", response?.message ?? "Failed to process payment");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePayment(int id) async {
    isHistoryLoading.value = true;
    try {
      final res = await ApiData().deleteSitePaymentApi(id);
      if (res != null && (res.status == true || res.responseCode == 200)) {
        Get.snackbar("Success", res.message ?? "Deleted successfully");
        getPaymentSummary();
        getPaymentHistory();
      } else {
        Get.snackbar("Error", "Failed to delete payment");
      }
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<void> downloadPaymentReceiptPdf(BuildContext context, int paymentId) async {
    try {
      final res = await ApiData().downloadPaymentReceiptPdf(paymentId);
      if (res != null && res.downloadUrl != null) {
        CommonFileDownloader.downloadAndOpen(
          urls: res.downloadUrl ?? "",
          context: context,
          fileName: "payment_receipt_$paymentId.pdf",
        );
      } else {
        showToastMessage("Failed to generate PDF receipt.");
      }
    } catch (e) {
      showToastMessage("Error downloading PDF: $e");
    }
  }

  Future<void> sendPaymentReceiptWhatsApp(int paymentId) async {
    try {
      final res = await ApiData().sendPaymentReceiptWhatsApp(paymentId, customerPhone.value);
      if (res != null && res.status == true) {
        showToastMessage(res.message ?? "WhatsApp link generated successfully");
        if (res.data != null && res.data!['whatsapp_url'] != null) {
          final String whatsappUrl = res.data!['whatsapp_url'];
          Uri uri = Uri.parse(whatsappUrl);
          
          try {
            bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (!launched && whatsappUrl.startsWith('https://wa.me/')) {
               // Fallback to whatsapp:// protocol
               String fallback = whatsappUrl.replaceFirst('https://wa.me/', 'whatsapp://send?phone=');
               fallback = fallback.replaceFirst('?', '&');
               Uri fallbackUri = Uri.parse(fallback);
               await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
            }
          } catch (e) {
            showToastMessage("Could not open WhatsApp");
          }
        } else {
          // Fallback if no URL returned
          final whatsappUrl = customerPhone.value.isNotEmpty 
              ? "https://wa.me/${customerPhone.value}?text=Payment receipt sent" 
              : "https://wa.me/?text=Payment receipt sent";
          Uri uri = Uri.parse(whatsappUrl);
          
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            showToastMessage("Could not open WhatsApp");
          }
        }
      } else {
        showToastMessage(res?.message ?? "Failed to generate WhatsApp link");
      }
    } catch (e) {
      showToastMessage("Error sending via WhatsApp: $e");
    }
  }

  Future<void> sendPaymentReceiptEmail(int paymentId) async {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final res = await ApiData().sendPaymentReceiptEmail(paymentId, customerEmail.value);
      Navigator.of(Get.overlayContext!).pop(); // close dialog
      if (res != null && (res.status == true || res.status == 'success' || res.responseCode == 200 || res.success == true)) {
        showToastMessage(res.message ?? "Receipt sent via Email");
      } else {
        showToastMessage(res?.message ?? "Failed to send receipt via Email");
      }
    } catch (e) {
      Navigator.of(Get.overlayContext!).pop(); // close dialog
      showToastMessage("Error sending via Email: $e");
    }
  }

  Future<void> exportPaymentHistoryExcel(BuildContext context) async {
    try {
      final res = await ApiData().sitePaymentExportApi(siteId.value);
      if (res != null && res.downloadUrl != null) {
        CommonFileDownloader.downloadAndOpen(
          urls: res.downloadUrl ?? "",
          context: context,
          fileName: "payment_history_site_${siteId.value}.xlsx",
        );
      } else {
        showToastMessage("Failed to generate Excel export.");
      }
    } catch (e) {
      showToastMessage("Error exporting to Excel: $e");
    }
  }
}
