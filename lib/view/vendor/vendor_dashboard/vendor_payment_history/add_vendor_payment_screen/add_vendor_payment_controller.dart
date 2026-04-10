import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class AddVendorPaymentController extends GetxController{

  RxBool isLoading= false.obs;

  TextEditingController paymentController =TextEditingController();
  final TextEditingController datePickerController = TextEditingController();
  RxnString ?selectedPayment = RxnString();


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  addPayment()async{
    isLoading.value =true;

    Map<String,dynamic> postData ={
      "vendor_id":Get.arguments,
      "payment": paymentController.text,
      "date":datePickerController.text,
      "payment_mode":selectedPayment!.value
    };


    CommonSuccessResponseModel ?model= await ApiData().vendorPaymentUpdate(postData);

    if(model!=null){
      showToastMessage(model.message??"Something Went wrong");
      Get.back();
    }

    isLoading.value=false;

  }
}