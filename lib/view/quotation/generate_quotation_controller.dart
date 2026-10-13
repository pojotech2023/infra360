
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_data.dart';
import '../../model/quotation_model.dart';
import '../../model/quotation_stored_model.dart';
import '../../utils/res/sendWhatsAppMessage.dart';
import '../widgets/toast.dart';

class GenerateQuotationController extends GetxController{

  TextEditingController locationEditingController = TextEditingController();

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController mobileNumberEditingController = TextEditingController();
  TextEditingController contractorEditingController = TextEditingController();
  TextEditingController subjectEditingController = TextEditingController();
  // Email field — passed to quotation/store to trigger mail_sent
  TextEditingController emailEditingController = TextEditingController();

  TextEditingController datePickerController = TextEditingController();
  
  final TextEditingController termsTitleController = TextEditingController();
  final TextEditingController termsDescController = TextEditingController();
  final GlobalKey autocompleteKey = GlobalKey();

  Future<List<String>> getTermsSuggestions(String query) async {
    if (query.isEmpty) return [];
    return await ApiData().termsConditionSearchApi(query);
  }

  Future<void> onTermsSelected(String title) async {
    print('--- DEBUG: onTermsSelected (Quotation) ---');
    print('Selected Title: $title');
    final desc = await ApiData().termsConditionDescriptionApi(title);
    print('Returned Description: $desc');
    if (desc.isNotEmpty) {
      termsDescController.text = desc;
      print('Assigned to termsDescController: ${termsDescController.text}');
      update();
    } else {
      print('Description was empty! Not updating.');
    }
  }

  var totalAmt = 0.0.obs;

  var quotationList = <QuotationData>[].obs;
  var units = <String>[].obs;

  // Loading indicator
  var isLoading = false.obs;
  var issubmitLoading = false.obs;

  @override
  void onInit() {
    quotation();
    super.onInit();
  }

  Future<void> quotation() async {
    try {
      isLoading.value = true;
      quotationList.clear();
      QuotationModel? response = await ApiData().quotationListApi();
      final unitRes = await ApiData().unitMasterListApi();
      
      quotationList.value = response?.data ?? [];
      
      if (unitRes != null && unitRes.data != null) {
        units.value = unitRes.data!.map((u) => u.unitName ?? '').where((u) => u.isNotEmpty).toList();
      }
      
      calculateTotal();
    } catch (e) {
      print("Error loading quotation data: $e");
    } finally {
      isLoading.value = false;
    }
    update();
  }

  void calculateTotal() {
    double sum = 0;
    for (var item in quotationList) {
      sum += double.tryParse(item.total?.text ?? '0') ?? 0;
    }
    totalAmt.value = sum;
    update();
  }

  Future<String?> _promptForEmail() async {
    final tempEmailCtrl = TextEditingController(text: emailEditingController.text.trim());
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
              'Enter the email address to receive this Quotation:',
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

  /// Builds the payload and calls quotation/store.
  /// Backend handles email sending with fail-safe try-catch.
  Future<QuotationStoredModel?> _storeQuotation({String? email}) async {
    try {
      issubmitLoading.value = true;
      update();

      List<Map<String, dynamic>> quotationData = quotationList.map((item) {
        return {
          "particular": item.particular?.text ?? "",
          "rate": item.rate?.text ?? "0",
          "sqFt": item.sqFt?.text ?? "0",
          "unit": item.unit ?? "",
        };
      }).toList();

      var data = {
        "name": nameEditingController.text,
        "subject": subjectEditingController.text,
        "date": convertDateFormat(datePickerController.text),
        "mobile_no": mobileNumberEditingController.text,
        "location": locationEditingController.text,
        "contractor": contractorEditingController.text,
        "data": quotationData,
        if (termsDescController.text.isNotEmpty) "terms_conditions": termsDescController.text,
        if (email != null && email.isNotEmpty) "email": email,
      };

      print("REQUEST BODY: $data");
      return await ApiData().quotationStoreApi(data);
    } catch (e) {
      print("Error in _storeQuotation: $e");
      return null;
    } finally {
      issubmitLoading.value = false;
      update();
    }
  }

  /// Send WhatsApp — stores quotation, opens whatsapp_url from response.
  Future<void> sendWhatsAppAction() async {
    final res = await _storeQuotation();
    if (res == null || res.status != true) {
      showToastMessage(res?.message ?? "Failed to generate quotation.");
      return;
    }

    final url = res.whatsappUrl;
    if (url != null && url.isNotEmpty) {
      extractAndOpenWhatsApp(url);
    } else {
      showToastMessage("WhatsApp URL not available.");
    }
  }

  /// Send Mail — stores quotation, opens device email client with PDF link if SMTP fails.
  Future<void> sendMailAction() async {
    String email = emailEditingController.text.trim();
    if (email.isEmpty) {
      final inputEmail = await _promptForEmail();
      if (inputEmail == null || inputEmail.trim().isEmpty) {
        return; // User cancelled
      }
      email = inputEmail.trim();
      emailEditingController.text = email;
    }

    final res = await _storeQuotation(email: email);
    if (res == null || res.status != true) {
      showToastMessage(res?.message ?? "Failed to generate quotation.");
      return;
    }

    if (res.mailSent == true) {
      showToastMessage("Quotation mail sent successfully!");
    } else {
      // Fallback: If server SMTP failed / quota exceeded, launch device email app with PDF link
      final pdfUrl = res.pdfUrl ?? '';
      final subj = subjectEditingController.text.trim().isNotEmpty
          ? subjectEditingController.text.trim()
          : 'Quotation';
      final Uri mailUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          'subject': subj,
          'body': 'Dear Sir/Madam,\n\nPlease find your Quotation link below:\n$pdfUrl\n\nThank you.',
        },
      );
      try {
        await launchUrl(mailUri, mode: LaunchMode.externalApplication);
        showToastMessage('Opening Mail App to send Quotation.');
      } catch (_) {
        showToastMessage('Quotation generated successfully.');
      }
    }
  }

  /// Download PDF — stores quotation, opens pdf_url from response.
  Future<void> downloadPdfAction() async {
    final res = await _storeQuotation();
    if (res == null || res.status != true) {
      showToastMessage(res?.message ?? "Failed to generate PDF.");
      return;
    }

    final pdfUrl = res.pdfUrl;
    if (pdfUrl != null && pdfUrl.isNotEmpty) {
      final Uri uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        showToastMessage("Cannot open PDF URL.");
      }
    } else {
      showToastMessage("PDF URL not available.");
    }
  }

  String convertDateFormat(String inputDate) {
    try {
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(inputDate);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      print("Error parsing date: $e");
      return inputDate;
    }
  }

  void shareQuotation(String url) {
    extractAndOpenWhatsApp(url);
  }
}