import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
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
                                      (vendorManagementData.name?.substring(0, 1).toUpperCase() ?? 'V'),
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
                                        vendorManagementData.name ?? '',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF102844),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 6),
                                      if (vendorManagementData.siteUtilities != null && vendorManagementData.siteUtilities!.isNotEmpty)
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFE5F3FE),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Color(0xFFBBE0FD)),
                                          ),
                                          child: Text(
                                            vendorManagementData.siteUtilities ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0089E8),
                                            ),
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
                                        onTap: (){ Get.to(AddVendorScreen(),arguments: vendorManagementData); },
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
                                          deleteDialog(context,(){ controller.deleteVendor(vendorManagementData.id!); });
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
                                    final phone = vendorManagementData.mobileNo;
                                    if (phone != null && phone.isNotEmpty) {
                                      final Uri url = Uri.parse('tel:$phone');
                                      if (await canLaunchUrl(url)) await launchUrl(url);
                                    }
                                  },
                                  child: Text(
                                    vendorManagementData.mobileNo ?? 'N/A',
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
                                    vendorManagementData.email ?? 'N/A',
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
                                    vendorManagementData.gst != null && vendorManagementData.gst!.isNotEmpty ? vendorManagementData.gst! : 'N/A',
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
                                    vendorManagementData.address != null && vendorManagementData.address!.isNotEmpty ? vendorManagementData.address! : 'N/A',
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