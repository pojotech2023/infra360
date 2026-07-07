import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class AddVendorPaymentController extends GetxController{

  RxBool isLoading= false.obs;

  TextEditingController paymentController =TextEditingController();
  final TextEditingController datePickerController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  RxnString ?selectedPayment = RxnString();


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  addPayment()async{
    isLoading.value =true;

    print("Get.arguments: ${Get.arguments}");
    print("Vendor ID from arguments: ${Get.arguments}");

    if (Get.arguments == null) {
      showToastMessage("Vendor ID is missing. Please try again.");
      isLoading.value = false;
      return;
    }

    Map<String,dynamic> postData ={
      "vendor_id":Get.arguments,
      "payment": paymentController.text,
      "date":datePickerController.text,
      "payment_mode":selectedPayment!.value,
      "remarks": remarksController.text
    };

    print("Payment Data: $postData");

    CommonSuccessResponseModel ?model= await ApiData().vendorPaymentUpdate(postData);

    if(model!=null){
      showToastMessage(model.message??"Something Went wrong");
      Get.back();
    }

    isLoading.value=false;

  }
}