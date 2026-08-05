import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/subcontractor_payment_history_model.dart';
import 'package:raptor_pro/utils/file_download.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class SubcontractorPaymentHistoryController extends GetxController{

  RxBool isLoading= true.obs;
  RxBool isExporting = false.obs;

  var paymentHistoryData = SubContractorPaymentHistory().obs;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init()async{
    isLoading.value =true;

    SubContractorPaymentHistoryModel ?model= await ApiData().subcontractorPaymentHistory(Get.arguments);

    if(model!=null){
      paymentHistoryData.value=  model.data!;
      print("Subcontractor Payment History Data: ${paymentHistoryData.value.toJson()}");
      if (paymentHistoryData.value.paymentHistoryList != null) {
        print("Payment History List Length: ${paymentHistoryData.value.paymentHistoryList!.length}");
        for (var item in paymentHistoryData.value.paymentHistoryList!) {
          print("Payment Item - ID: ${item.id}, Payment: ${item.payment}, Date: ${item.date}");
        }
      }
      if (paymentHistoryData.value.paymentHistoryList != null) {
        double total = 0;
        for (var item in paymentHistoryData.value.paymentHistoryList!) {
          double paymentVal = double.tryParse(item.payment ?? '0') ?? 0;
          total += paymentVal;
        }
        paymentHistoryData.value.totalPaidAmount = total.toInt();
      }
    }

    isLoading.value=false;
  }

  deletePayment(int id) async {
    isLoading.value = true;
    final res = await ApiData().deleteSubPaymentApi(id);
    if (res != null && (res.status == true || res.responseCode == 200)) {
      showToastMessage(res.message ?? "Deleted successfully");
      init();
    } else {
      showToastMessage("Failed to delete payment");
      isLoading.value = false;
    }
  }

  Future<void> subcontractorPaymentHistoryExport(BuildContext context) async {
    isExporting.value = true;
    final res = await ApiData().subcontractorPaymentHistoryExportApi(Get.arguments);

    if (res != null && res.downloadUrl != null) {
      CommonFileDownloader.downloadAndOpen(
        urls: res.downloadUrl ?? "",
        context: context,
        fileName: "subcontractor_payment_history_${Get.arguments}.csv",
      );
    } else {
      showToastMessage("Failed to generate export URL.");
    }
    isExporting.value = false;
  }
}
