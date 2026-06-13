import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/supervisor_permissions_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/images.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/attendance/attendance_screen.dart';
import 'package:raptor_pro/view/material_category/material_details/material_details_screen.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';

import '../../model/site_management_model.dart';
import '../check_list/check_list_screen.dart';
import '../darwing/drawing_list_screen.dart';
import '../subcontractor_details/subcontractor_sitewise_screen.dart';
import '../tickets/ticket_list_screen.dart';
import '../payment_status/payment_status_screen.dart';
import '../dashboard/dashboard_controller.dart';

class MaterialCategoryScreen extends StatefulWidget {
  @override
  State<MaterialCategoryScreen> createState() => _MaterialCategoryScreenState();
}

class _MaterialCategoryScreenState extends State<MaterialCategoryScreen> {
  late final SiteManagementList siteManagementList;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    siteManagementList = Get.arguments;

    final DashboardController dashboardController = Get.find();
    final bool isSupervisor =
        dashboardController.profileRole.value.toLowerCase() == 'supervisor';
    final PermissionsData? perms = dashboardController.supervisorPermissions.value;

    // Debug: print current permission state
    print("📋 [MATERIAL_CATEGORY] isSupervisor=$isSupervisor");
    if (isSupervisor) {
      if (perms == null) {
        print("⚠️ [MATERIAL_CATEGORY] Permissions not loaded — showing all items by default");
      } else {
        final s = perms.siteManagement;
        print("✅ [MATERIAL_CATEGORY] Permissions loaded:");
        print("   attendance=${ s?.viewTodayAttendance} canAttendance=${ s?.canViewAttendance}");
        print("   material=${ s?.viewMaterials} canMaterial=${ s?.canViewMaterials}");
        print("   sub_contractor=${ s?.viewSubcontractor} canSubContractor=${ s?.canViewSubcontractor}");
        print("   check_list=${ s?.viewChecklist} canCheckList=${ s?.canViewChecklist}");
        print("   tickets=${ s?.viewTickets} canTickets=${ s?.canViewTickets}");
        print("   drawing=${ s?.viewDrawing} canDrawing=${ s?.canViewDrawing}");
        print("   payment_status=${ s?.viewPaymentStatus} canPaymentStatus=${ s?.canViewPaymentStatus}");
      }
    }

    /// Returns true if the item should be shown.
    /// - Admin: always true.
    /// - Supervisor with no perms loaded: default true (show all).
    /// - Supervisor with perms: respect the value (1=show, 0=hide).
    bool canShow(bool Function(PermissionsData p) check) {
      if (!isSupervisor) return true;
      if (perms == null) return true;
      return check(perms);
    }

    items = [
      if (canShow((p) => p.siteManagement?.canViewAttendance ?? false))
        {
          "title": "Today Attendance",
          "image": Images.calendar,
          "onTap": () =>
              Get.to(() => AttendanceScreen(), arguments: siteManagementList.id),
        },
      if (canShow((p) => p.siteManagement?.canViewMaterials ?? false))
        {
          "title": "Materials",
          "image": Images.material,
          "onTap": () =>
              Get.to(() => MaterialDetailsScreen(), arguments: siteManagementList),
        },
      if (canShow((p) => p.siteManagement?.canViewSubcontractor ?? false))
        {
          "title": "Sub Contractor",
          "image": Images.subcontractors,
          "onTap": () =>
              Get.to(() => SubcontractorScreen(), arguments: siteManagementList),
        },
      if (canShow((p) => p.siteManagement?.canViewChecklist ?? false))
        {
          "title": "Check List",
          "image": Images.checklist,
          "onTap": () =>
              Get.to(() => CheckListScreen(), arguments: siteManagementList.id),
        },
      if (canShow((p) => p.siteManagement?.canViewTickets ?? false))
        {
          "title": "Tickets",
          "image": Images.tickets,
          "onTap": () =>
              Get.to(() => TicketListScreen(), arguments: siteManagementList.id),
        },
      if (canShow((p) => p.siteManagement?.canViewDrawing ?? false))
        {
          "title": "Drawing",
          "image": Images.drawing,
          "onTap": () =>
              Get.to(() => DrawingListScreen(), arguments: siteManagementList.id),
        },
      // Payment Status: admin always sees it; supervisor only if permitted
      if (canShow((p) => p.siteManagement?.canViewPaymentStatus ?? false))
        {
          "title": "Payment Status",
          "image": Images.paymentStatus,
          "onTap": () => Get.to(() => const PaymentStatusScreen(),
              arguments: siteManagementList.id),
        },
    ];

    print("📋 [MATERIAL_CATEGORY] Showing ${items.length} item(s): ${items.map((e) => e['title']).toList()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: "Materials Category",
        onTap: () => Get.back(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildGridItem(
              context,
              title: items[index]["title"],
              image: items[index]["image"],
              onTap: items[index]["onTap"],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required String image,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(
            color: AppColor.materialCategoryBorderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Container(
                color: AppColor.materialCategoryBGColor,
                child: Image.asset(
                  image,
                  height: MediaQuery.of(context).size.height * 0.12,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            VerticalSpacing.d10px(),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyle.materialTitleText,
              ),
            ),
            VerticalSpacing.d10px(),
          ],
        ),
      ),
    );
  }
}
