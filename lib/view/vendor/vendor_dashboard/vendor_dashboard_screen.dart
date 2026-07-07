import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/vendor_dashboard_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/vendor/vendor_dashboard/vendor_dashboard_controller.dart';
import 'package:raptor_pro/view/vendor/vendor_dashboard/vendor_material_orders_screen.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/view/dashboard/dashboard_controller.dart';

class VendorDashboardScreen extends StatefulWidget{
  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {

  VendorDashboardController controller = Get.put(VendorDashboardController());
  DashboardController dashboardController = Get.find<DashboardController>();

  bool canViewAmount() {
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.vendorManagement?.viewAmount == 1;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
       appBar: CommonAppBar.appBar(
           title: "Vendor Dashboard",
           onTap: (){
             Get.back();

           }),
       body: SafeArea(
         child: Obx((){
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
                         Get.to(() => const VendorMaterialOrdersScreen(), arguments: vendorData.vendorId);
                       },
                       child: Container(
                         padding: EdgeInsets.all(20),
                         margin: EdgeInsets.only(bottom: 16),
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(20),
                           gradient: LinearGradient(
                             colors: [
                               Colors.blue.shade50,
                               Colors.indigo.shade50,
                             ],
                             begin: Alignment.topLeft,
                             end: Alignment.bottomRight,
                           ),
                           border: Border.all(color: Colors.blue.shade200, width: 1.5),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.blue.shade100.withOpacity(0.3),
                               blurRadius: 15,
                               offset: Offset(0, 5),
                             ),
                           ],
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               children: [
                                 Container(
                                   padding: EdgeInsets.all(12),
                                   decoration: BoxDecoration(
                                     color: Colors.blue.shade100,
                                     borderRadius: BorderRadius.circular(12),
                                   ),
                                   child: Icon(Icons.business, color: Colors.blue.shade700, size: 24),
                                 ),
                                 SizedBox(width: 16),
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(
                                         "Vendor",
                                         style: TextStyle(
                                           fontSize: 12,
                                           fontWeight: FontWeight.w500,
                                           color: Colors.blue.shade600,
                                         ),
                                       ),
                                       SizedBox(height: 4),
                                       Text(
                                         vendorData.vendorName ?? "N/A",
                                         style: TextStyle(
                                           fontSize: 18,
                                           fontWeight: FontWeight.w700,
                                           color: Colors.blue.shade900,
                                         ),
                                         maxLines: 2,
                                         overflow: TextOverflow.ellipsis,
                                       ),
                                     ],
                                   ),
                                 ),
                               ],
                             ),
                             SizedBox(height: 16),
                             if (canViewAmount()) ...[
                               Container(
                                 padding: EdgeInsets.all(16),
                                 decoration: BoxDecoration(
                                   color: Colors.white.withOpacity(0.7),
                                   borderRadius: BorderRadius.circular(16),
                                   border: Border.all(color: Colors.blue.shade100, width: 1),
                                 ),
                                 child: Column(
                                   children: [
                                     _financialRow("Total Amount", vendorData.totalAmount.toString(), Colors.green),
                                     SizedBox(height: 12),
                                     _financialRow("Paid Amount", vendorData.paidAmount ?? "0", Colors.blue),
                                     SizedBox(height: 12),
                                     _financialRow("Pending Amount", vendorData.pendingAmount ?? "0", Colors.orange),
                                   ],
                                 ),
                               ),
                             ]
                           ],
                         ),
                       ),
                     );
                   })

             ],
           ),
         );
       }),
      ),
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

  Widget _financialRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

}