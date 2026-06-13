import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/vendor_management_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/vendor/vendor_management/add_vendor_screen.dart';
import 'package:raptor_pro/view/vendor/vendor_management/vendor_management_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/view/widgets/log_out.dart';
import 'package:raptor_pro/view/dashboard/dashboard_controller.dart';

class VendorManagementScreen extends StatefulWidget{
  @override
  State<VendorManagementScreen> createState() => _VendorManagementScreenState();
}

class _VendorManagementScreenState extends State<VendorManagementScreen> {

  VendorManagementController controller = Get.put(VendorManagementController());
  DashboardController dashboardController = Get.find<DashboardController>();

  bool canAdd() {
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.vendorManagement?.addVendor == 1;
  }
  
  bool canEdit() {
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.vendorManagement?.editVendor == 1;
  }

  bool canDelete() {
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.vendorManagement?.deleteVendor == 1;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: CommonAppBar.appBar(
            title: "Vendor Management",
            onTap: (){
              Get.back();
            }),
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
                    itemCount: controller.vendorManagementData.length,
                    itemBuilder: (BuildContext context,int index){
                      VendorManagementData vendorManagementData=  controller.vendorManagementData[index];
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
                                Expanded(child: textWidget("Name : ",vendorManagementData.name??"")),

                              Row(
                          children:[
                            if (canEdit())
                              InkWell(
                                onTap: (){
                                  Get.to(AddVendorScreen(),arguments: vendorManagementData);

                                },
                                child: Icon(Icons.edit_note,
                                  size: 30,
                                  color: AppColor.buttonLightBlue,),
                              ),
                              if (canEdit() && canDelete()) HorizontalSpacing.d10px(),
                              if (canDelete())
                                InkWell(
                                onTap: (){

                          deleteDialog(context,(){
                            controller.deleteVendor(vendorManagementData.id!);

                          });
                        },
                        child: Align(
                        alignment: Alignment.topRight,
                        child: Icon(Icons.delete,
                        color: Colors.redAccent,),
                        ),
                        ),
                            ]
                        )
                              ],
                            ),


                            VerticalSpacing.d10px(),

                           Wrap(
                             spacing: 16,
                             runSpacing: 8,
                             children: [
                               textWidget("Mobile Number : ", vendorManagementData.mobileNo ?? ""),
                               textWidget("GST: ", vendorManagementData.gst ?? ""),
                             ],
                           ),
                            VerticalSpacing.d10px(),

                            textWidget("Site Utilities : ",vendorManagementData.siteUtilities??""),
                            VerticalSpacing.d10px(),

                            textWidget("Email : ",vendorManagementData.email??""),

                            VerticalSpacing.d10px(),
                            Text(
                              "${vendorManagementData.address}",
                              style: AppTextStyle.textMedium.copyWith(fontSize: 15),

                            ),


                          ],
                        ),
                      );

                    })

              ],
            ),
          );
        })),
        floatingActionButton: Obx(() => canAdd() ? FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.add, color: Colors.white),
            onPressed: (){
              VendorManagementController controller = Get.find<VendorManagementController>();
              controller.clearMethod();

              Get.to(AddVendorScreen(),arguments: null);


            }) : SizedBox.shrink())
    );

  }
  textWidget(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyle.textRegular15.copyWith(color: Colors.grey[600]),
            ),
            Expanded(
              child: Text(
                value,
                style: AppTextStyle.textMedium.copyWith(fontSize: 15),
                softWrap: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}