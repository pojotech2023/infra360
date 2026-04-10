import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';

import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/view/widgets/custom_date_picker.dart';

import '../../../model/subcontractor_list_model.dart';
import 'new_services_request_screen.dart';
import 'request_details_controller.dart';

class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({super.key});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {

  final SubcontracorDetailsArgs args = Get.arguments as SubcontracorDetailsArgs;

  final RequestDetailsController controller = Get.put(RequestDetailsController(materialDetailsArgs:Get.arguments));


  void _pickMonth() async {
    final result = await showCustomMonthPicker(context, controller.selectedYear.value,initialMonth:
    controller.selectedMonth.value);
    if (result != null) {
      final parts = result.split("-");
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      controller.onMonthSelected(year, month);
    }
  }
  @override
  Widget build(BuildContext context) {



    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "${capitalize(args.itemKey)} Details",
          onTap: () {
            Get.back();
          }),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Obx((){
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: ()async{
                      _pickMonth();
                    },
                    child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColor.materialCategoryBorderColor,
                              width: 1),
                        ),
                        child:Row(
                          children: [
                            Text(
                              controller.selectedMonthText.value ?? "Select Month",
                              style: TextStyle(fontSize: 16),
                            ),
                            HorizontalSpacing.d2px(),
                            Icon(Icons.keyboard_arrow_down)
                          ],
                        )
                    ),
                  ),

                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: ListView.separated(
                        shrinkWrap: true,
                        primary: false,
                        padding: EdgeInsets.only(left: 10),
                        itemCount: 4,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context,int index){
                          return
                            Obx(()=>InkWell(
                              onTap: (){
                                controller.onWeekSelected(index + 1);


                              },
                              child: Container(
                                width: 55,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color:
                                    controller.selectedWeek.value==index+1?
                                    AppColor.buttonBlue:AppColor.black,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Text("W${index+1}",
                                  style: TextStyle(color: AppColor.white),),
                              ),
                            ));

                        }, separatorBuilder: (BuildContext context, int index) {
                        return Padding(padding: EdgeInsets.only(right: 10));
                      },),
                    ),
                  ),
                ],
              );
            }),

            VerticalSpacing.d20px(),
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    capitalize(args.itemKey),
                    style: AppTextStyle.materialTitleText
                        .copyWith(color: Color(0xFF252C58), fontSize: 16),
                  ),
                  

                  
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          Get.to(NewServiceRequestScreen(),arguments: args);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.buttonBlue.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(7), // rounded corners
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        child: Text('Add Request',
                            style: AppTextStyle.textMedium
                                .copyWith(color: AppColor.white)),
                      ),

                      HorizontalSpacing.d5px(),

                      // New Order Button (Blue)

                    ],
                  )
                ],
              ),
            ),
            _buildTableHeader(),
            GetBuilder<RequestDetailsController>(builder: (RequestDetailsController controller)=> Column(
              children: controller.listModel
                  .map((item) => _buildTableRow({
                'id': item.id.toString(),
                'date': item.date ?? '',
                'Sub contractor': item.subcontractorType ?? '',
                'price': item.amount.toString() ,
              }))
                  .toList(),
            ),  ),

      GetBuilder<RequestDetailsController>(builder: (controllers){
             // final Subcontractor = controller.SubcontractorModel?.value;
            return  Container(
              margin: EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // TOTAL row
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColor.totalBGColor, // light blue background
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:  [
                        Text('TOTAL',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${controllers.model.totalAmount ?? "0"}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // Settled Amount row

                ],
              ),
            );})
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
          _buildCell('S.No', bold: true),
          _buildCell('Date', flex: 2, bold: true),
          _buildCell('Sub contractor',flex: 2, bold: true),
          _buildCell('Price', bold: true),
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
          _buildCell(item['id']!),
          _buildCell(item['date']!, flex: 2),
          _buildCell(item['Sub contractor'] ?? '',flex: 2 ),
          _buildCell(item['price']!,),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {int flex = 1, bool bold = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w400,
              color: AppColor.black,
              fontSize: 13),
        ),
      ),
    );
  }
}
