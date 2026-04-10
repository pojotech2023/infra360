import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/vendor/vendor_dashboard/vendor_payment_details_controller.dart';
import 'package:raptor_pro/view/vendor/vendor_dashboard/vendor_payment_history/add_vendor_payment_screen/add_vendor_payment_screen.dart';
import 'package:raptor_pro/view/vendor/vendor_dashboard/vendor_payment_history/vendor_payment_history_screen.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

class VendorPaymentDetails extends StatefulWidget{
  @override
  State<VendorPaymentDetails> createState() => _VendorPaymentDetailsState();
}

class _VendorPaymentDetailsState extends State<VendorPaymentDetails> {

  VendorPaymentDetailsController controller = Get.put(VendorPaymentDetailsController());





  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Vendor Payment Details",
          onTap: (){
            Get.back();

          }),
      body: Obx((){
      return controller.isLoading.value?Center(
        child: CommonLoader(),
      ):SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: 150,

                  child: CommonButton(customColor: AppColor.buttonLightBlue, onTap: () {
                    Get.to(AddVendorPaymentScreen(),arguments: controller.vendorDataList.value.vendor?.id);
                  },
                    text: 'Add Payment',),),
                HorizontalSpacing.d5px(),


                SizedBox(width: 150,
                child: CommonButton(customColor: AppColor.buttonGreen, onTap: () {
                  Get.to(VendorPaymentHistoryScreen(),arguments: controller.vendorDataList.value.vendor?.id);
                },
                  text: 'Payment History',),)
              ],
            ),

            VerticalSpacing.d15px(),
            Text("Opening Balance",style: AppTextStyle.textFieldHeadingStyle,),
            VerticalSpacing.d5px(),
            TextFormField(
              controller: controller.openingBalanceController,
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,

              decoration:textBoxDecoration(hint:"Enter opening balance"),
              onChanged: (value){
                print("value");
              },
              validator: (text){
                if (text == null || text.isEmpty) {
                  return 'Required';
                }

                return null;
              },



            ),


            VerticalSpacing.d15px(),

            Text("Total Units",style: AppTextStyle.textFieldHeadingStyle,),
            VerticalSpacing.d5px(),
            TextFormField(
              initialValue:controller.vendorDataList.value.payDetail?.totalUnits ,
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              readOnly: true,
              decoration:textBoxDecoration(hint:"Total Units",
              fillColor: Colors.grey[200]),
            ),


            VerticalSpacing.d15px(),

            VerticalSpacing.d15px(),

            Text("Total Unit Price",style: AppTextStyle.textFieldHeadingStyle,),
            VerticalSpacing.d5px(),
            TextFormField(
              initialValue:controller.vendorDataList.value.payDetail?.totalUnitPrice ,
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              readOnly: true,
              decoration:textBoxDecoration(hint:"Total Unit Price",
                  fillColor: Colors.grey[200]),
            ),


            VerticalSpacing.d15px(),


            Text("Balance Amount",style: AppTextStyle.textFieldHeadingStyle,),
            VerticalSpacing.d5px(),
            TextFormField(
              initialValue:controller.vendorDataList.value.payDetail?.balanceAmount ,
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              readOnly: true,
              decoration:textBoxDecoration(hint:"Balance Amount",
                  fillColor: Colors.grey[200]),
            ),


            VerticalSpacing.d15px(),

            Text("Paid Amount",style: AppTextStyle.textFieldHeadingStyle,),
            VerticalSpacing.d5px(),
            TextFormField(
              initialValue:controller.vendorDataList.value.payDetail?.paidAmount ,
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              readOnly: true,
              decoration:textBoxDecoration(hint:"Paid Amount",
                  fillColor: Colors.grey[200]),
            ),


            VerticalSpacing.d15px(),


            Obx(() => 

           controller.isButtonLoading.value?Center(child: CommonLoader()): CommonButton(onTap: () {
              controller.paymentUpdate();
            }, text: "Submit"))

          ],
        ),
      );}));



      }
}