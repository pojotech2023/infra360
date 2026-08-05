import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_dashboard/subcontractor_payment_details_controller.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_dashboard/subcontractor_payment_history/add_subcontractor_payment_screen/add_subcontractor_payment_screen.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_dashboard/subcontractor_payment_history/subcontractor_payment_history_screen.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/view/dashboard/dashboard_controller.dart';

class SubcontractorPaymentDetails extends StatefulWidget{
  @override
  State<SubcontractorPaymentDetails> createState() => _SubcontractorPaymentDetailsState();
}

class _SubcontractorPaymentDetailsState extends State<SubcontractorPaymentDetails> {

  SubcontractorPaymentDetailsController controller = Get.put(SubcontractorPaymentDetailsController());
  DashboardController dashboardController = Get.find<DashboardController>();

  bool canAddPayment() {
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.subcontractorManagement?.addPayment == 1;
  }
  
  bool canViewPaymentHistory() {
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.subcontractorManagement?.paymentHistory == 1;
  }


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Subcontractor Payment Details",
          onTap: (){
            Get.back();

          }),
      body: SafeArea(
        child: Obx((){
        return controller.isLoading.value?Center(
          child: CommonLoader(),
        ):SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action Buttons at top
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (canAddPayment())
                    SizedBox(
                      width: 150,
                      child: CommonButton(
                        customColor: AppColor.buttonLightBlue,
                        onTap: () {
                          Get.to(() => AddSubcontractorPaymentScreen(), arguments: controller.subcontractorId.value);
                        },
                        text: 'Add Payment',
                      ),
                    ),
                  if (canViewPaymentHistory()) ...[
                    SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: CommonButton(
                        customColor: AppColor.buttonLightBlue,
                        onTap: () {
                          Get.to(() => SubcontractorPaymentHistoryScreen(), arguments: controller.subcontractorId.value);
                        },
                        text: 'Payment History',
                      ),
                    ),
                  ],
                ],
              ),

              VerticalSpacing.d15px(),
              // Opening Balance field hidden as per requirements
              // Text("Opening Balance",style: AppTextStyle.textFieldHeadingStyle,),
              // VerticalSpacing.d5px(),
              // TextFormField(
              //   controller: controller.openingBalanceController,
              //   keyboardType: TextInputType.number,
              //   autovalidateMode: AutovalidateMode.onUserInteraction,
              //   decoration:textBoxDecoration(hint:"Enter opening balance"),
              //   onChanged: (value){
              //     print("value");
              //   },
              //   validator: (text){
              //     if (text == null || text.isEmpty) {
              //       return 'Required';
              //     }
              //     return null;
              //   },
              // ),
              // VerticalSpacing.d15px(),

              Text("Total Counts",style: AppTextStyle.textFieldHeadingStyle,),
              VerticalSpacing.d5px(),
              TextFormField(
                controller: controller.totalUnitsController,
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                readOnly: true,
                decoration:textBoxDecoration(hint:"Total Counts",
                fillColor: Colors.grey[200]),
              ),

              VerticalSpacing.d15px(),

              Text("Total Amount",style: AppTextStyle.textFieldHeadingStyle,),
              VerticalSpacing.d5px(),
              TextFormField(
                controller: controller.totalAmountController,
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                readOnly: true,
                decoration:textBoxDecoration(hint:"Total Amount",
                    fillColor: Colors.grey[200]),
              ),

              VerticalSpacing.d15px(),

              Text("Paid Amount",style: AppTextStyle.textFieldHeadingStyle,),
              VerticalSpacing.d5px(),
              TextFormField(
                controller: controller.paidAmountController,
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                readOnly: true,
                decoration:textBoxDecoration(hint:"Paid Amount",
                    fillColor: Colors.grey[200]),
              ),

              VerticalSpacing.d15px(),

              Text("Balance Amount",style: AppTextStyle.textFieldHeadingStyle,),
              VerticalSpacing.d5px(),
              TextFormField(
                controller: controller.balanceAmountController,
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                readOnly: true,
                decoration:textBoxDecoration(hint:"Balance Amount",
                    fillColor: Colors.grey[200]),
              ),

              VerticalSpacing.d15px(),


              Obx(() => 

             controller.isButtonLoading.value?Center(child: CommonLoader()): CommonButton(onTap: () {
                controller.paymentUpdate();
              }, text: "Submit"))

            ],
          ),
        );
        }),
      ),
    );
  }
}
