import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/supervisor_list_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

import '../../../model/subcontractor_list_model.dart';

class SubcontractorManagementController extends GetxController{

  RxBool isLoading=true.obs;
  RxBool isSaveLoading=false.obs;
  var selectedSiteUtilities = ''.obs;

  var subcontractorList = <Subcontractor>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }

  init()async{
     isLoading.value=true;

     SubcontractorModel ?subcontractorModel= await ApiData().subContractorManagementList();

    if(subcontractorModel!=null){
      subcontractorList.value= subcontractorModel.data??[];
    }
     isLoading.value=false;

  }

  addSubcontractor({String? name,String? mobileNo,String? emailId,String? contractor,String? address,String? gst})async{
    isSaveLoading.value=true;

    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().addSubContractor(name: name,mobileNo:  mobileNo,email:  emailId,siteUtilities: contractor,address: address,gst: gst);

    if(commonSuccessModel!=null){
      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      Get.back();
      init();
    }

    isSaveLoading.value=false;
  }

  deleteSupervisor(int id)async{

    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().deleteSubContractor(id);

    if(commonSuccessModel!=null){
      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      init();
    }

    isSaveLoading.value=false;
  }

  updateSupervisor({required int id,String? name,String? mobileNo,String? emailId,String? contractor,String? address,String? gst})async{
    isSaveLoading.value=true;

    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().updateSubContractor(id: id,name: name,mobileNo:  mobileNo,email:  emailId,siteUtilities: contractor,address: address,gst: gst);

    if(commonSuccessModel!=null){
      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      Get.back();
      init();
    }

    isSaveLoading.value=false;
  }


}