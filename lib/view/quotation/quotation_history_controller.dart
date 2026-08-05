import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api/api_data.dart';
import '../../model/quotation_history_model.dart';

class QuotationHistoryController extends GetxController {
  final TextEditingController mobileNoController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var isPdfLoading = false.obs;
  var hasSearched = false.obs;

  var historyList = <QuotationHistoryData>[].obs;

  Future<void> searchHistory() async {
    if (!formKey.currentState!.validate()) return;
    
    final mobileNo = mobileNoController.text.trim();
    if (mobileNo.isEmpty) return;

    isLoading.value = true;
    hasSearched.value = true;
    update();

    try {
      final res = await ApiData().quotationHistoryApi(mobileNo);
      if (res != null && res.status == true) {
        historyList.value = res.data ?? [];
      } else {
        historyList.clear();
        Get.snackbar(
          'Error',
          res?.message ?? 'Failed to fetch quotation history',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error searching quotation history: $e');
      historyList.clear();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> viewPdf(int quotationId) async {
    isPdfLoading.value = true;
    update();
    
    try {
      final res = await ApiData().downloadQuotationPdf(quotationId);
      print('📄 [PDF URL PARSED] downloadUrl=${res?.downloadUrl}');
      if (res != null && res.downloadUrl != null) {
        final url = Uri.parse(res.downloadUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar('Error', 'Could not open PDF viewer',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', res?.message ?? 'Failed to fetch PDF URL',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print('Error viewing PDF: $e');
      Get.snackbar('Error', 'An error occurred while opening PDF',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isPdfLoading.value = false;
      update();
    }
  }
  
  @override
  void onClose() {
    mobileNoController.dispose();
    super.onClose();
  }
}
