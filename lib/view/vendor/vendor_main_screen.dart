import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';import 'package:raptor_pro/view/vendor/vendor_dashboard/vendor_dashboard_screen.dart';
import 'package:raptor_pro/view/vendor/vendor_management/vendor_management_screen.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';

class VendorMainScreen extends StatefulWidget{
  @override
  State<VendorMainScreen> createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
     appBar: CommonAppBar.appBar(
         title: "Vendor",
         onTap: (){
           Get.back();

         }),
     body:  SingleChildScrollView(
       padding: EdgeInsets.all(16),
       child: Column(
         children: [
           InkWell(
             onTap: (){
               Get.to(VendorManagementScreen());
             },
             child: Container(
               width: double.infinity,
               height: 65,
               alignment: Alignment.center,
               padding: EdgeInsets.all(16),
               decoration: BoxDecoration(
                   color: AppColor.white,
                   boxShadow: [
                     BoxShadow(
                       color: Colors.grey.withOpacity(0.2),
                       spreadRadius: 1,
                       blurRadius: 10,
                       offset: Offset(0, 8), // vertical offset for soft shadow
                     ),
                   ],
                   borderRadius: BorderRadius.circular(10),
                  ),
               child: Text("Vendor Management"),
             ),
           ),
           VerticalSpacing.d16px(),
           InkWell(
             onTap: (){

               Get.to(VendorDashboardScreen());
       
             },
             child: Container(
               width: double.infinity,
               height: 65,
               alignment: Alignment.center,
               padding: EdgeInsets.all(16),
               decoration:  BoxDecoration(
                 color: AppColor.white,
                 boxShadow: [
                   BoxShadow(
                     color: Colors.grey.withOpacity(0.2),
                     spreadRadius: 1,
                     blurRadius: 10,
                     offset: Offset(0, 8), // vertical offset for soft shadow
                   ),
                 ],
                 borderRadius: BorderRadius.circular(10),
               ),
               child: Text("Vendor Dashboard"),
             ),
           ),


       
         ],
       ),
     ),
   );
  }



}