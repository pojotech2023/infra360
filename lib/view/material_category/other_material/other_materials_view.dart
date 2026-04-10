import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/utils/url_helper.dart';
import 'package:raptor_pro/model/other_utilities_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/material_category/other_material/others_material_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';

class OtherMaterialView extends StatefulWidget{
  @override
  State<OtherMaterialView> createState() => _OtherMaterialViewState();
}

class _OtherMaterialViewState extends State<OtherMaterialView> {
 var othersMaterialController = Get.find<OthersMaterialController>();
 int ?siteId;
  @override
  void initState() {
    // TODO: implement initState
    siteId =Get.arguments;
    othersMaterialController.otherUtilitiesView(siteId!);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Others",
          onTap: () {
            Get.back();
          }),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(()
            {return
             ListView.builder(
               shrinkWrap: true,
                 primary: false,
                 itemCount: othersMaterialController.otherUtilitiesData.length,
                 itemBuilder: (BuildContext context,int index){
                  OtherUtilitiesData data= othersMaterialController.otherUtilitiesData[index];
                 return Container(
                   margin: EdgeInsets.only(bottom: 16),
                   padding: EdgeInsets.all(10),
                   decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
                       border:
                       Border.all(color: Color(0xFFDCE1EF), width: 1)),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       if(data.image!=null)
                       ClipRRect(
                         borderRadius: BorderRadius.only(
                           topLeft: Radius.circular(14),
                           topRight: Radius.circular(14),
                         ),
                         child: Image.network(
                           UrlHelper.getFullImageUrl(data.image),
                           width: double.infinity,
                           height: 120,
                           fit: BoxFit.fitWidth,
                         ),
                       ),
                       VerticalSpacing.d5px(),
                       Text(
                         "Amount : ${data.amount}",
                         style: AppTextStyle.textMedium,
                       ),
                       VerticalSpacing.d10px(),
                       Text(
                         "Remarks",
                         style: AppTextStyle.textMedium.
                         copyWith(color: AppColor.buttonBlue),
                       ),
                       VerticalSpacing.d5px(),
                       Text(
                         "${data.remarks}",
                         style: AppTextStyle.textMedium,
                       ),
                     ],
                   ),
                 );

             });
            }),

          ],
        ),
      ),
    );
  }
}