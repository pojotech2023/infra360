import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/subcontractor_dashboard_model.dart';
import 'package:raptor_pro/model/subcontractor_payment_history_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_dashboard/subcontractor_dashboard_controller.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_dashboard/subcontractor_material_orders_screen.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/view/dashboard/dashboard_controller.dart';

class SubContractorDashboardScreen extends StatefulWidget{
  @override
  State<SubContractorDashboardScreen> createState() => _SubContractorDashboardScreenState();
}

class _SubContractorDashboardScreenState extends State<SubContractorDashboardScreen> {

  SubContractorDashboardController controller = Get.put(SubContractorDashboardController());
  DashboardController dashboardController = Get.find<DashboardController>();

  bool canViewAmount() {
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.subcontractorManagement?.viewAmount == 1;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
       appBar: CommonAppBar.appBar(
           title: "SubContractor Dashboard",
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
                   itemCount: controller.subContractorData.length,
                   itemBuilder: (BuildContext context,int index){
                     SubContractorData data=  controller.subContractorData[index];
                     return InkWell(
                       onTap: (){
                         Get.to(SubcontractorMaterialOrdersScreen(), arguments: data.subcontractorId);
                       },
                       child: Container(
                         padding: EdgeInsets.all(20),
                         margin: EdgeInsets.only(bottom: 16),
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(20),
                           gradient: LinearGradient(
                             colors: [
                               Colors.purple.shade50,
                               Colors.pink.shade50,
                             ],
                             begin: Alignment.topLeft,
                             end: Alignment.bottomRight,
                           ),
                           border: Border.all(color: Colors.purple.shade200, width: 1.5),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.purple.shade100.withOpacity(0.3),
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
                                     color: Colors.purple.shade100,
                                     borderRadius: BorderRadius.circular(12),
                                   ),
                                   child: Icon(Icons.engineering, color: Colors.purple.shade700, size: 24),
                                 ),
                                 SizedBox(width: 16),
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(
                                         "Subcontractor",
                                         style: TextStyle(
                                           fontSize: 12,
                                           fontWeight: FontWeight.w500,
                                           color: Colors.purple.shade600,
                                         ),
                                       ),
                                       SizedBox(height: 4),
                                       Text(
                                         data.subcontractorName ?? "N/A",
                                         style: TextStyle(
                                           fontSize: 18,
                                           fontWeight: FontWeight.w700,
                                           color: Colors.purple.shade900,
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
                                   border: Border.all(color: Colors.purple.shade100, width: 1),
                                 ),
                                 child: Column(
                                   children: [
                                     _financialRow("Total Amount", data.totalAmount.toString(), Colors.green),
                                     SizedBox(height: 12),
                                     _financialRow("Paid Amount", data.paidAmount.toString(), Colors.purple),
                                     SizedBox(height: 12),
                                     _financialRow("Pending Amount", data.pendingAmount.toString(), Colors.orange),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.textRegular15,
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyle.textMedium.copyWith(fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _financialRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

}