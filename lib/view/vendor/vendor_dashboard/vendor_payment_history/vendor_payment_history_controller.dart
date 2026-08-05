import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/vendor_payment_history_model.dart';
import 'package:raptor_pro/utils/file_download.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class VendorPaymentHistoryController extends GetxController{

  RxBool isLoading= true.obs;
  RxBool isExporting = false.obs;

  var paymentHistoryData = VendorPaymentHistoryData().obs;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init()async{
    isLoading.value =true;

    VendorPaymentHistoryModel ?model= await ApiData().vendorPaymentHistory(Get.arguments);

    if(model!=null){
      paymentHistoryData.value=  model.data!;
      print("Payment History Data: ${paymentHistoryData.value.toJson()}");
      if (paymentHistoryData.value.paymentHistoryList != null) {
        print("Payment History List Length: ${paymentHistoryData.value.paymentHistoryList!.length}");
        for (var item in paymentHistoryData.value.paymentHistoryList!) {
          print("Payment Item - ID: ${item.id}, Payment: ${item.payment}, Date: ${item.date}");
        }
      }
    }

    isLoading.value=false;
  }

  deletePayment(int id) async {
    isLoading.value = true;
    final res = await ApiData().deletePaymentApi(id);
    if (res != null && (res.status == true || res.responseCode == 200)) {
      showToastMessage(res.message ?? "Deleted successfully");
      init();
    } else {
      showToastMessage("Failed to delete payment");
      isLoading.value = false;
    }
  }

  Future<void> vendorPaymentHistoryExport(BuildContext context) async {
    isExporting.value = true;
    final res = await ApiData().vendorPaymentHistoryExportApi(Get.arguments);

    if (res != null && res.downloadUrl != null) {
      CommonFileDownloader.downloadAndOpen(
        urls: res.downloadUrl ?? "",
        context: context,
        fileName: "vendor_payment_history_${Get.arguments}.csv",
      );
    } else {
      showToastMessage("Failed to generate export URL.");
    }
    isExporting.value = false;
  }
}