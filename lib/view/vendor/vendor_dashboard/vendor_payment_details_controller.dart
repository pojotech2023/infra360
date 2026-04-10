import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/vendor_payment_details_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class VendorPaymentDetailsController extends GetxController{

  RxBool isLoading=true.obs;
  RxBool isButtonLoading=false.obs;
  var vendorDataList = VendorPaymentDetailsData().obs;
  TextEditingController openingBalanceController = TextEditingController();

  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }

  init()async{
    isLoading.value=true;
    VendorPaymentDetailsModel ?vendorPaymentDetailsModel=   await ApiData().vendorPaymentDetail(Get.arguments);

    if(vendorPaymentDetailsModel!=null){
      vendorDataList.value=vendorPaymentDetailsModel.data?? VendorPaymentDetailsData();
      final payDetail = vendorDataList.value.payDetail;

      openingBalanceController.text = payDetail?.openingBalance ?? '';
    }

    isLoading.value=false;


  }

  paymentUpdate()async{
    isButtonLoading.value=true;
    final payDetail = vendorDataList.value.payDetail;

    final Map<String, dynamic> vendorPaymentMap = {
      "vendor_id": Get.arguments,
      "opening_balance": openingBalanceController.text,
      "total_units": payDetail!.totalUnits,
      "total_unit_price": payDetail.totalUnitPrice,
      "balance_amount": payDetail.balanceAmount,
      "paid_amount": payDetail.paidAmount,
    };
    CommonSuccessResponseModel ?commonSuccessResponseModel=   await ApiData().vendorPaymentUpdateDetail(vendorPaymentMap);
    if(commonSuccessResponseModel!=null){
      showToastMessage(commonSuccessResponseModel.message??"Something Went wrong");
      Get.back();
    }
    isButtonLoading.value=false;

  }
}