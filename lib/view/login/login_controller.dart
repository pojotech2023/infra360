import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/login_response.dart';
import 'package:raptor_pro/service/api_service.dart';
import 'package:raptor_pro/service/shared_preference_service.dart';
import 'package:raptor_pro/view/dashboard/dashboard_screen.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class LoginController extends GetxController{

  var isLoading =false.obs;

  onLoginSubmit(String mobileNumber,String password)async{

    isLoading.value = true;
    try {
      LoginResponse ?loginResponse= await ApiData().loginApi(mobileNumber, password);

      if(loginResponse?.data!=null){
        PreferenceUtils().setAccessToken(loginResponse!.data!.token!);
        String user = jsonEncode(loginResponse);


        PreferenceUtils().setUserInfo(user);
        Get.offAll(() => DashboardScreen());
      }
    } catch (e) {

          showToastMessage( e.toString().replaceFirst('Exception: ', ''));

      // Get.snackbar("Error", e.toString().replaceFirst('Exception: ', ''),
      //     snackPosition: SnackPosition.BOTTOM);
    }

    isLoading.value = false;
  }

}