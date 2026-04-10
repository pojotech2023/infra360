import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/customer_model.dart';
import 'package:raptor_pro/model/supervisor_list_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/customer/customer_list_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/view/widgets/log_out.dart';

import 'customer_mangement_screen.dart';

class CustomerListScreen extends StatefulWidget{
  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {

  CustomerListController controller = Get.put(CustomerListController());


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: CommonAppBar.appBar(
            title: "Customer List",
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
                    itemCount: controller.customerData.length,
                    itemBuilder: (BuildContext context,int index){
                      Customers customerData=  controller.customerData[index];
                      return Container(
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
                               textWidget("Name : ",customerData.name??""),

                             Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [

                                 InkWell(
                                   onTap: (){
                                     Get.to(() => CustomerMangementScreen(), arguments: customerData);

                                   },
                                   child: Align(
                                     alignment: Alignment.topRight,
                                     child: Icon(Icons.edit,
                                       color: Colors.blueAccent,),
                                   ),
                                 ),
                                 SizedBox(width: 16,),
                                 InkWell(
                                   onTap: (){
                                     deleteDialog(context,(){
                                       controller.deleteCustomer(customerData.id!);

                                     });
                                   },
                                   child: Align(
                                     alignment: Alignment.topRight,
                                     child: Icon(Icons.delete,
                                       color: Colors.redAccent,),
                                   ),
                                 ),
                               ],
                             )

                             ],
                           ),
                            VerticalSpacing.d10px(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            textWidget("Mobile : ",customerData.mobileNo??""),
                            textWidget("DOB : ",customerData.dob??""),
                          ],
                        ),
                            VerticalSpacing.d10px(),

                            textWidget("Email : ",customerData.email??""),
                            // VerticalSpacing.d10px(),
                            //
                            // textWidget("Marriage Date : ",customerData!.marriageDate??""),
                            //

                          ],
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
          style: AppTextStyle.textMedium.copyWith(fontSize: 15),
        ),
        Text(
          value,
          style: AppTextStyle.textRegular15,
        ),
      ],
    );
  }
}