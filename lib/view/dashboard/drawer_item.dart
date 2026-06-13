import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/model/supervisor_permissions_model.dart';
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
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: GetBuilder<DashboardController>(
        init: DashboardController(),
        builder: (controller) {
          final bool isSupervisor =
              controller.profileRole.value.toLowerCase() == 'supervisor';
          final PermissionsData? perms = controller.supervisorPermissions.value;

          /// Returns true if the drawer item should be shown.
          /// - Admin: always true.
          /// - Supervisor with no perms: default true (show all).
          /// - Supervisor with perms: respect the value.
          bool canShow(bool Function(PermissionsData p) check) {
            if (!isSupervisor) return true;
            if (perms == null) return true;
            return check(perms);
          }

          // Debug print each time the drawer builds
          if (isSupervisor) {
            print("🗂️ [DRAWER] Supervisor permissions:");
            print("   customer =${perms?.customerManagement?.addCustomer}  canCustomer=${ perms?.customerManagement?.canAccessCustomer}");
            print("   quotation=${perms?.quotation?.addQuotation} canQuotation=${perms?.quotation?.canAccessQuotation}");
            print("   vendor   =${perms?.vendorManagement?.addVendor}    canVendor=${perms?.vendorManagement?.canAccessVendor}");
            print("   sub_contractor=${perms?.subcontractorManagement?.addSubcontractor} canSubContractor=${perms?.subcontractorManagement?.canAccessSubcontractor}");
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // ── Close button ────────────────────────────────────────────────
              VerticalSpacing.d10px(),
              Container(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ),

              // ── Profile header ──────────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: Column(
                  children: [
                    controller.profileImage.value.isNotEmpty
                        ? Image.network(
                            '$imageUrl/${controller.profileImage}',
                            width: 48,
                            height: 48,
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
                        : Image.asset(Images.profile, width: 48, height: 48),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.profileName.value,
                            style: AppTextStyle.textMedium),
                        Text(controller.profileRole.value,
                            style: AppTextStyle.textMedium
                                .copyWith(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0xFFE2E4E5)),

              // ── Menu items ──────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile — always visible
                      drawerItem(Images.user, 'Profile', onTap: () {
                        Get.to(() => ProfileScreen());
                      }),

                      // Supervisor Creation — admin only
                      if (controller.userDetails.data!.role!.toLowerCase() ==
                          'admin')
                        drawerItem(Images.supervisor, 'Supervisor Creation',
                            onTap: () {
                          Get.to(SuperVisorManagementScreen());
                        }),

                      // Customer List — permission controlled for supervisor
                      if (canShow((p) => p.customerManagement?.canAccessCustomer ?? false))
                        drawerItem(Images.customer, 'Customer List', onTap: () {
                          Get.to(CustomerListScreen());
                        }),

                      // Generate Quotation — permission controlled for supervisor
                      if (canShow((p) => p.quotation?.canAccessQuotation ?? false))
                        drawerItem(Images.quotation, 'Generate Quotation',
                            onTap: () {
                          if (Get.isRegistered<GenerateQuotationController>()) {
                            Get.delete<GenerateQuotationController>(
                                force: true);
                          }
                          Get.to(() => GenerateQuotationScreen());
                        }),

                      // Vendor Creation — permission controlled for supervisor
                      if (canShow((p) => p.vendorManagement?.canAccessVendor ?? false))
                        drawerItem(Images.vendor, 'Vendor Creation', onTap: () {
                          Get.to(VendorMainScreen());
                        }),

                      // SubContractor Creation — permission controlled for supervisor
                      if (canShow((p) => p.subcontractorManagement?.canAccessSubcontractor ?? false))
                        drawerItem(Images.subcontractor,
                            'SubContractor Creation', onTap: () {
                          Get.to(SubContractorMainScreen());
                        }),

                      // Sign out — always visible
                      drawerItem(Images.signOut, 'Signout', onTap: () {
                        showLogoutDialog(context);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget drawerItem(String icon, String title,
    {bool isActive = false, int badgeCount = 0, Function? onTap}) {
  return InkWell(
    onTap: () {
      if (onTap != null) onTap();
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                      color: Colors.deepPurpleAccent, fontSize: 12),
                ),
              )
            : null,
      ),
    ),
  );
}
