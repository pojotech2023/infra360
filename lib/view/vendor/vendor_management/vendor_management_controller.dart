import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/vendor_management_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class VendorManagementController extends GetxController{
  RxBool isLoading=true.obs;
  var vendorManagementData = <VendorManagementData>[].obs;

  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  String ?selectedSiteUtilities;
  RxBool isSaveLoading=false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }

  init()async{
    isLoading.value=true;
    VendorManagementModel ?vendorManagementModel= await ApiData().vendorManagementList();

    if(vendorManagementModel!=null){
      vendorManagementData.value = vendorManagementModel.data??[];
    }

    isLoading.value=false;
  }

  preFillMethod(){
    VendorManagementData ?vendorManagementData = Get.arguments;
    if(vendorManagementData!=null){
      nameController.text=vendorManagementData.name??"";
      gstController.text=vendorManagementData.gst??"";
      emailController.text=vendorManagementData.email??"";
      addressController.text=vendorManagementData.address??"";
      mobileController.text=vendorManagementData.mobileNo??"";
      selectedSiteUtilities=vendorManagementData.siteUtilities;

      print("vendorManagementData.siteUtilities ${vendorManagementData.siteUtilities}");
    }
  }

  clearMethod(){
    nameController.clear();
    gstController.clear();
    emailController.clear();
    addressController.clear();
    mobileController.clear();
    selectedSiteUtilities=null;
  }

  deleteVendor(int id)async{

    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().deleteVendor(id);

    if(commonSuccessModel!=null){
      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      init();
    }

  }

  addVendor()async{
    isSaveLoading.value=true;
    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().addVendor(
      name: nameController.text,
      mobileNo: mobileController.text,
      email: emailController.text,
      gst: gstController.text,
      address: addressController.text,
      siteUtilities: selectedSiteUtilities
    );

    if(commonSuccessModel!=null){
      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      Get.back();
      init();
    }
    isSaveLoading.value=false;
  }

  updateVendor()async{
    isSaveLoading.value=true;
    VendorManagementData ?vendorManagementData = Get.arguments;

    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().updateVendor(
        id: vendorManagementData!.id,
        name: nameController.text,
        mobileNo: mobileController.text,
        email: emailController.text,
        gst: gstController.text,
        address: addressController.text,
        siteUtilities: selectedSiteUtilities
    );

    if(commonSuccessModel!=null){
      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      Get.back();
      init();
    }
    isSaveLoading.value=false;
  }
}