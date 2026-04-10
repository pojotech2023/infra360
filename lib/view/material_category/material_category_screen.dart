import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

class MaterialCategoryScreen extends StatefulWidget{
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

    items = [
      {
        "title": "Today Attendance",
        "image": Images.calendar,
        "onTap": () => Get.to(() => AttendanceScreen(),
            arguments: siteManagementList.id),
      },
      {
        "title": "Materials",
        "image": Images.material,
        "onTap": () => Get.to(() => MaterialDetailsScreen(),
            arguments: siteManagementList),
      },
      {
        "title": "Sub Contractor",
        "image": Images.subcontractors,
        "onTap": () => Get.to(() => SubcontractorScreen(),
            arguments: siteManagementList),
      },
      {
        "title": "Check List",
        "image": Images.checklist,
        "onTap": () => Get.to(() => CheckListScreen(),
            arguments: siteManagementList.id),
      },
      {
        "title": "Tickets",
        "image": Images.tickets,
        "onTap": () => Get.to(() => TicketListScreen(),
            arguments: siteManagementList.id),
      },
      {
        "title": "Drawing",
        "image": Images.drawing,
        "onTap": () => Get.to(() => DrawingListScreen(),
            arguments: siteManagementList.id),
      },
    ];
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
