import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
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
          title: "Subcontractor",
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
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFF0089E8),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (subcontractorData.name?.substring(0, 1).toUpperCase() ?? 'S'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Name and Badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subcontractorData.name ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF102844),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6),
                                if (subcontractorData.subcontractors != null && subcontractorData.subcontractors!.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE5F3FE),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Color(0xFFBBE0FD)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.business_center, size: 12, color: Color(0xFF0089E8)),
                                        SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            subcontractorData.subcontractors ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0089E8),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Actions
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (canEdit())
                                InkWell(
                                  onTap: (){ Get.to(AddSubcontractorManagementScreen(), arguments: subcontractorData); },
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE5F3FE),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.edit, size: 18, color: Color(0xFF0089E8)),
                                  ),
                                ),
                              if (canEdit() && canDelete()) SizedBox(width: 8),
                              if (canDelete())
                                InkWell(
                                  onTap: (){
                                    deleteDialog(context,(){ controller.deleteSupervisor(subcontractorData.id!); });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.delete, size: 18, color: Color(0xFFE53935)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Contact details
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              final phone = subcontractorData.mobileNo;
                              if (phone != null && phone.isNotEmpty) {
                                final Uri url = Uri.parse('tel:$phone');
                                if (await canLaunchUrl(url)) await launchUrl(url);
                              }
                            },
                            child: Text(
                              subcontractorData.mobileNo ?? 'N/A',
                              style: TextStyle(fontSize: 13, color: Color(0xFF0089E8), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              subcontractorData.email ?? 'N/A',
                              style: TextStyle(fontSize: 13, color: Color(0xFF5A6676)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.receipt_long, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Text(
                              subcontractorData.gst != null && subcontractorData.gst!.isNotEmpty ? subcontractorData.gst! : 'N/A',
                              style: TextStyle(fontSize: 13, color: Color(0xFF5A6676)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Text(
                              subcontractorData.address != null && subcontractorData.address!.isNotEmpty ? subcontractorData.address! : 'N/A',
                              style: TextStyle(fontSize: 13, color: Color(0xFF5A6676)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
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
