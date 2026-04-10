import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/material_category/new_bricks/new_request_screen.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/view/widgets/custom_date_picker.dart';

import 'bricks_details_controller.dart';

class BricksDetailsScreen extends StatefulWidget {
  const BricksDetailsScreen({super.key});

  @override
  State<BricksDetailsScreen> createState() => _BricksDetailsScreenState();
}

class _BricksDetailsScreenState extends State<BricksDetailsScreen> {

  final MaterialDetailsArgs args = Get.arguments as MaterialDetailsArgs;

  final BricksDetailsController controller = Get.put(BricksDetailsController(materialDetailsArgs:Get.arguments));


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
                          await Get.to(()=>NewRequestScreen(type: 1,),arguments: args);
                          controller.fetchData();
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
                      ElevatedButton(
                        onPressed: () async {
                          await Get.to(()=>NewRequestScreen(type: 2,),arguments: args);
                          controller.fetchData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.buttonBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        child: Text('New Order',
                            style: AppTextStyle.textMedium
                                .copyWith(color: AppColor.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            _buildTableHeader(),
            Obx(() {
              final list = controller.getBricksLists;
              return Column(
                children: list.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildTableRow({
                    'id': (index + 1).toString(),
                    'date': item.date ?? '',
                    'unit': item.quantity ?? '0',
                    'vendor': item.vendorName ?? '',
                    'price': item.price?.toString() ?? '0',
                  }, isEven: index % 2 == 0);
                }).toList(),
              );
            }),

            Obx((){
              final bricks = controller.bricksModel?.value;
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
                        Text(' ${bricks?.totalUnits ?? "0"} Unit',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${bricks?.totalAmount ?? "0"}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // Settled Amount row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Settled Amount',
                            style: AppTextStyle.textRegular15
                                .copyWith(color: AppColor.buttonGreen)),
                        Text('${bricks?.settledAmount ?? "0"}',
                            style: AppTextStyle.textRegular15
                                .copyWith(color: AppColor.buttonGreen))
                      ],
                    ),
                  ),
                  // Pending Amount row
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColor.pendingBGColorr, // light background
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      border:
                          Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pending Amount',
                            style: AppTextStyle.textRegular15
                                .copyWith(color: AppColor.red)),
                        Text('${bricks?.pendingAmount ?? "0"}',
                            style: AppTextStyle.textRegular15
                                .copyWith(color: AppColor.red)),
                      ],
                    ),
                  ),
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
          _buildCell('Material Details', flex: 6, bold: true),
          _buildCell('Quantity', flex: 3, bold: true, align: TextAlign.center),
          _buildCell('Price', flex: 3, bold: true, align: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, String> item, {bool isEven = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        color: isEven ? AppColor.white : AppColor.tableBGColor,
      ),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Stacked Details: S.No, Date, and Vendor
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("${item['id']}. ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColor.buttonBlue)),
                    Text(item['date']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  item['vendor']!.isEmpty ? "N/A" : item['vendor']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          // Quantity
          _buildCell(item['unit']!, flex: 3, align: TextAlign.center, bold: true),
          // Price
          _buildCell(item['price']!, flex: 3, align: TextAlign.right, bold: true),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {int flex = 1, bool bold = false, TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          text,
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w400,
              color: AppColor.black,
              fontSize: 12),
        ),
      ),
    );
  }
}
