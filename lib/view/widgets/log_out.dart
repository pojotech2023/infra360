import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/service/shared_preference_service.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/app_text_style.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Logout',style: AppTextStyle.appBarTextStyle,),
      content: Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close dialog
          child: Text('Cancel',
          style: AppTextStyle.textMedium.copyWith(
              color: Colors.redAccent
          )),
        ),
        TextButton(
          onPressed: () {
            PreferenceUtils().init();
            PreferenceUtils().clear();
            Navigator.of(context).pop(); // Close dialog
            // Your logout logic here
            // Example: Get.offAllNamed('/login');
            Get.offAllNamed('/login');
          }, // Close dialog
          child: Text('Logout',
          style: AppTextStyle.textMedium.copyWith(
            color: Colors.green
          ),),
        ),

      ],
    ),
  );
}


void deleteDialog(BuildContext context,Function onDelete) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Alert',style: AppTextStyle.appBarTextStyle,),
      content: Text('Are you sure you want to delete?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close dialog
          child: Text('No',
              style: AppTextStyle.textMedium.copyWith(
                  color: Colors.redAccent
              )),
        ),
        TextButton(
          onPressed: (){
            onDelete(); // Then perform the delete action

            Navigator.of(context).pop(); // Close the dialog first
          },
          child: Text('Yes',
            style: AppTextStyle.textMedium.copyWith(
                color: Colors.green
            ),),
        ),

      ],
    ),
  );
}

