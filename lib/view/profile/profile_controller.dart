

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/user_profile_model.dart';

import '../../api/api_data.dart';
import '../../model/profile_update_success_model.dart';
import '../../service/shared_preference_service.dart';
import '../dashboard/dashboard_controller.dart';
import '../widgets/toast.dart';

class ProfileController extends GetxController{

  var isLoading = false.obs;
  var isSaveLoading = false.obs;

var profileId = ''.obs;
var profileImage = ''.obs;
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();






  @override
  void onInit() {
  viewProfileApi();
    super.onInit();
  }

  viewProfileApi() async{
    isLoading.value=true;
    UserProfileModel ?model=await ApiData().viewProfile();


    isLoading.value=false;

    if(model!=null){
      profileId.value = model.data!.id.toString()??"";
      profileImage.value = model.data!.image.toString()??"";
    nameController.text =   model.data!.name ??"";
    mobileController.text =   model.data!.mobileNo ??"";
    emailController.text =   model.data!.email ??"";
    //passwordController.text =   model.data!.password ??"";
   // confirmpasswordController.text =   model.data!.password ??"";


      showToastMessage(model.message??"Something Went wrong");

    }
    update();

  }

  updateProfileApi({File? files}) async {
    isSaveLoading.value=true;
    ProfileUpdateSuccessfullyModel ?model=await ApiData().updateProfile(
        userID: profileId.value,
        name: nameController.text,
        email: emailController.text,
      //  password: passwordController.text,
         files: files);


    isSaveLoading.value=false;

    if(model!=null){
      showToastMessage(model.message??"Something Went wrong");
      showToastMessage(model.message ?? "Updated");

      /// UPDATE LOCAL PREF DATA
      final userJson = jsonDecode(PreferenceUtils().getUserInfo());
      userJson['data']['user']['name'] = nameController.text;
      userJson['data']['user']['image'] = model.data?.image ?? "";

      /// Save back to Shared Preference
      PreferenceUtils().setUserInfo(jsonEncode(userJson));

      /// Update Dashboard Controller values
      final d = Get.find<DashboardController>();
     d.updateFromPreference();
      d.update();


      Get.back();
    }else{
      showToastMessage("Something Went wrong");
    }

  }
}