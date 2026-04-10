import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/vendor_dashboard_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/vendor/vendor_dashboard/vendor_dashboard_controller.dart';
import 'package:raptor_pro/view/vendor/vendor_dashboard/vendor_payment_details.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

class VendorDashboardScreen extends StatefulWidget{
  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {

  VendorDashboardController controller = Get.put(VendorDashboardController());

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
       appBar: CommonAppBar.appBar(
           title: "Vendor Dashboard",
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
                   itemCount: controller.vendorDataList.length,
                   itemBuilder: (BuildContext context,int index){
                     VendorData vendorData=  controller.vendorDataList[index];
                     return InkWell(
                       onTap: (){
                         Get.to(VendorPaymentDetails(),arguments:vendorData.vendorId );


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
                                 textWidget("Vendor Name : ",vendorData.vendorName??""),
                               ],
                             ),


                             VerticalSpacing.d5px(),

                             textWidget("Total Amount : ",vendorData.totalAmount.toString()??""),
                             VerticalSpacing.d5px(),
                             textWidget("Paid Amount : ",vendorData.paidAmount??""),

                             VerticalSpacing.d5px(),
                             textWidget("Pending Amount : ",vendorData.pendingAmount??""),


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