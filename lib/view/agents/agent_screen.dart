import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/agent_list_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/agents/add_agent_management.dart';
import 'package:raptor_pro/view/agents/agent_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/view/widgets/log_out.dart';

class AgentManagementScreen extends StatefulWidget{
  @override
  State<AgentManagementScreen> createState() => _AgentManagementScreenState();
}

class _AgentManagementScreenState extends State<AgentManagementScreen> {

  AgentManagementController controller = Get.put(AgentManagementController());


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: CommonAppBar.appBar(
            title: "Agent Management",
            onTap: (){
              Get.back();

            }),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add, color: Colors.white),
            onPressed: (){

              Get.to(AddAgentManagementScreen());

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
                    itemCount: controller.agentList.length,
                    itemBuilder: (BuildContext context,int index){
                      AgentListData agentData=  controller.agentList[index];
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
                                textWidget("Name : ",agentData.name??""),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        Get.to(AddAgentManagementScreen(),arguments: agentData);

                                      },
                                      child: Icon(Icons.edit_note,
                                        size: 30,
                                        color: AppColor.buttonLightBlue,),
                                    ),
                                    HorizontalSpacing.d10px(),
                                    InkWell(
                                      onTap: (){
                                        deleteDialog(context,(){
                                          controller.deleteAgent(agentData.id!);

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


                            textWidget("Company Name : ",agentData.companyName??""),
                            VerticalSpacing.d5px(),


                            textWidget("Mobile Number : ",agentData.mobileNo??""),
                            VerticalSpacing.d5px(),

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