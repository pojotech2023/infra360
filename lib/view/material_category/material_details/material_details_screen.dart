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
import 'package:raptor_pro/view/widgets/common_app_bar.dart';

import 'package:raptor_pro/view/material_category/bricks_details_screen.dart';

import '../../../model/site_management_model.dart';
import 'material_details_controller.dart';

class MaterialDetailsScreen extends StatefulWidget{
  @override
  State<MaterialDetailsScreen> createState() => _MaterialDetailsScreenState();
}

class _MaterialDetailsScreenState extends State<MaterialDetailsScreen> {
  late final SiteManagementList siteManagementList;
  final controller = Get.put(MaterialDetailsController());
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
          title: "Materials Details",
          onTap: (){
            Get.back();

          }),
  body: SafeArea(
        child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Obx((){
              final materialList = controller.data.entries.toList();
           return  GridView.builder(
              shrinkWrap: true,
              primary: false,
             gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
               maxCrossAxisExtent: 300,
               mainAxisSpacing: 16,
               crossAxisSpacing: 16,
               childAspectRatio: 0.8,
             ),
              itemCount: materialList.length,
              itemBuilder: (context, index) {
                final item = materialList[index];

                return InkWell(
                  onTap: () async {
                    await Get.to(() => BricksDetailsScreen(),
                        arguments: MaterialDetailsArgs(
                            id: siteManagementList.id ?? 0,
                            siteName: siteManagementList.siteName ?? '',
                            siteLocation: siteManagementList.location ?? '',
                            itemKey: item.key,
                            itemData: item.value,
                            supervisorId: siteManagementList.supervisor!.id
                                    .toString() ??
                                '',
                            supervisorName:
                                siteManagementList.supervisor!.name.toString() ??
                                    '',
                            supervisorMob: siteManagementList.supervisor!.mobileNo
                                    .toString() ??
                                ''));
                    controller.init(siteManagementList.id ?? 0);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      border: Border.all(
                          color: AppColor.materialCategoryBorderColor,
                          width: 2
                      ),
                      borderRadius:BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),

                          ),
                          child: Container(
                            margin: EdgeInsets.all(7),
                            color: AppColor.materialCategoryBGColor,
                            child: Image.asset(ConstantData.materialImages[item.key]!,
                                width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height*0.13,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),


                        VerticalSpacing.d10px(),

                        Center(
                          child: Text(capitalize(item.key),
                            textAlign: TextAlign.center,
                            style: AppTextStyle.materialTitleText,),
                        ),
                        Center(
                          child: Text("Qnty - ${item.value.units}",
                              textAlign: TextAlign.center,
                              style: AppTextStyle.textMedium.
                              copyWith(color: Color(0xFF0B9F08),
                                  fontSize: 13)),
                        ),
                        Center(
                          child: Text("Values - ${item.value.values}",
                              textAlign: TextAlign.center,
                              style: AppTextStyle.textMedium.
                              copyWith(color: Color(0xFF0B9F08),
                                  fontSize: 13)),
                        ),




                      ],
                    ),
                  ),
                );
              },
            );}),

            InkWell(
              onTap: (){
                Get.to(OtherMaterialScreen(),arguments:siteManagementList.id);
              },
              child: Container(
                height: 60,
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF084E9F),width: 0.5),
                  borderRadius: BorderRadius.circular(6)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SvgPicture.asset(Images.others),

                    Text("Others",style: AppTextStyle.textMedium
                      .copyWith(fontSize: 20),),
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