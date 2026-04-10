import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/images.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/customer/customer_list_screen.dart';
import 'package:raptor_pro/view/dashboard/dashboard_controller.dart';
import 'package:raptor_pro/view/profile/profile_screen.dart';
import 'package:raptor_pro/view/supervisor_management/supervisor_management_screen.dart';
import 'package:raptor_pro/view/vendor/vendor_main_screen.dart';
import 'package:raptor_pro/view/widgets/log_out.dart';

import '../quotation/generate_quotation_controller.dart';
import '../quotation/generate_quotation_screen.dart';
import '../subcontractor/subcontractor_main_screen.dart';


class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return   Drawer(
        shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        ),
        child: GetBuilder<DashboardController>(
          init: DashboardController(),
          builder: (controller) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Profile Header
              VerticalSpacing.d10px(),
              Container(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: Column(
                  children: [
                    controller.profileImage.value != null ||
                        controller.profileImage.value != ''
                        ? Image.network(
                      width: 48,
                      height: 48,
                      '$imageUrl/${controller.profileImage}',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                            child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.add_a_photo,
                          size: 30, color: Colors.grey),
                    )
                        : Image.asset(
                      width: 48,
                      height: 48,
                      Images.profile, // your profile image
                    ),
                    SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.profileName.value ?? '',
                            style: AppTextStyle.textMedium),
                        Text(controller.profileRole.value ?? '',
                            style: AppTextStyle.textMedium
                                .copyWith(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),

              Divider(
                color: Color(0xFFE2E4E5),
              ),

              Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        drawerItem(Images.user, 'Profile', onTap: () {
                          Get.to(() => ProfileScreen());
                        }),
                        // drawerItem(Images.properties, 'Sites Details',
                        //     isActive: true),

                        controller.userDetails.data!.role!.toLowerCase() == 'admin'
                            ? drawerItem(Images.supervisor, 'Supervisor Creation',
                            onTap: () {
                              Get.to(SuperVisorManagementScreen());
                            })
                            : SizedBox(),
                        drawerItem(Images.customer, 'Customer List', onTap: () {
                          Get.to(CustomerListScreen());
                        }),
                        drawerItem(Images.quotation, 'Generate Quotation',
                            onTap: () {
                              if (Get.isRegistered<GenerateQuotationController>()) {
                                Get.delete<GenerateQuotationController>(force: true);
                              }
                              Get.to(() => GenerateQuotationScreen());
                            }),
                        drawerItem(Images.vendor, 'Vendor Creation', onTap: () {
                          Get.to(VendorMainScreen());
                        }),

                        drawerItem(Images.subcontractor, 'SubContractor Creation',
                            onTap: () {
                              Get.to(SubContractorMainScreen());
                            }),

                        /* drawerItem(Images.properties, 'Property List',
                 onTap: (){
                   Get.toNamed('/properties');
                 }),

             drawerItem(Images.supervisor, 'View Agents',
                 onTap: (){
                   Get.to(AgentManagementScreen());
                 }),*/
                        drawerItem(Images.signOut, 'Signout', onTap: () {
                          showLogoutDialog(context);
                        }),
                      ],
                    ),
                  ))
              // Menu Items
            ],
          ),
        ));
  }
}



Widget drawerItem(String icon, String title,
    {bool isActive = false, int badgeCount = 0, Function? onTap}) {
  return InkWell(
    onTap: () {
      if (onTap != null) {
        onTap();
      }
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ListTile(
        minTileHeight: 20,
        leading: SvgPicture.asset(icon),
        title: Text(title,
            style: AppTextStyle.textMedium.copyWith(color: AppColor.black)),
        trailing: badgeCount > 0
            ? Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$badgeCount',
            style:
            TextStyle(color: Colors.deepPurpleAccent, fontSize: 12),
          ),
        )
            : null,
      ),
    ),
  );
}


