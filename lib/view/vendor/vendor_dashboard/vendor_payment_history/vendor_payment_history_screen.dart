import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/view/vendor/vendor_dashboard/vendor_payment_history/vendor_payment_history_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:get/get.dart';

class VendorPaymentHistoryScreen extends StatefulWidget{
  @override
  State<VendorPaymentHistoryScreen> createState() => _VendorPaymentHistoryScreenState();
}

class _VendorPaymentHistoryScreenState extends State<VendorPaymentHistoryScreen> {

VendorPaymentHistoryController controller =Get.put(VendorPaymentHistoryController());
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Payment History",
          onTap: (){
            Get.back();

          }),
      body:  SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTableHeader(),
            Obx(() => controller.isLoading.value?Center(child: CommonLoader(),):Column(
              children: controller.paymentHistoryData.value.paymentHistoryList!
                  .map((item) => _buildTableRow({
                'id': item.id.toString(),
                'name': item.vendor?.name ?? '',
                'date': item.date ?? '',
                'payment': item.payment ?? '',
                'mode': item.paymentMode??"" ,
              }))
                  .toList(),
            )),
            Obx(()=>Container(
              height: 50,
              margin: EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: AppColor.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 8), // vertical offset for soft shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Total Amount: ",style: AppTextStyle.textMedium.copyWith(color: AppColor.buttonLightBlue),),
                  Text("${controller.paymentHistoryData.value.totalPaidAmount??"N/A"}",style: AppTextStyle.textBold.
                    copyWith(color: AppColor.buttonLightBlue),),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
Widget _buildTableHeader() {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
    decoration: BoxDecoration(
        color: AppColor.tableBGColor,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        )),
    child: Row(
      children: [
       // _buildCell('S.No', bold: true),
        _buildCell('Name',  bold: true,),
        _buildCell('Date', bold: true,),
        _buildCell('Payment', bold: true),
        _buildCell('Mode', bold: true),
      ],
    ),
  );
}
Widget _buildTableRow(Map<String, String> item) {
  return Container(
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      color: AppColor.tableBGColor,
      // borderRadius: BorderRadius.only(
      //   bottomLeft: Radius.circular(10),
      //   bottomRight: Radius.circular(10),
      // )
    ),
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
    child: Row(
      children: [
        //_buildCell(item['id']!,),
        _buildCell(item['name']!,),
        _buildCell(item['date']!,),
        _buildCell(item['payment']!,),
        _buildCell(item['mode']!,),
      ],
    ),
  );
}
Widget _buildCell(String text, {int flex = 1, bool bold = false}) {
  return Expanded(
    flex: flex,
    child: Padding(
      padding: const EdgeInsets.only(left: 1),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w400,
            color: AppColor.black,
            fontSize: 13),
      ),
    ),
  );
}


}