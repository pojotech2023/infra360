import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

import '../../../../model/subcontractor_dashboard_model.dart';
import '../subcontractor_payment_history_controller.dart';

class AddSubContractorPaymentController extends GetxController{

  RxBool isLoading= false.obs;

  TextEditingController paymentController =TextEditingController();
  TextEditingController nameController =TextEditingController();
  final TextEditingController datePickerController = TextEditingController();
  RxnString ?selectedPayment = RxnString();
  SubContractorData data = Get.arguments;

  @override
  void onInit() {
    // TODO: implement onInit
    nameController.text = data.subcontractorName.toString();
    super.onInit();
  }

  addSubContractorPayment()async{
    isLoading.value =true;

    Map<String,dynamic> postData ={
     // "site_id":Get.arguments,
      "subcontractor_id":data.subcontractorId,
      "payment": paymentController.text,
      "date":datePickerController.text,
      "payment_mode":selectedPayment!.value
    };


    CommonSuccessResponseModel ?model= await ApiData().vendorSubContractorUpdate(postData);

    if(model!=null){
      SubContractorPaymentHistoryController controller = Get.find<SubContractorPaymentHistoryController>();
      controller.fetchPaymentHistory();

      showToastMessage(model.message??"Something Went wrong");
      Get.back();
    }

    isLoading.value=false;

  }
}