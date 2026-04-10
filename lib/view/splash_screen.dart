import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/service/shared_preference_service.dart';
import 'package:raptor_pro/utils/res/images.dart';
import 'package:raptor_pro/view/dashboard/dashboard_screen.dart';

import 'login/login_screen.dart';

class SplashScreen extends StatefulWidget{
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(const Duration(milliseconds: 500), () {

      if (PreferenceUtils().getSessionToken().isEmpty) {
        Get.offAll(() => LoginScreen());
      }
      else{
        Get.offAll(() => DashboardScreen());
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Images.appLogo,width: 150,height: 150,),
            SizedBox(height: 8,),
            Image.asset(Images.appName,width: 150,height: 56,),

          ],
        )
      ),
    );
  }
}