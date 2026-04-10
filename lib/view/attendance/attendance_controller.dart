import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/attendance_list_model.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/view/widgets/custom_date_picker.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

import '../../model/attendance_datewise_model.dart';
import '../../model/excel_attendance_download.dart';
import '../../utils/const_data.dart';
import '../../utils/file_download.dart';

class AttendanceController extends GetxController {
  RxnInt selectedWeek = RxnInt();
  RxString selectedMonthText = ''.obs;
  RxInt selectedYear = DateTime.now().year.obs;
  RxInt selectedMonth = DateTime.now().month.obs;
  RxnString selectedDate = RxnString();

  List<WeekDays>? weekDays;
  RxInt totalWeeks = 1.obs;

  RxnInt siteId = RxnInt();
  RxList<WeekDays> weekDaysList = <WeekDays>[].obs;
  RxList<Attendances> attendanceList = <Attendances>[].obs;

  RxnInt totalWages = RxnInt();
  RxInt totalWorkers = 0.obs;

  RxBool attendanceSave = false.obs;

  final TextEditingController masonCountController = TextEditingController();
  final TextEditingController masonAmountController = TextEditingController();

  final TextEditingController helperCountController = TextEditingController();
  final TextEditingController helperAmountController = TextEditingController();

  final TextEditingController fitterCountController = TextEditingController();
  final TextEditingController fitterAmountController = TextEditingController();

  final TextEditingController centringHelperCountController =
      TextEditingController();
  final TextEditingController centringHelperAmountController =
      TextEditingController();

  var data = Get.arguments;

  @override
  void onInit() {
    updateMonthText();
    super.onInit();
  }

  init(int? id) async {
    AttendanceListModel? attendanceListModel = await ApiData().attendanceList(
        id!, selectedMonthText.value, selectedWeek.value, selectedDate.value);

    if (attendanceListModel != null) {
      print("📊 Attendance API: TotalWages=${attendanceListModel.totalWages}, Date=${selectedDate.value}, Week=${selectedWeek.value}");
      if (attendanceListModel.categoryWages != null) {
        print("🧱 CategoryWages: Mason=${attendanceListModel.categoryWages?.mason}, Helper=${attendanceListModel.categoryWages?.helper}");
      }
      weekDaysList.value = attendanceListModel.weekDays ?? [];

      totalWages.value = attendanceListModel.totalWages ?? 0;

      // Build the summary view for Month/Week
      if (selectedDate.value == null) {
        if (attendanceListModel.attendances != null && attendanceListModel.attendances!.isNotEmpty) {
          // If we have individual records, aggregate them manually to ensure period-only accuracy
          attendanceList.assignAll(aggregateAttendances(attendanceListModel.attendances!, attendanceListModel.wage));
          print("📊 Built summary from ${attendanceListModel.attendances!.length} individual records");
        } else if (attendanceListModel.categoryWages != null) {
          // Fallback to pre-aggregated server data if individual records are too many/missing
          List<Attendances> summaryList = [];
          final cw = attendanceListModel.categoryWages!;
          final wage = attendanceListModel.wage;
          String dateString = "${selectedYear.value}-${selectedMonth.value.toString().padLeft(2, '0')}-01";

          if (cw.mason != null && cw.mason! > 0) {
            summaryList.add(Attendances(category: "Mason", count: cw.mason, amount: double.tryParse(wage?.mason ?? "0"), date: dateString));
          }
          if (cw.helper != null && cw.helper! > 0) {
            summaryList.add(Attendances(category: "Helper", count: cw.helper, amount: double.tryParse(wage?.helper ?? "0"), date: dateString));
          }
          if (cw.fitter != null && cw.fitter! > 0) {
            summaryList.add(Attendances(category: "Fitter", count: cw.fitter, amount: double.tryParse(wage?.fitter ?? "0"), date: dateString));
          }
          if (cw.centringHelper != null && cw.centringHelper! > 0) {
            summaryList.add(Attendances(category: "Centring Helper", count: cw.centringHelper, amount: double.tryParse(wage?.centringHelper ?? "0"), date: dateString));
          }
          attendanceList.assignAll(summaryList);
          print("📊 Built summary from server categoryWages");
        } else {
          attendanceList.clear();
        }
      }

      final wage = attendanceListModel.wage;

      /* if (wage != null) {
        for (var data in attendanceList) {
          // Normalize category name to lowercase for comparison
          final normalizedCategory = data.category?.toLowerCase().trim();

          double? wageValue;

          if (normalizedCategory == 'mason') {
            wageValue = double.tryParse(wage.mason ?? '0');
          } else if (normalizedCategory == 'helper') {
            wageValue = double.tryParse(wage.helper ?? '0');
          } else if (normalizedCategory == 'centring helper') {
            wageValue = double.tryParse(wage.centringHelper ?? '0');
          } else if (normalizedCategory == 'fitter') {
            wageValue = double.tryParse(wage.fitter ?? '0');
          }

          if (wageValue != null) {
            data.amount = wageValue;
          }
        }
      }*/
      calculateTotalWages();
    }
  }

  void calculateTotalWages() {
    double wages = 0;
    int workers = 0;
    for (var item in attendanceList) {
      wages += (item.amount ?? 0) * (item.count ?? 0);
      workers += (item.count ?? 0);
    }
    totalWages.value = wages.round();
    totalWorkers.value = workers;
  }

  dateWiseAttendance(int? id, String date) async {
    AttendanceDatewiseModel? attendanceListModel =
    await ApiData().dateWiseattendanceApi(id!, date);

    if (attendanceListModel != null) {
      totalWages.value = attendanceListModel.totalWages ?? 0;

      if (attendanceListModel.data != null) {
        final convertedAttendances = convertDataToAttendances(
          attendanceListModel.data!.toJson(),
          id,
        );

        attendanceList.value = convertedAttendances;
      } else {
        attendanceList.clear();
      }
      calculateTotalWages();
    }


  }


  List<Attendances> convertDataToAttendances(
      Map<String, dynamic> data, int siteId) {
    final String date = data['date'];

    final List<Map<String, String>> categories = [
      {'key': 'mason', 'label': 'Mason'},
      {'key': 'helper', 'label': 'Helper'},
      {'key': 'fitter', 'label': 'Fitter'},
      {'key': 'centring_helper', 'label': 'Centring Helper'},
    ];

    final List<Attendances> attendances = [];

    for (var item in categories) {
      final String key = item['key']!;
      final String label = item['label']!;

      final int count = data[key] ?? 0;
      final double amount =
          double.tryParse(data['${key}_wage']?.toString() ?? '0') ?? 0;

      if (count > 0) {
        attendances.add(
          Attendances(
            siteId: siteId,
            category: label,
            count: count,
            amount: amount,
            date: date,
          ),
        );
      }
    }

    return attendances;
  }

  List<Attendances> aggregateAttendances(List<Attendances> list, Wage? wages) {
    Map<String, int> counts = {"Mason": 0, "Helper": 0, "Fitter": 0, "Centring Helper": 0};
    Map<String, double> totals = {"Mason": 0.0, "Helper": 0.0, "Fitter": 0.0, "Centring Helper": 0.0};

    DateTime now = DateTime.now();
    DateTime currentDate = DateTime(now.year, now.month, now.day);

    for (var item in list) {
      if (item.date != null) {
        DateTime parsedDate = DateTime.tryParse(item.date!) ?? DateTime(2000);
        if (parsedDate.isAfter(currentDate)) {
          continue; // Skip entries after the current date
        }
      }

      final cat = item.category ?? "";
      if (counts.containsKey(cat)) {
        double dayAmount = item.amount ?? 0.0;
        if (dayAmount <= 0.0) {
          if (cat == "Mason") dayAmount = double.tryParse(wages?.mason ?? "0") ?? 0.0;
          else if (cat == "Helper") dayAmount = double.tryParse(wages?.helper ?? "0") ?? 0.0;
          else if (cat == "Fitter") dayAmount = double.tryParse(wages?.fitter ?? "0") ?? 0.0;
          else if (cat == "Centring Helper") dayAmount = double.tryParse(wages?.centringHelper ?? "0") ?? 0.0;
        }

        counts[cat] = (counts[cat] ?? 0) + (item.count ?? 0);
        totals[cat] = (totals[cat] ?? 0.0) + ((item.count ?? 0) * dayAmount);
      }
    }

    String dateString = "${selectedYear.value}-${selectedMonth.value.toString().padLeft(2, '0')}-01";
    List<Attendances> summary = [];

    counts.forEach((label, count) {
      if (count > 0) {
        double avgAmount = count > 0 ? (totals[label]! / count) : 0.0;
        summary.add(Attendances(category: label, count: count, amount: double.parse(avgAmount.toStringAsFixed(2)), date: dateString));
      }
    });

    return summary;
  }

  attendanceExcelDownload(BuildContext context) async {
    ExcelAttendanceDownloadModel? attendanceListModel = await ApiData()
        .attendanceExcelDownload(data!, selectedMonthText.value,
            selectedWeek.value, selectedDate.value);

    if (attendanceListModel != null) {
      if (attendanceListModel.downloadUrl != null) {
        CommonFileDownloader.downloadAndOpen(
          urls: attendanceListModel.downloadUrl ?? '',
          context: context,
        );
      }
    }
    update();
  }

  void onWeekSelected(int week) {
    selectedWeek.value = week;
    selectedDate.value = null;
    init(siteId.value);
  }

  void onDaysSelected(String day) {
    selectedDate.value = day;
    init(siteId.value);
    dateWiseAttendance(siteId.value, "${selectedDate.value}");
  }

  void onMonthSelected(int year, int month) {
    selectedYear.value = year;
    selectedMonth.value = month;
    updateMonthText();
    selectedWeek.value = null;
    selectedDate.value = null;
    totalWeeks.value = ConstantData.getWeeksInMonth(year, month);
    init(siteId.value);
  }

  void updateMonthText() {
    selectedMonthText.value =
        "${monthNames[selectedMonth.value - 1]}-${selectedYear.value}";
  }

  attendanceAddWages(String date, String type) async {
    attendanceSave.value = true;
    DateTime dateTime = DateFormat("dd-MM-yyyy").parse(date);
    String formattedDate = DateFormat("yyyy-MM-dd").format(dateTime);

    Map<String, dynamic> postAttendanceData = {
      "site_id": siteId.value,
      "date": formattedDate,
      // Traditional keys
      "count_mason": masonCountController.text,
      "count_helper": helperCountController.text,
      "count_fitter": fitterCountController.text,
      "count_centring_helper": centringHelperCountController.text,
      "count_Centring_Helper": centringHelperCountController.text,
      // Direct keys (matching GET response)
      "mason": masonCountController.text,
      "helper": helperCountController.text,
      "fitter": fitterCountController.text,
      "centring_helper": centringHelperCountController.text,
    };

    Map<String, dynamic> postWagesData = {
      "site_id": siteId.value,
      "date": formattedDate,
      // Traditional keys
      "amount_mason": masonAmountController.text,
      "amount_helper": helperAmountController.text,
      "amount_fitter": fitterAmountController.text,
      "amount_centring_helper": centringHelperAmountController.text,
      "amount_Centring_Helper": centringHelperAmountController.text,
      // Wage-suffixed keys (matching GET response)
      "mason_wage": masonAmountController.text,
      "helper_wage": helperAmountController.text,
      "fitter_wage": fitterAmountController.text,
      "centring_helper_wage": centringHelperAmountController.text,
    };

    Map<String, dynamic> editWagesAndAttendance = {
      ...postAttendanceData,
      ...postWagesData,
    };

    var sendOutput = type == "1"
        ? postWagesData
        : type == "2"
            ? postAttendanceData
            : editWagesAndAttendance;

    if (type == "3") {
      // Direct update-attendance-wages is often unreliable on the backend, 
      // so we hit both specific endpoints to ensure data is saved.
      CommonSuccessResponseModel? res1 = await ApiData().addWagesApi(postWagesData, "1");
      CommonSuccessResponseModel? res2 = await ApiData().addWagesApi(postAttendanceData, "2");
      
      if (res1 != null && res2 != null) {
        showToastMessage(res2.message ?? "Saved Successfully");
      } else if (res1 != null || res2 != null) {
        showToastMessage("Partially Saved. Please check again.");
      } else {
        showToastMessage("Failed to save. Please try again.");
      }
    } else {
      CommonSuccessResponseModel? commonSuccessResponseModel =
          await ApiData().addWagesApi(sendOutput, type);
      showToastMessage(
          commonSuccessResponseModel?.message ?? "Something Went Wrong");
    }

    // Ensure the controller knows which date we just saved to for refresh
    selectedDate.value = formattedDate;

    await init(siteId.value);
    await dateWiseAttendance(siteId.value, formattedDate);

    attendanceSave.value = false;

    Get.back();
    update();
  }

  clear() {
    masonCountController.clear();
    masonAmountController.clear();

    helperCountController.clear();
    helperAmountController.clear();

    fitterCountController.clear();
    fitterAmountController.clear();

    centringHelperCountController.clear();
    centringHelperAmountController.clear();
  }
}
