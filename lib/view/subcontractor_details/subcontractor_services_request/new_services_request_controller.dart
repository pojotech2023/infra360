

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/vendor_model.dart';
import 'package:raptor_pro/view/subcontractor_details/subcontractor_services_request/request_details_controller.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

import '../../../model/subcontractor_list_model.dart';
import '../subcontractor_sitewise_controller.dart';

class NewServicesRequestController extends GetxController{


  RxList<Subcontractor> getLists = <Subcontractor>[].obs;

  Rxn<Subcontractor> selectedSubContractorData = Rxn<Subcontractor>();

  var isLoading =false.obs;
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController countController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  void onInit() {
    getSubcontractorApi();
    super.onInit();
  }


  getSubcontractorApi()async{
    isLoading.value=true;

    SubcontractorModel ?subcontractorModel= await ApiData().subContractorManagementList();

    if(subcontractorModel!=null){
      getLists.value= subcontractorModel.data??[];
    }
    isLoading.value=false;

  }

  addServicesApi(int siteId)async{
    isLoading.value=true;
    Map<String,dynamic> postedData={
      "site_id":siteId,
      'subcontractor_id': selectedSubContractorData.value!.id,
      'subcontractor_type': selectedSubContractorData.value!.subcontractors,
      'date': dateController.text,
      'amount': amountController.text,
      'no_counts': countController.text



    };

    CommonSuccessResponseModel ?commonSuccessResponseModel= await ApiData()
        .addSubcontractorServicesApi(postedData);

    if(commonSuccessResponseModel!=null){
      if(commonSuccessResponseModel.responseCode==200){
        showToastMessage(commonSuccessResponseModel.message??"");

        SubcontractorController controller = Get.find();
        controller.init(siteId);
        RequestDetailsController detailsController = Get.find();
        detailsController.fetchData();
        Get.back();
      }
      else{
        showToastMessage(commonSuccessResponseModel.message??"");

      }
    }
    isLoading.value=false;
update();
  }
}