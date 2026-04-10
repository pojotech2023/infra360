import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/subcontractor_dashboard_model.dart';
import 'package:raptor_pro/model/subcontractor_payment_history_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_dashboard/subcontractor_dashboard_controller.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_dashboard/subcontractor_payment_history_screen.dart';import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

class SubContractorDashboardScreen extends StatefulWidget{
  @override
  State<SubContractorDashboardScreen> createState() => _SubContractorDashboardScreenState();
}

class _SubContractorDashboardScreenState extends State<SubContractorDashboardScreen> {

  SubContractorDashboardController controller = Get.put(SubContractorDashboardController());

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
       appBar: CommonAppBar.appBar(
           title: "SubContractor Dashboard",
           onTap: (){
             Get.back();

           }),
       body: Obx((){
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
                   itemCount: controller.subContractorData.length,
                   itemBuilder: (BuildContext context,int index){
                     SubContractorData data=  controller.subContractorData[index];
                     return InkWell(
                       onTap: (){
                         Get.to(SubContractorPaymentHistoryScreen(),arguments:data);
                       },
                       child: Container(
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
                                 textWidget("Name : ",data.subcontractorName??""),
                               ],
                             ),


                             VerticalSpacing.d5px(),

                             textWidget("Total Amount : ",data.totalAmount.toString()??""),
                             VerticalSpacing.d5px(),
                             textWidget("Paid Amount : ",data.paidAmount.toString()??""),

                             VerticalSpacing.d5px(),
                             textWidget("Pending Amount : ",data.pendingAmount.toString()??""),


                           ],
                         ),
                       ),
                     );

                   })

             ],
           ),
         );
       })
   );
  }
  textWidget(String title,String value){
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyle.textRegular15,
        ),
        Text(
          value,
          style: AppTextStyle.textMedium.copyWith(fontSize: 15),

        ),
      ],
    );
  }

}