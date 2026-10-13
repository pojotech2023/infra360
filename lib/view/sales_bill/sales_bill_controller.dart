import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_data.dart';
import '../../model/unit_master_model.dart';
import '../../model/sales_bill_model.dart';
import '../../utils/res/sendWhatsAppMessage.dart';
import '../widgets/toast.dart';

class SalesBillItem {
  TextEditingController particular = TextEditingController();
  TextEditingController count = TextEditingController();
  String? selectedUnit;
  TextEditingController amount = TextEditingController(); // this is Rate
  TextEditingController total = TextEditingController();
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
  final TextEditingController termsTitleController = TextEditingController();
  final TextEditingController termsController = TextEditingController();
  final GlobalKey autocompleteKey = GlobalKey();

  Future<List<String>> getTermsSuggestions(String query) async {
    if (query.isEmpty) return [];
    return await ApiData().termsConditionSearchApi(query);
  }

  Future<void> onTermsSelected(String title) async {
    final desc = await ApiData().termsConditionDescriptionApi(title);
    if (desc.isNotEmpty) {
      termsController.text = desc;
      update();
    }
  }

  // Customer List
  List<CustomerInfo> customers = [];

  // Unit Master List
  List<UnitMasterData> unitMasterList = [];

  // Particulars list
  var itemList = <SalesBillItem>[].obs;

  // Total
  var totalAmount = 0.0.obs;

  // Loading
  var isFormLoading = false.obs;
  var isSubmitLoading = false.obs;

  // Date Parsing helper
  DateTime parsedDate = DateTime.now();

  @override
  void onInit() {
    siteId = Get.arguments as int;
    // Add one blank row by default
    itemList.add(SalesBillItem());
    // Set today's date
    dateController.text = DateFormat('dd-MM-yyyy').format(parsedDate);
    // Load form details (pre-fill customer info)
    _loadFormDetails();
    super.onInit();
  }

  void resetForm() {
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    parsedDate = DateTime.now();
    dateController.text = DateFormat('dd-MM-yyyy').format(parsedDate);
    subjectController.clear();
    locationController.clear();
    termsTitleController.clear();
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
      
      // Fetch Unit Master List
      final unitRes = await ApiData().unitMasterListApi();
      if (unitRes != null && unitRes.status == true && unitRes.data != null) {
        unitMasterList = unitRes.data!;
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
      double countVal = double.tryParse(item.count.text) ?? 0.0;
      double rateVal = double.tryParse(item.amount.text) ?? 0.0;
      double itemTotal = countVal * rateVal;
      
      // Update the read-only total controller for this item
      if (item.count.text.isNotEmpty && item.amount.text.isNotEmpty) {
        item.total.text = itemTotal.toStringAsFixed(2);
      } else {
        item.total.clear();
      }
      
      sum += itemTotal;
    }
    totalAmount.value = sum;
    update();
  }

  Map<String, dynamic> _buildPayload({String? email}) {
    final particulars = itemList.map((i) => i.particular.text.trim()).toList();
    final counts = itemList.map((i) => i.count.text.trim()).toList();
    final units = itemList.map((i) => i.selectedUnit ?? '').toList();
    final amounts = itemList.map((i) => i.amount.text.trim()).toList();

    return {
      'site_id': siteId,
      'name': nameController.text.trim(),
      'subject': subjectController.text.trim(),
      'date': DateFormat('yyyy-MM-dd').format(parsedDate),
      'mobile_no': mobileController.text.trim(),
      'location': locationController.text.trim(),
      if (termsController.text.isNotEmpty) 'terms_conditions': termsController.text.trim(),
      if (email != null && email.isNotEmpty) 'email': email,
      'particular': particulars,
      'count': counts,
      'unit': units,
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

  Future<String?> _promptForEmail() async {
    final tempEmailCtrl = TextEditingController(text: emailController.text.trim());
    return await Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.mail_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('Recipient Email', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the email address to receive this Sales Bill:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tempEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'customer@example.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = tempEmailCtrl.text.trim();
              if (text.isEmpty || !text.contains('@')) {
                showToastMessage('Please enter a valid email address.');
                return;
              }
              Get.back(result: text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> sendWhatsApp() async {
    final res = await _submitBill();
    if (res == null || res.status != true) {
      showToastMessage(res?.message ?? 'Failed to generate Sales Bill.');
      return;
    }
    final url = res.whatsappUrl;
    if (url != null && url.isNotEmpty) {
      extractAndOpenWhatsApp(url);
    } else {
      showToastMessage('WhatsApp URL not available.');
    }
  }

  Future<void> sendMail() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      final inputEmail = await _promptForEmail();
      if (inputEmail == null || inputEmail.trim().isEmpty) {
        return; // User cancelled
      }
      email = inputEmail.trim();
      emailController.text = email;
    }

    final res = await _submitBill(email: email);
    if (res == null || res.status != true) {
      showToastMessage(res?.message ?? 'Failed to generate Sales Bill.');
      return;
    }

    if (res.mailSent == true) {
      showToastMessage('Sales Bill mail sent successfully!');
    } else {
      // Fallback: If server SMTP failed, launch device email app with PDF link
      final pdfUrl = res.pdfUrl ?? '';
      final billSubj = subjectController.text.trim().isNotEmpty ? subjectController.text.trim() : 'Sales Bill';
      final Uri mailUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          'subject': billSubj,
          'body': 'Dear Sir/Madam,\n\nPlease find your Sales Bill link below:\n$pdfUrl\n\nThank you.',
        },
      );
      try {
        await launchUrl(mailUri, mode: LaunchMode.externalApplication);
        showToastMessage('Opening Mail App to send Sales Bill.');
      } catch (_) {
        showToastMessage('Sales Bill generated successfully.');
      }
    }
  }

  Future<void> downloadPdf() async {
    final res = await _submitBill();
    if (res == null || res.status != true) {
      showToastMessage(res?.message ?? 'Failed to generate PDF.');
      return;
    }
    final pdfUrl = res.pdfUrl;
    if (pdfUrl != null && pdfUrl.isNotEmpty) {
      final Uri uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        showToastMessage('Cannot open PDF URL.');
      }
    } else {
      showToastMessage('PDF URL not available.');
    }
  }
}
