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
import 'package:raptor_pro/view/dashboard/dashboard_controller.dart';

import 'add_subcontractor_management.dart';

class SubcontractorManagementScreen extends StatefulWidget{
  @override
  State<SubcontractorManagementScreen> createState() => _SubcontractorManagementScreenState();
}

class _SubcontractorManagementScreenState extends State<SubcontractorManagementScreen> {

  SubcontractorManagementController controller = Get.put(SubcontractorManagementController());
  DashboardController dashboardController = Get.find<DashboardController>();

  bool canAdd() {
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.subcontractorManagement?.addSubcontractor == 1;
  }
  
  bool canEdit() {
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.subcontractorManagement?.editSubcontractor == 1;
  }

  bool canDelete() {
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.subcontractorManagement?.deleteSubcontractor == 1;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
  return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Subcontractor Creation",
          onTap: (){
            Get.back();

          }),
    floatingActionButton: Obx(() => canAdd() ? FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: (){

          Get.to(AddSubcontractorManagementScreen());

    }) : SizedBox.shrink()),
    body: SafeArea(
      child: Obx((){
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
                return AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(0),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1.0, -0.8),
                      end: Alignment(1.0, 0.8),
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFF5F7FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFE65100).withOpacity(0.12),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color(0xFFE65100).withOpacity(0.06),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFE3E8F0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with avatar and actions
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFE65100).withOpacity(0.05),
                                  Color(0xFFFF9800).withOpacity(0.02),
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFE65100),
                                        Color(0xFFFF9800),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFE65100).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      (subcontractorData.name?.substring(0, 1).toUpperCase() ?? 'S'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Name
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subcontractorData.name ?? '',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A365D),
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 6),
                                      if (subcontractorData.subcontractors != null && subcontractorData.subcontractors!.isNotEmpty)
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFF9800).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Color(0xFFFF9800).withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.business_rounded,
                                                size: 14,
                                                color: Color(0xFFE65100),
                                              ),
                                              SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  subcontractorData.subcontractors ?? '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFE65100),
                                                    letterSpacing: 0.3,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Action buttons
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (canEdit())
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFF9800).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: InkWell(
                                          onTap: (){
                                            Get.to(AddSubcontractorManagementScreen(),arguments: subcontractorData);
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Icon(
                                              Icons.edit_rounded,
                                              size: 20,
                                              color: Color(0xFFE65100),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (canEdit() && canDelete()) SizedBox(width: 8),
                                    if (canDelete())
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFEF5350).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: InkWell(
                                          onTap: (){
                                            deleteDialog(context,(){
                                              controller.deleteSupervisor(subcontractorData.id!);
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Icon(
                                              Icons.delete_rounded,
                                              size: 20,
                                              color: Color(0xFFD32F2F),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Details section
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Contact info row
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone_rounded,
                                      size: 18,
                                      color: Color(0xFF78909C),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      subcontractorData.mobileNo ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF455A64),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 24),
                                    Icon(
                                      Icons.email_rounded,
                                      size: 18,
                                      color: Color(0xFF78909C),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        subcontractorData.email ?? 'N/A',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF455A64),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // GST and Address row
                                Row(
                                  children: [
                                    Icon(
                                      Icons.receipt_long_rounded,
                                      size: 18,
                                      color: Color(0xFF78909C),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        subcontractorData.gst != null && subcontractorData.gst!.isNotEmpty ? subcontractorData.gst! : 'N/A',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF455A64),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 18,
                                      color: Color(0xFF78909C),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        subcontractorData.address != null && subcontractorData.address!.isNotEmpty ? subcontractorData.address! : 'N/A',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF455A64),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

            })
          ],
        ),
        );
      }),
      ),
    );
  }
  textWidget(String title,String value){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.textRegular15,
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyle.textMedium.copyWith(fontSize: 15),
          ),
        ),
      ],
    );
  }
}