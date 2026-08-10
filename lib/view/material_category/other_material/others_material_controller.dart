import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/utils/file_download.dart';
import 'package:raptor_pro/model/other_utilities_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class OthersMaterialController extends GetxController{
  Rx<bool> isButtonLoading =false.obs;
  TextEditingController reMarksController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  RxList<OtherUtilitiesData> otherUtilitiesData = <OtherUtilitiesData>[].obs;


  otherSave(int siteId, File file)async{
    isButtonLoading.value=true;

    // Convert display format DD-MM-YYYY back to backend format YYYY-MM-DD
    String apiDate = dateController.text;
    if (apiDate.isNotEmpty && apiDate.contains('-')) {
      final parts = apiDate.split('-');
      if (parts.length == 3 && parts[0].length == 2) {
        // DD-MM-YYYY -> YYYY-MM-DD
        apiDate = "${parts[2]}-${parts[1]}-${parts[0]}";
      }
    }

    CommonSuccessResponseModel ?successResponseModel =await ApiData().addUtilities(files: file,siteId: siteId.toString(),
        amount:amountController.text,remarks: reMarksController.text, date: apiDate);

    if(successResponseModel!=null){
      amountController.clear();
      reMarksController.clear();
      showToastMessage(successResponseModel.message??"Other Utilities Added Successfully!.");
    }

    isButtonLoading.value=false;
  }

  otherUtilitiesView(int siteId)async{
    OtherUtilitiesModel ?otherUtilitiesModel =await ApiData().otherUtilitiesListApi(siteId);

    if(otherUtilitiesModel!=null){
      otherUtilitiesData.value= otherUtilitiesModel.data??[];
    }
  }

  updateOtherUtility(int id, int siteId, String amount, String remarks, String date) async {
    isButtonLoading.value = true;
    
    // Convert DD-MM-YYYY to YYYY-MM-DD
    String apiDate = date;
    if (apiDate.contains('-')) {
      final parts = apiDate.split('-');
      if (parts.length == 3 && parts[0].length == 2) {
        apiDate = "${parts[2]}-${parts[1]}-${parts[0]}";
      }
    }

    final res = await ApiData().updateOtherUtilityApi(id, {"amount": amount, "remarks": remarks, "date": apiDate});
    if (res != null) {
      showToastMessage(res.message ?? "Updated successfully");
      await otherUtilitiesView(siteId);
    } else {
      showToastMessage("Failed to update. Please try again.");
    }
    isButtonLoading.value = false;
  }

  deleteOtherUtility(int id, int siteId) async {
    isButtonLoading.value = true;
    final res = await ApiData().deleteOtherUtilityApi(id);
    if (res != null) {
      showToastMessage(res.message ?? "Deleted successfully");
      await otherUtilitiesView(siteId);
    } else {
      showToastMessage("Failed to delete. Route might be missing on backend.");
    }
    isButtonLoading.value = false;
  }


  void otherUtilitiesExcelDownload(BuildContext context, int siteId) {
    final String reportUrl = "${baseUrl}site-utilities/$siteId/export";
    CommonFileDownloader.downloadAndOpen(
      urls: reportUrl,
      context: context,
      fileName: "utilities_report.pdf",
    );
  }
}