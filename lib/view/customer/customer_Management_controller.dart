import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/supervisor_list_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

import '../../model/customer_model.dart';
import '../../utils/res/date_picker.dart';
import 'customer_list_controller.dart';

class CustomerManagementController extends GetxController{

  RxBool isLoading=true.obs;
  RxBool isSaveLoading=false.obs;


  TextEditingController nameEditingController = TextEditingController();
  TextEditingController mobileNumberEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController dobEditingController = TextEditingController();
  TextEditingController marrageDateEditingController = TextEditingController();
  TextEditingController addressEditingController = TextEditingController();
  Customers? customerData = Get.arguments;

  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }

  init()async{


    isLoading.value=true;
     customerData = Get.arguments;
   nameEditingController.text = customerData!.name??"";
    mobileNumberEditingController.text = customerData!.mobileNo??"";
 emailEditingController.text = customerData!.email??"";
    dobEditingController.text = formatDate(customerData!.dob??"") ??"";//customerData!.dob.toString()??"";
  marrageDateEditingController.text = formatDate(customerData!.marriageDate ??'') ??"";
   addressEditingController.text = customerData!.address??"";



    isLoading.value=false;

  }



  updateCustomer()async{

    int customerid = customerData!.id!;
    int siteid = customerData!.siteId!;

    isSaveLoading.value=true;

    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().updateCustomer(
        customerid,siteid,nameEditingController.text,
        mobileNumberEditingController.text, emailEditingController.text,
        dobEditingController.text,marrageDateEditingController.text,
        addressEditingController.text);

    if(commonSuccessModel!=null){
      CustomerListController list  = Get.find();
      list.init();


      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      Get.back();

      update();
    }

    isSaveLoading.value=false;
  }


}