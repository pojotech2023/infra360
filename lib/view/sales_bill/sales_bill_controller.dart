import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_data.dart';
import '../../model/sales_bill_model.dart';
import '../../utils/res/sendWhatsAppMessage.dart';

class SalesBillItem {
  TextEditingController particular = TextEditingController();
  TextEditingController count = TextEditingController();
  TextEditingController amount = TextEditingController();
}

class SalesBillController extends GetxController {
  // Site ID passed via arguments
  late int siteId;

  // Form controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController termsController = TextEditingController();

  // Customer List
  List<CustomerInfo> customers = [];

  // Particulars list
  var itemList = <SalesBillItem>[].obs;

  // Total
  var totalAmount = 0.0.obs;

  // Loading
  var isFormLoading = false.obs;
  var isSubmitLoading = false.obs;

  @override
  void onInit() {
    siteId = Get.arguments as int;
    // Add one blank row by default
    itemList.add(SalesBillItem());
    // Set today's date
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // Load form details (pre-fill customer info)
    _loadFormDetails();
    super.onInit();
  }

  void resetForm() {
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    subjectController.clear();
    locationController.clear();
    termsController.clear();
    itemList.clear();
    itemList.add(SalesBillItem());
    recalcTotal();
    update();
  }

  Future<void> _loadFormDetails() async {
    isFormLoading.value = true;
    update();
    try {
      final res = await ApiData().salesBillFormApi(siteId);
      if (res != null && res.status == true) {
        if (res.data?.customers != null && res.data!.customers!.isNotEmpty) {
          customers = res.data!.customers!;
          // Pre-fill with the first customer by default
          onCustomerSelected(customers.first);
        }
        
        // Also prefill location from site if empty
        if (locationController.text.isEmpty) {
          locationController.text = res.data?.site?.location ?? '';
        }
      }
    } catch (e) {
      print('Error loading sales bill form: $e');
    } finally {
      isFormLoading.value = false;
      update();
    }
  }

  void onCustomerSelected(CustomerInfo customer) {
    nameController.text = customer.name ?? '';
    mobileController.text = customer.mobileNo ?? '';
    emailController.text = customer.email ?? '';
    if (customer.address != null && customer.address!.isNotEmpty) {
      locationController.text = customer.address!;
    }
    update();
  }

  void addItem() {
    itemList.add(SalesBillItem());
    update();
  }

  void removeItem(int index) {
    if (itemList.length > 1) {
      itemList.removeAt(index);
      recalcTotal();
    }
  }

  void recalcTotal() {
    double sum = 0;
    for (var item in itemList) {
      sum += double.tryParse(item.amount.text) ?? 0;
    }
    totalAmount.value = sum;
    update();
  }

  Map<String, dynamic> _buildPayload({String? email}) {
    final particulars = itemList.map((i) => i.particular.text.trim()).toList();
    final counts = itemList.map((i) => i.count.text.trim()).toList();
    final amounts = itemList.map((i) => i.amount.text.trim()).toList();

    return {
      'site_id': siteId,
      'name': nameController.text.trim(),
      'subject': subjectController.text.trim(),
      'date': dateController.text.trim(),
      'mobile_no': mobileController.text.trim(),
      'location': locationController.text.trim(),
      if (termsController.text.isNotEmpty) 'terms_conditions': termsController.text.trim(),
      if (email != null && email.isNotEmpty) 'email': email,
      'particular': particulars,
      'count': counts,
      'amount': amounts,
    };
  }

  Future<SalesBillStoredModel?> _submitBill({String? email}) async {
    isSubmitLoading.value = true;
    update();
    try {
      final payload = _buildPayload(email: email);
      print('📦 SalesBill PAYLOAD: $payload');
      return await ApiData().salesBillAddApi(payload);
    } catch (e) {
      print('Error submitting sales bill: $e');
      return null;
    } finally {
      isSubmitLoading.value = false;
      update();
    }
  }

  Future<void> sendWhatsApp() async {
    final res = await _submitBill();
    if (res == null || res.status != true) {
      Get.snackbar('Error', res?.message ?? 'Failed to generate Sales Bill.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    final url = res.whatsappUrl;
    if (url != null && url.isNotEmpty) {
      extractAndOpenWhatsApp(url);
    } else {
      Get.snackbar('Error', 'WhatsApp URL not available.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> sendMail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Email Required', 'Please enter an email address.',
          backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return;
    }
    final res = await _submitBill(email: email);
    if (res == null || res.status != true) {
      Get.snackbar('Error', res?.message ?? 'Failed to send mail.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    if (res.mailSent == true) {
      Get.snackbar('Success', 'Sales Bill mail sent successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('Info', res.message ?? 'Bill created. Mail status unavailable.',
          backgroundColor: Colors.blueGrey, colorText: Colors.white);
    }
  }

  Future<void> downloadPdf() async {
    final res = await _submitBill();
    if (res == null || res.status != true) {
      Get.snackbar('Error', res?.message ?? 'Failed to generate PDF.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    final pdfUrl = res.pdfUrl;
    if (pdfUrl != null && pdfUrl.isNotEmpty) {
      final Uri uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Cannot open PDF URL.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } else {
      Get.snackbar('Error', 'PDF URL not available.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
