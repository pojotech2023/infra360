
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

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

  TextEditingController datePickerController = TextEditingController();
  var totalAmt = 0.0.obs;


  var quotationList = <QuotationData>[].obs;

  // Loading indicator
  var isLoading = false.obs;
  var issubmitLoading = false.obs;


  @override
  void onInit() {
    // TODO: implement onInit
    quotation();
    super.onInit();
  }


  Future<void> quotation() async {
    try {
      isLoading.value = true;
      quotationList.clear();

      // Call API
      QuotationModel? response =
      await ApiData().quotationListApi();

       quotationList.value = response?.data ?? [];
      calculateTotal();
      isLoading.value = false;

    } catch (e) {
      print("Error loading subcontractor data: $e");
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
    isLoading.value = false;
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



  Future<void> genrateQuotationApi() async {
    try {
      issubmitLoading.value = true;

      // Convert your quotationList (which contains TextEditingControllers)
      // into a clean JSON array for API
      List<Map<String, dynamic>> quotationData = quotationList.map((item) {
        return {
          "particular": item.particular?.text ?? "",
          "rate": item.rate?.text ?? "0",
          "sqFt": item.sqFt?.text ?? "0",
          "unit": item.unit ?? "", // assuming you have a dropdown or string field for unit
        };
      }).toList();

      // Prepare full request payload
      var data = {
        "name": nameEditingController.text,
        "subject": subjectEditingController.text,
        "date": convertDateFormat(datePickerController.text),
        "mobile_no": mobileNumberEditingController.text,
        "location": locationEditingController.text,
        "contractor": contractorEditingController.text,
        "data": quotationData,
      };

      // Debug print to verify payload
      print("REQUEST BODY: $data");

      // Call API
      QuotationStoredModel? response = await ApiData().quotationStoreApi(data);
      shareQuotation(response!.whatsappUrl ?? '');

    } catch (e) {
      print("Error in genrateQuotationApi: $e");
    } finally {
      issubmitLoading(false);
    }
    update();
  }


  String convertDateFormat(String inputDate) {
    try {
      // Parse from dd-MM-yyyy
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(inputDate);

      // Convert to yyyy-MM-dd
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      return formattedDate;
    } catch (e) {
      print("Error parsing date: $e");
      return inputDate; // Return the original if parsing fails
    }
  }


  void shareQuotation(String url) {

    extractAndOpenWhatsApp(url);
  }



}