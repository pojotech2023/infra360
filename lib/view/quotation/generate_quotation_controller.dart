
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_data.dart';
import '../../model/quotation_model.dart';
import '../../model/quotation_stored_model.dart';
import '../../utils/res/sendWhatsAppMessage.dart';

class GenerateQuotationController extends GetxController{

  TextEditingController locationEditingController = TextEditingController();

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController mobileNumberEditingController = TextEditingController();
  TextEditingController contractorEditingController = TextEditingController();
  TextEditingController subjectEditingController = TextEditingController();
  // Email field — passed to quotation/store to trigger mail_sent
  TextEditingController emailEditingController = TextEditingController();

  TextEditingController datePickerController = TextEditingController();
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

  /// Builds the payload and calls quotation/store.
  /// Optionally pass [email] to trigger mail sending on the backend.
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
      Get.snackbar("Error", res?.message ?? "Failed to generate quotation.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final url = res.whatsappUrl;
    if (url != null && url.isNotEmpty) {
      extractAndOpenWhatsApp(url);
    } else {
      Get.snackbar("Error", "WhatsApp URL not available.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  /// Send Mail — stores quotation with email param, backend triggers mail.
  Future<void> sendMailAction() async {
    final email = emailEditingController.text.trim();
    if (email.isEmpty) {
      Get.snackbar("Email Required",
          "Please enter an email address to send the quotation.",
          backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return;
    }

    final res = await _storeQuotation(email: email);
    if (res == null || res.status != true) {
      Get.snackbar("Error", res?.message ?? "Failed to send mail.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (res.mailSent == true) {
      Get.snackbar("Success", "Quotation mail sent successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar("Info",
          res.message ?? "Quotation created. Mail status unavailable.",
          backgroundColor: Colors.blueGrey, colorText: Colors.white);
    }
  }

  /// Download PDF — stores quotation, opens pdf_url from response.
  Future<void> downloadPdfAction() async {
    final res = await _storeQuotation();
    if (res == null || res.status != true) {
      Get.snackbar("Error", res?.message ?? "Failed to generate PDF.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final pdfUrl = res.pdfUrl;
    if (pdfUrl != null && pdfUrl.isNotEmpty) {
      final Uri uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar("Error", "Cannot open PDF URL.",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } else {
      Get.snackbar("Error", "PDF URL not available.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
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