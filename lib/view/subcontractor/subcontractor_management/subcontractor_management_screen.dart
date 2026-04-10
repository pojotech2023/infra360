import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/subcontractor_list_model.dart';
import 'package:raptor_pro/model/supervisor_list_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_management/subcontractor_management_controller.dart';
import 'package:raptor_pro/view/supervisor_management/add_supervisor_management.dart';
import 'package:raptor_pro/view/supervisor_management/supervisor_management_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/view/widgets/log_out.dart';

import 'add_subcontractor_management.dart';

class SubcontractorManagementScreen extends StatefulWidget{
  @override
  State<SubcontractorManagementScreen> createState() => _SubcontractorManagementScreenState();
}

class _SubcontractorManagementScreenState extends State<SubcontractorManagementScreen> {

  SubcontractorManagementController controller = Get.put(SubcontractorManagementController());


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
  return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Subcontractor Creation",
          onTap: (){
            Get.back();

          }),
    floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: (){

          Get.to(AddSubcontractorManagementScreen());

    }),
    body: Obx((){
      return controller.isLoading.value?Center(
        child: CommonLoader(),
      ):
        SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            ListView.builder(
              shrinkWrap: true,
                primary: false,
                itemCount: controller.subcontractorList.length,
                itemBuilder: (BuildContext context,int index){
                Subcontractor subcontractorData=  controller.subcontractorList[index];
                return Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border:
                      Border.all(color: Color(0xFFDCE1EF), width: 1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textWidget("Name : ",subcontractorData.name??""),
                        Row(
                          children: [
                            InkWell(
                              onTap: (){
                                Get.to(AddSubcontractorManagementScreen(),arguments: subcontractorData);

                              },
                              child: Icon(Icons.edit_note,
                                size: 30,
                                color: AppColor.buttonLightBlue,),
                            ),
                            HorizontalSpacing.d10px(),
                            InkWell(
                              onTap: (){
                                deleteDialog(context,(){
                                  controller.deleteSupervisor(subcontractorData.id!);

                                });
                              },
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Icon(Icons.delete,
                                  color: Colors.redAccent,),
                              ),
                            ),
                          ],
                        )
                        ],
                      ),


                      VerticalSpacing.d5px(),

                      textWidget("subcontractor : ",subcontractorData.subcontractors??""),
                      VerticalSpacing.d5px(),
                      textWidget("Mobile Number : ",subcontractorData.mobileNo??""),
                      VerticalSpacing.d5px(),
                      textWidget("Email : ",subcontractorData.email??""),

                    ],
                  ),
                );

            })

          ],
        ),
      );
    })
  );

  }
  textWidget(String title,String value){
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyle.textRegular15,
        ),
        Text(
          value,
          style: AppTextStyle.textMedium.copyWith(fontSize: 15),

        ),
      ],
    );
  }
}