import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';
import '../../api/api_data.dart';
import '../../model/quotation_history_model.dart';
import '../../model/customer_model.dart';

class QuotationHistoryController extends GetxController {
  final TextEditingController mobileNoController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var isPdfLoading = false.obs;
  var hasSearched = false.obs;

  var historyList = <QuotationHistoryData>[].obs;
  var allCustomers = <Customers>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      final res = await ApiData().customerList();
      if (res != null && res.data != null && res.data!.customers != null) {
        allCustomers.value = res.data!.customers!;
      }
    } catch (e) {
      print('Error fetching customers: $e');
    }
  }

  List<Customers> getSuggestions(String query) {
    if (query.isEmpty) return [];
    return allCustomers.where((customer) {
      final nameLower = customer.name?.toLowerCase() ?? '';
      final mobileLower = customer.mobileNo?.toLowerCase() ?? '';
      final queryLower = query.toLowerCase();
      return nameLower.startsWith(queryLower) || nameLower.contains(queryLower) || mobileLower.contains(queryLower);
    }).toList();
  }

  Future<void> searchHistory({String? explicitMobileNo}) async {
    if (!formKey.currentState!.validate()) return;
    
    String mobileNo = explicitMobileNo ?? mobileNoController.text.trim();
    if (mobileNo.isEmpty) return;

    // If the input contains letters, it's likely a name typed manually without selecting from suggestion
    if (mobileNo.contains(RegExp(r'[a-zA-Z]'))) {
      final matchedCustomer = allCustomers.firstWhereOrNull((c) => 
          (c.name?.toLowerCase() ?? '') == mobileNo.toLowerCase());
      
      if (matchedCustomer != null && matchedCustomer.mobileNo != null) {
        mobileNo = matchedCustomer.mobileNo!;
        mobileNoController.text = mobileNo; // update UI to reflect resolved number
      } else {
        Get.snackbar(
          'Error',
          'Customer not found. Please select from suggestions or enter a valid mobile number.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
    }

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
