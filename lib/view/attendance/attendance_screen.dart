import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/model/attendance_list_model.dart';
import 'package:raptor_pro/api/api_data.dart';
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
import 'package:raptor_pro/view/widgets/full_screen_image_viewer.dart';

import '../../utils/url_helper.dart';
import 'add_wages.dart';
import 'export_attendance.dart';

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
    controller.totalWeeks.value = ConstantData.getWeeksInMonth(
        controller.selectedYear.value, controller.selectedMonth.value);
    controller.init(id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Attendance",
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    _pickMonth();
                  },
                  child: Container(
                      width: 150,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColor.materialCategoryBorderColor,
                            width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              controller.displayMonthText.value.isNotEmpty
                                  ? controller.displayMonthText.value
                                  : "Select Month",
                              style: TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down, size: 20)
                        ],
                      )),
                ),
                VerticalSpacing.custom(value: 12),
                SizedBox(
                  height: 40,
                  child: Obx(() => ListView.separated(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: controller.totalWeeks.value + 1,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      final tabName = index == 0 ? 'Full Month' : 'Week ${index}';
                      return Obx(() => InkWell(
                            onTap: () {
                              controller.onTabSelected(tabName);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: controller.selectedTab.value == tabName
                                      ? AppColor.buttonBlue
                                      : AppColor.black,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                tabName,
                                style: TextStyle(color: AppColor.white, fontSize: 13),
                              ),
                            ),
                          ));
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Padding(padding: EdgeInsets.only(right: 8));
                    },
                  )),
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
                            return Obx(() => InkWell(
                              onTap: () {
                                print("📅 Date tapped: ${weekDays.value}");
                                controller.selectedDate.value = weekDays.value!;
                                print("📅 selectedDate.value set to: ${controller.selectedDate.value}");
                                controller.onDaysSelected(weekDays.value!);

                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                      color: controller.selectedDate.value ==
                                              weekDays.value
                                          ? AppColor.buttonBlue
                                          : AppColor.daysSelected,
                                      borderRadius: BorderRadius.circular(16),
                                      border: controller.selectedDate.value ==
                                              weekDays.value
                                          ? Border.all(
                                              color: AppColor.buttonBlue,
                                              width: 2,
                                            )
                                          : null,
                                      boxShadow: controller.selectedDate.value ==
                                              weekDays.value
                                          ? [
                                              BoxShadow(
                                                color: AppColor.buttonBlue.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ]
                                          : null),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        weekDays.label!.split(" ")[0],
                                        style: AppTextStyle.textMedium.copyWith(
                                            fontSize: 14,
                                            fontWeight: controller.selectedDate.value ==
                                                    weekDays.value
                                                ? FontWeight.bold
                                                : FontWeight.normal,
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
                                                  fontWeight: controller.selectedDate.value ==
                                                          weekDays.value
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: controller.selectedDate
                                                              .value ==
                                                          weekDays.value
                                                      ? AppColor.white
                                                      : AppColor.black)),
                                    ],
                                  )),
                            ));
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
                         showDialog(context: context, builder: (_) => ExportAttendance());
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
                               Icons.download,
                               color: Colors.white,
                               size: 18,
                             ),
                             SizedBox(width: 6),
                             Text(
                               "Export",
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
                         showDialog(context: context, builder: (_) => ExportAttendance());
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
                               Icons.download,
                               color: Colors.white,
                               size: 18,
                             ),
                             SizedBox(width: 6),
                             Text(
                               "Export",
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
              if (controller.attendanceList.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Text("No attendance records found.", style: AppTextStyle.textMedium),
                );
              }
              // Group attendance by date
              Map<String, List<Attendances>> groupedData = {};
              for (var item in controller.attendanceList) {
                if (item.date != null) {
                  groupedData.putIfAbsent(item.date!, () => []).add(item);
                }
              }

              return Column(
                children: groupedData.entries.map((entry) {
                  String rawDate = entry.key;
                  List<Attendances> items = entry.value;
                  String displayDate = DateFormat('dd MMM yyyy').format(DateTime.parse(rawDate));

                  return Container(
                    margin: EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        // Card Header (Date + Actions)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Color(0xffC8D6FF),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(displayDate, style: AppTextStyle.textBold.copyWith(fontSize: 15, color: Colors.indigo.shade900)),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      controller.clear();
                                      showAddWagesBottomSheet(context, "3", items);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                                      child: Icon(Icons.edit, size: 18, color: Colors.blue.shade700),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      print("Delete button tapped for date: $displayDate");
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Confirm Delete"),
                                            content: Text("Are you sure you want to delete all attendance records for $displayDate?"),
                                            actions: [
                                              TextButton(
                                                style: TextButton.styleFrom(backgroundColor: Colors.blue.shade400, foregroundColor: Colors.white),
                                                child: Text("Cancel"),
                                                onPressed: () => Navigator.of(context).pop(),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
                                                child: Text("Delete"),
                                                onPressed: () async {
                                                  print("Delete confirmed for date: $displayDate");
                                                  Navigator.of(context).pop();
                                                  // Delete all records for this date by calling delete for each ID
                                                  print("Starting to delete ${items.length} records for date $displayDate");
                                                  for (var item in items) {
                                                    print("Checking item: category=${item.category}, count=${item.count}, id=${item.id}");
                                                    if (item.id != null) {
                                                      print("➡️ Deleting record with ID: ${item.id}");
                                                      await controller.deleteAttendance(item.id!);
                                                    } else {
                                                      print("⚠️ Skipping delete for ${item.category} because ID is NULL");
                                                    }
                                                  }
                                                  print("Delete operation completed. Now deleting wages for $displayDate");
                                                  await ApiData().deleteWagesRowApi({
                                                    "site_id": controller.siteId.value,
                                                    "date": rawDate,
                                                  });
                                                  print("Wages deletion requested. Fetching latest data...");
                                                  await controller.init(controller.siteId.value);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                                      child: Icon(Icons.delete, size: 18, color: Colors.red.shade600),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        // Column Headers
                        Padding(
                          padding: EdgeInsets.only(top: 12, bottom: 4, left: 16, right: 16),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text("Category", style: AppTextStyle.textBold.copyWith(fontSize: 13, color: Colors.grey.shade700))),
                              Expanded(flex: 1, child: Text("Count", style: AppTextStyle.textBold.copyWith(fontSize: 13, color: Colors.grey.shade700), textAlign: TextAlign.center)),
                              Expanded(flex: 2, child: Text("Wages", style: AppTextStyle.textBold.copyWith(fontSize: 13, color: Colors.grey.shade700), textAlign: TextAlign.right)),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey.shade200, height: 1),
                        // List of categories
                        ListView.separated(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => Divider(color: Colors.grey.shade100, height: 1),
                          itemBuilder: (context, index) {
                            Attendances item = items[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(flex: 2, child: Text(item.category ?? "-", style: AppTextStyle.textMedium.copyWith(fontSize: 14))),
                                  Expanded(flex: 1, child: Text("${item.count ?? 0}", style: AppTextStyle.textMedium.copyWith(fontSize: 14), textAlign: TextAlign.center)),
                                  Expanded(flex: 2, child: Text(
                                    () {
                                      final total = (item.amount ?? 0) * (item.count ?? 0);
                                      return total == total.roundToDouble()
                                          ? "₹ ${total.toInt()}"
                                          : "₹ ${total.toStringAsFixed(2)}";
                                    }(),
                                    style: AppTextStyle.textMedium.copyWith(fontSize: 14, color: Colors.green.shade700),
                                    textAlign: TextAlign.right,
                                  )),
                                ],
                              ),
                            );
                          },
                        ),
                        if (items.isNotEmpty) _buildCardFooterPhotos(items, context),
                      ],
                    ),
                  );
                }).toList(),
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

  void showAddWagesBottomSheet(BuildContext context, type, List<Attendances> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          snap: true,
          builder: (_, scrollController) {
            return AddWages(
              types: type,
              attendanceDatas: data,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int min = int.parse(parts[1]);
        String ampm = hour >= 12 ? 'PM' : 'AM';
        int h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return "${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')} $ampm";
      }
    } catch (e) {
      return timeStr;
    }
    return timeStr;
  }

  String _resolvePhotoUrl(String? path) => UrlHelper.getFullImageUrl(path);

  Attendances? _photoSourceForDate(List<Attendances> items) {
    // First check individual records for photos
    for (final item in items) {
      final hasCheckIn = item.imageUrl != null && item.imageUrl!.trim().isNotEmpty;
      final hasCheckOut = item.checkOutPhoto != null && item.checkOutPhoto!.trim().isNotEmpty;
      if (hasCheckIn || hasCheckOut) return item;
    }
    
    // If no individual records have photos, check the controller's datePhotoLookup for day-level photos
    if (items.isNotEmpty) {
      final date = items.first.date;
      if (date != null) {
        final dayPhotos = controller.datePhotoLookup[date];
        if (dayPhotos != null) {
          final checkInPhoto = dayPhotos['check_in_photo']?.toString();
          final checkOutPhoto = dayPhotos['check_out_photo']?.toString();
          final hasCheckIn = checkInPhoto != null && checkInPhoto.trim().isNotEmpty;
          final hasCheckOut = checkOutPhoto != null && checkOutPhoto.trim().isNotEmpty;
          
          if (hasCheckIn || hasCheckOut) {
            // Return the first item with day-level photos applied
            final item = items.first;
            item.imageUrl = checkInPhoto;
            item.checkOutPhoto = checkOutPhoto;
            item.time = dayPhotos['check_in_time']?.toString();
            item.checkOutTime = dayPhotos['check_out_time']?.toString();
            return item;
          }
        }
      }
    }
    
    return items.isNotEmpty ? items.first : null;
  }

  Widget _buildCardFooterPhotos(List<Attendances> items, BuildContext context) {
    final item = _photoSourceForDate(items);
    if (item == null) return const SizedBox.shrink();

    final checkInUrl = _resolvePhotoUrl(item.imageUrl);
    final checkOutUrl = _resolvePhotoUrl(item.checkOutPhoto);
    final hasCheckIn = checkInUrl.isNotEmpty;
    final hasCheckOut = checkOutUrl.isNotEmpty;

    if (!hasCheckIn && !hasCheckOut) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Photos", style: AppTextStyle.textBold.copyWith(fontSize: 13, color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasCheckIn)
                    Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => FullScreenImageViewer.show(context, checkInUrl),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                checkInUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image, size: 24, color: Colors.grey);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("In: ${_formatTime(item.time)}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  if (hasCheckOut)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => FullScreenImageViewer.show(context, checkOutUrl),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                checkOutUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image, size: 24, color: Colors.grey);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("Out: ${_formatTime(item.checkOutTime)}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
