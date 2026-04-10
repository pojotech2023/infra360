import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/other_utilities_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class OthersSubcontractorController extends GetxController{
  Rx<bool> isButtonLoading =false.obs;
  TextEditingController reMarksController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  RxList<OtherUtilitiesData> otherUtilitiesData = <OtherUtilitiesData>[].obs;


  otherSave(int siteId, File file)async{
    isButtonLoading.value=true;

    CommonSuccessResponseModel ?successResponseModel =await ApiData().addUtilitiesSubcontractor(
       files:file, siteId: siteId.toString(), amount:  amountController.text, remarks: reMarksController.text,);

    if(successResponseModel!=null){
      amountController.clear();
      reMarksController.clear();

      showToastMessage(successResponseModel.message??"Other Utilities Added Successfully!.");
    }

    isButtonLoading.value=false;
  }

  otherUtilitiesView(int siteId)async{
    OtherUtilitiesModel ?otherUtilitiesModel =await ApiData().otherUtilitiesSubcontractorListApi(siteId);

    if(otherUtilitiesModel!=null){
      otherUtilitiesData.value= otherUtilitiesModel.data??[];
    }

    }

}