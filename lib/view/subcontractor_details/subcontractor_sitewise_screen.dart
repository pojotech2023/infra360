import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/images.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/material_category/other_material/others_material.dart';
import 'package:raptor_pro/view/subcontractor_details/subcontractor_services_request/request_details_controller.dart';
import 'package:raptor_pro/view/subcontractor_details/subcontractor_services_request/request_details_screen.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';

import 'package:raptor_pro/view/material_category/bricks_details_screen.dart';

import '../../../model/site_management_model.dart';
import 'other_subcontractor_screen/other_subcontractor.dart';
import 'subcontractor_sitewise_controller.dart';

class SubcontractorScreen extends StatefulWidget {
  @override
  State<SubcontractorScreen> createState() =>
      _SubcontractorScreenState();
}

class _SubcontractorScreenState
    extends State<SubcontractorScreen> {
  late final SiteManagementList siteManagementList;
  final controller = Get.put(SubcontractorController());

  @override
  void initState() {
    super.initState();
    siteManagementList = Get.arguments ?? 0;
    controller.init(siteManagementList.id ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Subcontractor Details",
          onTap: () {
            Get.back();
          }),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.subcontractors.isEmpty) {
                return const Center(child: Text("No data available"));
              }

              return GridView.builder(

                shrinkWrap: true,
                // ✅ important
                physics: const NeverScrollableScrollPhysics(),
                // ✅ disable GridView scrolling
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.68, // Reduced for more vertical space
                ),
                itemCount: controller.subcontractors.length,
                itemBuilder: (context, index) {
                  final item = controller.subcontractors[index];
                  return InkWell(
                    onTap:(){
                      Get.to(() => RequestDetailsScreen(), arguments: SubcontracorDetailsArgs(
                        id: siteManagementList.id ?? 0,
                        siteName: siteManagementList.siteName ??'',
                        itemKey: item.title,
                      ));
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [


                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),

                              ),
                              child: Container(
                                margin: EdgeInsets.all(4),
                                color: AppColor.materialCategoryBGColor,
                                child: Image.asset(item.image,
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height*0.12,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),


                            VerticalSpacing.custom(value: 8),

                            SizedBox(
                              height: 44,
                              child: Text(
                                item.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₹${item.totalAmount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            InkWell(
              onTap: () {
                Get.to(OtherSubcontractorScreen(), arguments: siteManagementList.id);
              },
              child: Container(
                height: 60,
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color(0xFF084E9F), width: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SvgPicture.asset(Images.others),
                    Text(
                      "Others",
                      style: AppTextStyle.textMedium.copyWith(fontSize: 20),
                    ),
                    Container(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
