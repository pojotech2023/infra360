import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_dashboard/subcontractor_dashboard_screen.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_management/subcontractor_management_screen.dart';
import 'package:raptor_pro/view/vendor/vendor_dashboard/vendor_dashboard_screen.dart';
import 'package:raptor_pro/view/vendor/vendor_management/vendor_management_screen.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';

class SubContractorMainScreen extends StatefulWidget{
  @override
  State<SubContractorMainScreen> createState() => _SubContractorMainScreenState();
}

class _SubContractorMainScreenState extends State<SubContractorMainScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "SubContractor",
          onTap: (){
            Get.back();

          }),
      body:  SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            VerticalSpacing.d16px(),

            InkWell(
              onTap: (){
                Get.to(SubContractorDashboardScreen());
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                height: 65,
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
                child: Text("SubContractor Dashboard"),
              ),
            ),
            VerticalSpacing.d16px(),
            InkWell(
              onTap: (){

                Get.to(SubcontractorManagementScreen());

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
                child: Text("Subcontractor Management"),
              ),
            ),
          ],
        ),
      ),
    );
  }



}