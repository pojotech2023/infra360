import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/model/attendance_list_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/images.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/attendance/attendance_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/view/widgets/custom_date_picker.dart';

import 'add_wages.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int? id;

  AttendanceController controller = Get.put(AttendanceController());

  @override
  void initState() {
    // TODO: implement initState
    id = Get.arguments;
    controller.siteId.value = id;
    controller.init(id);
    controller.totalWeeks.value = ConstantData.getWeeksInMonth(
        controller.selectedYear.value, controller.selectedMonth.value);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Today Attendance",
          onTap: () {
            Get.back();
          },actions: [
            InkWell(
              onTap:()=>  controller.attendanceExcelDownload(context),
              child: Image.asset(
                'assets/images/xls.png',
                width: 46,
                height: 46,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16,),

]),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Obx((){

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 4,
                  child: InkWell(
                    onTap: () async {
                      _pickMonth();
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColor.materialCategoryBorderColor,
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                controller.selectedMonthText.value ??
                                    "Select Month",
                                style: TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down, size: 20)
                          ],
                        )),
                  ),
                ),
                HorizontalSpacing.custom(value: 8),
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: 30,
                    child: Obx(() => ListView.separated(
                      shrinkWrap: true,
                      primary: false,
                      padding: EdgeInsets.only(left: 10),
                      itemCount: controller.totalWeeks.value,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return Obx(() => InkWell(
                              onTap: () {
                                controller.onWeekSelected(index + 1);
                              },
                              child: Container(
                                width: 55,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: controller.selectedWeek.value ==
                                            index + 1
                                        ? AppColor.buttonBlue
                                        : AppColor.black,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  "W${index + 1}",
                                  style: TextStyle(color: AppColor.white),
                                ),
                              ),
                            ));
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Padding(padding: EdgeInsets.only(right: 8));
                      },
                    )),
                  ),
                ),
              ],
            );}),
            VerticalSpacing.d20px(),



            Obx(() {
              return controller.weekDaysList.isNotEmpty
                  ? SizedBox(
                      height: 80,
                      child: ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.weekDaysList.length,
                          itemBuilder: (BuildContext context, int index) {
                            WeekDays weekDays = controller.weekDaysList[index];
                            return InkWell(
                              onTap: () {
                                controller.selectedDate.value = weekDays.value!;
                                controller.onDaysSelected(weekDays.value!);

                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                  ),
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                      color: controller.selectedDate.value ==
                                              weekDays.value
                                          ? AppColor.black
                                          : AppColor.daysSelected,
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        weekDays.label!.split(" ")[0],
                                        style: AppTextStyle.textMedium.copyWith(
                                            fontSize: 14,
                                            color:
                                                controller.selectedDate.value ==
                                                        weekDays.value
                                                    ? AppColor.white
                                                    : AppColor.black),
                                      ),
                                      Text(weekDays.label!.split(" ")[1],
                                          style: AppTextStyle.textMedium
                                              .copyWith(
                                                  fontSize: 14,
                                                  color: controller.selectedDate
                                                              .value ==
                                                          weekDays.value
                                                      ? AppColor.white
                                                      : AppColor.black)),
                                    ],
                                  )),
                            );
                          }),
                    )
                  : Container();
            }),


            Obx(() {
              return controller.weekDaysList.isNotEmpty
                  ? VerticalSpacing.d20px()
                  : Container();
            }),


           MediaQuery.of(context).size.width >600 ?
            Row(
            //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Workers",
                  style: AppTextStyle.textMedium.copyWith(fontSize: 17),
                ),
               Expanded(child:  Row(
                 children: [
                   Expanded(
                       flex: 2,
                       child:InkWell(
                         borderRadius: BorderRadius.circular(6),
                         onTap: () {
                           controller.clear();
                           showAddWagesBottomSheet(context, "1", []);
                         },
                         child: Container(
                           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                           decoration: BoxDecoration(
                             color: AppColor.buttonBlue,
                             borderRadius: BorderRadius.circular(6),
                             boxShadow: const [
                               BoxShadow(
                                 color: Colors.black26,
                                 blurRadius: 4,
                                 offset: Offset(0, 2),
                               ),
                             ],
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: const [
                               Icon(
                                 Icons.add,
                                 color: Colors.white,
                                 size: 18,
                               ),
                               SizedBox(width: 6),
                               Text(
                                 "Wages",
                                 style: TextStyle(
                                   color: Colors.white,
                                   fontWeight: FontWeight.w600,
                                   fontSize: 14,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       )
                     ,),



                   SizedBox(width: 16,),

                   Expanded(
                     flex: 2,
                     child:InkWell(
                       borderRadius: BorderRadius.circular(6),
                       onTap: () {
                         controller.clear();
                         showAddWagesBottomSheet(context,"2",[]);
                       },
                       child: Container(
                         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                         decoration: BoxDecoration(
                           color: AppColor.buttonBlue,
                           borderRadius: BorderRadius.circular(6),
                           boxShadow: const [
                             BoxShadow(
                               color: Colors.black26,
                               blurRadius: 4,
                               offset: Offset(0, 2),
                             ),
                           ],
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: const [
                             Icon(
                               Icons.add,
                               color: Colors.white,
                               size: 18,
                             ),
                             SizedBox(width: 6),
                             Text(
                               "Attendance",
                               style: TextStyle(
                                 color: Colors.white,
                                 fontWeight: FontWeight.w600,
                                 fontSize: 14,
                               ),
                             ),
                           ],
                         ),
                       ),
                     )
                     ,),





                 ],
               ))
              ],
            ) :  Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 "Total Workers",
                 style: AppTextStyle.textMedium.copyWith(fontSize: 17),
               ),
                SizedBox(height: 6,),
                Row(

                 children: [
                   Expanded(
                     flex: 2,
                     child:InkWell(
                       borderRadius: BorderRadius.circular(6),
                       onTap: () {
                         controller.clear();
                         showAddWagesBottomSheet(context, "1", []);
                       },
                       child: Container(
                         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                         decoration: BoxDecoration(
                           color: AppColor.buttonBlue,
                           borderRadius: BorderRadius.circular(6),
                           boxShadow: const [
                             BoxShadow(
                               color: Colors.black26,
                               blurRadius: 4,
                               offset: Offset(0, 2),
                             ),
                           ],
                         ),
                         child: Row(
                           crossAxisAlignment: CrossAxisAlignment.center,
mainAxisAlignment: MainAxisAlignment.center,
                           mainAxisSize: MainAxisSize.min,
                           children: const [
                             Icon(
                               Icons.add,
                               color: Colors.white,
                               size: 18,
                             ),
                             SizedBox(width: 6),
                             Text(
                               "Wages",
                               style: TextStyle(
                                 color: Colors.white,
                                 fontWeight: FontWeight.w600,
                                 fontSize: 14,
                               ),
                             ),
                           ],
                         ),
                       ),
                     )
                     ,),



                   SizedBox(width: 16,),

                   Expanded(
                     flex: 2,
                     child:InkWell(
                       borderRadius: BorderRadius.circular(6),
                       onTap: () {
                         controller.clear();
                         showAddWagesBottomSheet(context,"2",[]);
                       },
                       child: Container(
                         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                         decoration: BoxDecoration(
                           color: AppColor.buttonBlue,
                           borderRadius: BorderRadius.circular(6),
                           boxShadow: const [
                             BoxShadow(
                               color: Colors.black26,
                               blurRadius: 4,
                               offset: Offset(0, 2),
                             ),
                           ],
                         ),
                         child: Row(    crossAxisAlignment: CrossAxisAlignment.center,
                           mainAxisAlignment: MainAxisAlignment.center,
                           mainAxisSize: MainAxisSize.min,
                           children: const [
                             Icon(
                               Icons.add,
                               color: Colors.white,
                               size: 18,
                             ),
                             SizedBox(width: 6),
                             Text(
                               "Attendance",
                               style: TextStyle(
                                 color: Colors.white,
                                 fontWeight: FontWeight.w600,
                                 fontSize: 14,
                               ),
                             ),
                           ],
                         ),
                       ),
                     )
                     ,),





                 ],
               )
             ],
           )  ,


            Obx((){
              return GridView.builder(
                shrinkWrap: true,
                primary: false,
                padding: EdgeInsets.only(top: 16),
                itemCount: controller.attendanceList.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75
                ),
                itemBuilder: (BuildContext context,int index){
               Attendances attendances=   controller.attendanceList[index];
                  /*return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ConstantData().attendanceBorderColor[index% ConstantData().attendanceBorderColor.length], width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: ConstantData().attendanceShadowColor[index% ConstantData().attendanceShadowColor.length],
                          blurRadius: 10,
                          spreadRadius: 0.8,
                          offset: Offset(0, 6), // vertical shadow
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(alignment: Alignment.topRight,
                        child: IconButton(onPressed: (){
                          controller.clear();
                          showAddWagesBottomSheet(context,"3",controller.attendanceList);
                        }, icon: Icon(Icons.edit)),),

                        Text("${attendances.count}",
                        style: AppTextStyle.textMedium
                          .copyWith(fontSize: 20,
                        color: AppColor.attendanceTextColor),),

                       Row(
                         children: [
                           Text("${attendances.category}",
                               style: AppTextStyle.textMedium
                                   .copyWith(fontSize: 18,
                                   color: AppColor.attendanceTextColor)),

                           Text(" x ${attendances.amount}",
                               style: AppTextStyle.textMedium
                                   .copyWith(fontSize: 18,
                                   color:Colors.grey)),
                           Text(
                             " = ${(attendances.amount ?? 0) * (attendances.count ?? 0)}",
                             style: AppTextStyle.textMedium.copyWith(
                               fontSize: 18,
                               color: Colors.grey,
                             ),
                           ),

                         ],
                       )

                      ],
                    ),
                  );*/
return Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: ConstantData()
          .attendanceBorderColor[index %
          ConstantData().attendanceBorderColor.length],
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: ConstantData()
            .attendanceShadowColor[index %
            ConstantData().attendanceShadowColor.length],
        blurRadius: 10,
        spreadRadius: 1,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: Column(

    children: [
      /// ---------------- TOP SECTION ----------------
      Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.selectedDate.value == null)
                        Text(
                          controller.selectedWeek.value != null
                              ? "Week ${controller.selectedWeek.value}"
                              : "${DateFormat('MMMM').format(DateTime(2000, controller.selectedMonth.value))} Month",
                          style: AppTextStyle.textMedium.copyWith(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (controller.selectedDate.value == null)
                        const SizedBox(height: 4),  
                      Text(
                        attendances.category ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.textMedium.copyWith(
                          fontSize: 18,
                          color: AppColor.attendanceTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.selectedDate.value != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        controller.clear();
                        showAddWagesBottomSheet(
                            context, "3", controller.attendanceList);
                      },
                    ),
                  ),
              ],
            ),
            /// Edit icon

SizedBox(height: 30,),
            /// Category & Count
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, color: Colors.grey, size: 20),
                  Text(
                    " ${attendances.count ?? 0}  *  ",
                    style: AppTextStyle.textMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "${attendances.amount ?? 0}",
                    style: AppTextStyle.textMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30,),

            /// Amount

          ],
        ),
      ),

      /// ---------------- BOTTOM COLORED SECTION ----------------
     Expanded(child:  Container(
       width: double.infinity,
       padding: const EdgeInsets.symmetric(vertical: 14),
       decoration: BoxDecoration(
         color: ConstantData()
             .attendanceBorderColor[index %
             ConstantData().attendanceBorderColor.length],
         borderRadius: const BorderRadius.only(
           bottomLeft: Radius.circular(14),
           bottomRight: Radius.circular(14),
         ),
       ),
       child: Center(
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 8),
           child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "Total : ₹ ${(attendances.amount ?? 0) * (attendances.count ?? 0)}",
              style: AppTextStyle.textMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
         ),
       ),
     ),)
    ],
  ),
);

                },
              );
            }),

            Obx(() {
              return controller.attendanceList.isNotEmpty?
              Container(
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.only(top: 20, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.totalWages, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.totalWagesShadow,
                      blurRadius: 10,
                      spreadRadius: 0.9,
                      offset: Offset(0, 6), // vertical shadow
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Total Workers Column
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "TOTAL WORKERS",
                            style: AppTextStyle.customerDetailsStyle.copyWith(
                                color: AppColor.totalWagesTextColor,
                                fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                            "${controller.totalWorkers.value}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[900],
                            ),
                          )),
                        ],
                      ),
                    ),

                    // Divider
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey.withOpacity(0.3),
                    ),

                    // Total Wages Column
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "TOTAL WAGES",
                            style: AppTextStyle.customerDetailsStyle.copyWith(
                                color: AppColor.totalWagesTextColor,
                                fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                            "₹ ${controller.totalWages.value ?? 0}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[900],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ):Container();
            }),
            VerticalSpacing.custom(value: 80)
          ],
        ),
      ),
    ),
    );
  }

  void _pickMonth() async {
    final result = await showCustomMonthPicker(
        context, controller.selectedYear.value,
        initialMonth: controller.selectedMonth.value);
    if (result != null) {
      final parts = result.split("-");
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      controller.onMonthSelected(year, month);
    }
  }
  void showAddWagesBottomSheet(BuildContext context,type,List<Attendances> data,) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
        useSafeArea:true,


      builder: (_) {
    return DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.8,
    snap: true,
    builder: (_, controller1) {
        return AddWages(types:type,attendanceDatas: data,scrollController: controller1,);});
      },
    );
  }
}
