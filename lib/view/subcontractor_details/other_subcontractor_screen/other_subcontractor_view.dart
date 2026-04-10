import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/model/other_utilities_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/material_category/other_material/others_material_controller.dart';
import 'package:raptor_pro/view/subcontractor_details/other_subcontractor_screen/others_subcontractor_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';

class OtherSubcontractorView extends StatefulWidget{
  @override
  State<OtherSubcontractorView> createState() => _OtherSubcontractorViewState();
}

class _OtherSubcontractorViewState extends State<OtherSubcontractorView> {
 var controller = Get.find<OthersSubcontractorController>();
 int ?siteId;
  @override
  void initState() {
    // TODO: implement initState
    siteId =Get.arguments;
    controller.otherUtilitiesView(siteId!);
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
                 itemCount: controller.otherUtilitiesData.length,
                 itemBuilder: (BuildContext context,int index){
                  OtherUtilitiesData data= controller.otherUtilitiesData[index];
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
                             Uri.encodeFull( "${imageUrl}/${data.image}"),
                             width: double.infinity,
                             height: 120,
                             fit: BoxFit.fitWidth,
                             errorBuilder: (context, error, stackTrace) {
                               return Container(
                                   width: double.infinity,
                                   height: 120,
                                   alignment: Alignment.center,
                                   color: Colors.grey[300],
                                   child:Text("No Image Preview",
                                     style: AppTextStyle.textRegularSmall,)
                               );
                             },

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