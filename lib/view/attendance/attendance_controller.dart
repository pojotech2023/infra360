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
  RxString selectedTab = 'Full Month'.obs;  // Options: 'Full Month', 'Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5'
  RxnInt selectedWeek = RxnInt();
  RxString selectedMonthText = ''.obs;  // API format: YYYY-MM  e.g. "2026-07"
  RxString displayMonthText = ''.obs;   // UI label: e.g. "Jul-2026"
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
    if (selectedTab.value == 'Full Month') {
      // Load full month data using /api/attendance/{siteId} with month parameter only
      await loadFullMonthAttendance(id);
    } else {
      // Load week data using /api/attendance/sites/{siteId}/attendance-by-date
      await loadWeekAttendance(id);
    }
    
    // ✅ Force UI update after data refresh
    update();
  }

  /// Load full month attendance using /api/attendance/{siteId}
  Future<void> loadFullMonthAttendance(int? id) async {
    AttendanceListModel? attendanceListModel = await ApiData().attendanceList(
        id!, selectedMonthText.value, null, null);

    if (attendanceListModel != null) {
      print("📊 Full Month Attendance API: TotalWages=${attendanceListModel.totalWages}, "
          "records=${attendanceListModel.attendances?.length}");
      print("📊 grouped_by_date exists: ${attendanceListModel.groupedByDate != null}, "
          "length: ${attendanceListModel.groupedByDate?.length ?? 0}");
      print("📊 categoryWages exists: ${attendanceListModel.categoryWages != null}");

      totalWages.value = attendanceListModel.totalWages ?? 0;

      if (attendanceListModel.groupedByDate != null &&
          attendanceListModel.groupedByDate!.isNotEmpty) {
        print("📊 Using grouped_by_date branch");
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        List<Attendances> allMapped = [];
        for (var dayData in attendanceListModel.groupedByDate!) {
          allMapped.addAll(convertDataToAttendances(dayData, id));
        }
        print("📊 Mapped ${allMapped.length} records from grouped_by_date");

        // Inject real IDs from attendances array
        final Map<String, int> idLookup = {};
        if (attendanceListModel.attendances != null) {
          for (var rec in attendanceListModel.attendances!) {
            if (rec.id != null && rec.date != null && rec.category != null) {
              final k = "${rec.date}_${rec.category}";
              if (!idLookup.containsKey(k) || idLookup[k]! < rec.id!) {
                idLookup[k] = rec.id!;
              }
            }
          }
        }

        for (var item in allMapped) {
          if (item.id == null && item.date != null && item.category != null) {
            final lookupKey = "${item.date}_${item.category}";
            if (idLookup.containsKey(lookupKey)) {
              item.id = idLookup[lookupKey];
            }
          }
        }

        // Filter by selected month/year only - don't filter by today's date for Full Month view
        var filtered = allMapped.where((item) {
          if (item.date == null) return true;
          final parsed = DateTime.tryParse(item.date!) ?? DateTime(2000);
          return parsed.year == selectedYear.value && parsed.month == selectedMonth.value;
        }).toList();
        print("📊 After date filtering: ${filtered.length} records");

        filtered.sort((a, b) {
          final da = DateTime.tryParse(a.date ?? '') ?? DateTime(2000);
          final db = DateTime.tryParse(b.date ?? '') ?? DateTime(2000);
          return da.compareTo(db);
        });

        final Map<String, Attendances> uniqueMap = {};
        for (var item in filtered) {
          final key = "${item.date}_${item.category}";
          if (item.id != null) {
            if (!uniqueMap.containsKey(key) || (uniqueMap[key]?.id ?? 0) < item.id!) {
              uniqueMap[key] = item;
            }
          } else {
            uniqueMap.putIfAbsent(key, () => item);
          }
        }
        final deduplicated = uniqueMap.values.toList();
        print("📊 After deduplication: ${deduplicated.length} records");

        attendanceList.assignAll(deduplicated);
        print("📊 Full Month Showing ${deduplicated.length} records");

        calculateTotalWages();
      } else if (attendanceListModel.attendances != null &&
          attendanceListModel.attendances!.isNotEmpty) {
        print("📊 Using attendances fallback branch");
        List<Attendances> allRecords = attendanceListModel.attendances!;
        print("📊 Raw attendances count: ${allRecords.length}");

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Filter by selected month/year only - don't filter by today's date for Full Month view
        var filtered = allRecords.where((item) {
          if (item.date == null) return true;
          final parsed = DateTime.tryParse(item.date!) ?? DateTime(2000);
          return parsed.year == selectedYear.value && parsed.month == selectedMonth.value;
        }).toList();
        print("📊 After date filtering: ${filtered.length} records");

        filtered.sort((a, b) {
          final da = DateTime.tryParse(a.date ?? '') ?? DateTime(2000);
          final db = DateTime.tryParse(b.date ?? '') ?? DateTime(2000);
          return da.compareTo(db);
        });

        final Map<String, Attendances> uniqueMap = {};
        for (var item in filtered) {
          final key = "${item.date}_${item.category}";
          if (item.id != null) {
            if (!uniqueMap.containsKey(key) || (uniqueMap[key]?.id ?? 0) < item.id!) {
              uniqueMap[key] = item;
            }
          } else {
            uniqueMap.putIfAbsent(key, () => item);
          }
        }
        final deduplicated = uniqueMap.values.toList();
        print("📊 After deduplication: ${deduplicated.length} records");

        attendanceList.assignAll(deduplicated);
        print("📊 Full Month (attendances fallback) Showing ${deduplicated.length} records");

        calculateTotalWages();
      } else if (attendanceListModel.categoryWages != null) {
        print("📊 Using categoryWages fallback branch");
        final cw = attendanceListModel.categoryWages!;
        final wageRates = attendanceListModel.wage;
        final now = DateTime.now();
        final mm = selectedMonth.value.toString().padLeft(2, '0');
        final dateStr = "${selectedYear.value}-$mm-01";

        List<Attendances> summaryList = [];
        void addRow(String cat, int? count, String? wageStr) {
          if (count != null && count > 0) {
            final amt = double.tryParse(wageStr ?? '0') ?? 0.0;
            summaryList.add(Attendances(category: cat, count: count, amount: amt, date: dateStr));
          }
        }
        addRow("Mason", cw.mason, wageRates?.mason);
        addRow("Helper", cw.helper, wageRates?.helper);
        addRow("Fitter", cw.fitter, wageRates?.fitter);
        addRow("Centring Helper", cw.centringHelper, wageRates?.centringHelper);

        attendanceList.assignAll(summaryList);
        print("📊 Full Month Fallback to categoryWages: ${summaryList.length} categories");
        calculateTotalWages();
      } else {
        print("📊 No data available - clearing attendance list");
        attendanceList.clear();
        totalWages.value = 0;
        totalWorkers.value = 0;
      }
    } else {
      print("📊 API response was null - clearing attendance list");
      attendanceList.clear();
      totalWages.value = 0;
      totalWorkers.value = 0;
    }
  }

  /// Load week attendance using /api/attendance/sites/{siteId}/attendance-by-date
  Future<void> loadWeekAttendance(int? id) async {
    if (selectedWeek.value == null) {
      attendanceList.clear();
      totalWages.value = 0;
      totalWorkers.value = 0;
      return;
    }

    final weekNum = selectedWeek.value!;
    final startDay = (weekNum - 1) * 7 + 1;
    final daysInMonth = DateTime(selectedYear.value, selectedMonth.value + 1, 0).day;
    final endDay = startDay + 6 > daysInMonth ? daysInMonth : startDay + 6;

    final mm = selectedMonth.value.toString().padLeft(2, '0');
    final startDate = "${selectedYear.value}-$mm-${startDay.toString().padLeft(2, '0')}";
    final endDate = "${selectedYear.value}-$mm-${endDay.toString().padLeft(2, '0')}";

    print("📊 Week $weekNum Attendance: $startDate to $endDate");

    // Call attendance-by-date API with date range
    AttendanceDatewiseModel? model = await ApiData().weekWiseAttendanceApi(id!, startDate, endDate);

    if (model != null && (model.data != null || model.dataList != null)) {
      print("📊 Week Attendance API Response received");

      List<Attendances> converted = [];
      if (model.dataList != null) {
        for (var d in model.dataList!) {
          converted.addAll(convertDataToAttendances(d.toJson(), id));
        }
      } else if (model.data != null) {
        converted.addAll(convertDataToAttendances(model.data!.toJson(), id));
      }
      
      // Sort ascending
      converted.sort((a, b) {
        final da = DateTime.tryParse(a.date ?? '') ?? DateTime(2000);
        final db = DateTime.tryParse(b.date ?? '') ?? DateTime(2000);
        return da.compareTo(db);
      });
      
      // Deduplicate by (date, category)
      final Map<String, Attendances> uniqueMap = {};
      for (var item in converted) {
        final key = "${item.date}_${item.category}";
        if (item.id != null) {
          if (!uniqueMap.containsKey(key) || (uniqueMap[key]?.id ?? 0) < item.id!) {
            uniqueMap[key] = item;
          }
        } else {
          uniqueMap.putIfAbsent(key, () => item);
        }
      }
      attendanceList.value = uniqueMap.values.toList();
      
      print("📊 Week $weekNum Showing ${attendanceList.length} records");
      calculateTotalWages();
    } else {
      attendanceList.clear();
      totalWages.value = 0;
      totalWorkers.value = 0;
      print("📊 Week $weekNum No data received");
    }
  }

  /// Generates week day buttons locally so Week 1 = days 1-7 of the month,
  /// Week 2 = days 8-14, etc. — matching the web admin's week definition.
  void _generateWeekDays() {
    if (selectedWeek.value == null) {
      weekDaysList.clear();
      return;
    }

    final weekNum    = selectedWeek.value!;
    final startDay   = (weekNum - 1) * 7 + 1;
    final daysInMonth = DateTime(selectedYear.value, selectedMonth.value + 1, 0).day;
    final endDay     = startDay + 6 > daysInMonth ? daysInMonth : startDay + 6;

    const dayShortNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<WeekDays> days = [];

    for (int d = startDay; d <= endDay; d++) {
      final date = DateTime(selectedYear.value, selectedMonth.value, d);
      final dayName = dayShortNames[date.weekday - 1];
      final mm = selectedMonth.value.toString().padLeft(2, '0');
      final dd = d.toString().padLeft(2, '0');
      days.add(WeekDays(
        label: '$dayName $dd',
        value: '${selectedYear.value}-$mm-$dd',
      ));
    }
    weekDaysList.assignAll(days);
  }

  void calculateTotalWages() {
    double wages = 0;
    int workers = 0;
    for (var item in attendanceList) {
      final amt = item.amount ?? 0;
      final cnt = item.count ?? 0;
      wages += amt * cnt;
      workers += cnt;
    }
    totalWages.value = wages.round();
    totalWorkers.value = workers;
  }

  void onTabSelected(String tab) {
    selectedTab.value = tab;
    selectedDate.value = null;
    
    if (tab == 'Full Month') {
      selectedWeek.value = null;
      weekDaysList.clear();
    } else {
      final weekNum = int.parse(tab.split(' ')[1]);
      selectedWeek.value = weekNum;
      _generateWeekDays();
    }
    
    init(siteId.value);
  }

  void onDaysSelected(String day) {
    print("📅 onDaysSelected called: $day");
    selectedDate.value = day;
    print("📅 selectedDate.value set to: ${selectedDate.value}");
    update();
    init(siteId.value);
    dateWiseAttendance(siteId.value, day);
  }

  void onMonthSelected(int year, int month) {
    selectedYear.value = year;
    selectedMonth.value = month;
    updateMonthText();
    selectedWeek.value = null;
    selectedDate.value = null;
    selectedTab.value = 'Full Month';
    weekDaysList.clear();
    totalWeeks.value = ConstantData.getWeeksInMonth(year, month);
    init(siteId.value);
  }

  void updateMonthText() {
    // API expects YYYY-MM (matches web URL: ?month=2026-07)
    final mm = selectedMonth.value.toString().padLeft(2, '0');
    selectedMonthText.value = "${selectedYear.value}-$mm";
    // UI label stays human-readable
    displayMonthText.value = "${monthNames[selectedMonth.value - 1]}-${selectedYear.value}";
  }

  dateWiseAttendance(int? id, String date) async {
    AttendanceDatewiseModel? model =
        await ApiData().dateWiseattendanceApi(id!, date);

    if (model != null) {
      if (model.data != null) {
        final converted = convertDataToAttendances(model.data!.toJson(), id);
        // Sorted ascending
        converted.sort((a, b) {
          final da = DateTime.tryParse(a.date ?? '') ?? DateTime(2000);
          final db = DateTime.tryParse(b.date ?? '') ?? DateTime(2000);
          return da.compareTo(db);
        });
        
        // ✅ Deduplicate by (date, category) to prevent duplicate UI cards
        final Map<String, Attendances> uniqueMap = {};
        for (var item in converted) {
          final key = "${item.date}_${item.category}";
          if (item.id != null) {
            if (!uniqueMap.containsKey(key) || (uniqueMap[key]?.id ?? 0) < item.id!) {
              uniqueMap[key] = item;
            }
          } else {
            uniqueMap.putIfAbsent(key, () => item);
          }
        }
        attendanceList.value = uniqueMap.values.toList();
      } else {
        attendanceList.clear();
      }
      calculateTotalWages();
    }
  }

  List<Attendances> convertDataToAttendances(Map<String, dynamic> data, int siteId) {
    final String date = data['date'] ?? '';
    final categories = [
      {'key': 'mason',           'label': 'Mason'},
      {'key': 'helper',          'label': 'Helper'},
      {'key': 'fitter',          'label': 'Fitter'},
      {'key': 'centring_helper', 'label': 'Centring Helper'},
    ];
    final List<Attendances> list = [];
    for (var cat in categories) {
      final key   = cat['key']!;
      final label = cat['label']!;
      final count = data[key] ?? 0;
      final rawWage = data['${key}_wage'];
      final amount = double.tryParse(rawWage?.toString() ?? '0') ?? 0.0;
      
      // ✅ Include record even if count is 0, as long as amount > 0 or there's an ID
      final id = data['${key}_id'];
      if (count > 0 || amount > 0 || id != null) {
        print("💰 [$date] $label → count=$count, wage=${rawWage} → amount=$amount, id=$id");
        list.add(Attendances(
          siteId: siteId, 
          category: label,
          count: count, 
          amount: amount, 
          date: date,
          id: id is int ? id : (id is String ? int.tryParse(id) : null),
        ));
      }
    }
    return list;
  }

  attendanceExcelDownload(BuildContext context, {String? fromDate, String? toDate}) async {
    ExcelAttendanceDownloadModel? model = await ApiData().attendanceExportApi(
        siteId.value.toString(),
        selectedMonthText.value,
        selectedWeek.value?.toString() ?? '');
    if (model?.downloadUrl != null) {
      CommonFileDownloader.downloadAndOpen(
          urls: model!.downloadUrl!, context: Get.context ?? context);
    }
    update();
  }

  attendanceAddWages(String date, String type) async {
    attendanceSave.value = true;
    update();
    
    DateTime dateTime = DateFormat("dd-MM-yyyy").parse(date);
    String formattedDate = DateFormat("yyyy-MM-dd").format(dateTime);

    // ✅ Use exact field names expected by backend (uppercase category names)
    Map<String, dynamic> postAttendanceData = {
      "site_id": siteId.value,
      "date": formattedDate,
      "count_Mason": masonCountController.text,
      "count_Helper": helperCountController.text,
      "count_Fitter": fitterCountController.text,
      "count_Centring_Helper": centringHelperCountController.text,
    };

    Map<String, dynamic> postWagesData = {
      "site_id": siteId.value,
      "date": formattedDate,
      "amount_Mason": masonAmountController.text,
      "amount_Helper": helperAmountController.text,
      "amount_Fitter": fitterAmountController.text,
      "amount_Centring_Helper": centringHelperAmountController.text,
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

    CommonSuccessResponseModel? commonSuccessResponseModel =
        await ApiData().addWagesApi(sendOutput, type);
    
    if (commonSuccessResponseModel != null) {
      showToastMessage(commonSuccessResponseModel.message ?? "Updated successfully");
      
      // ✅ Clear old state completely
      attendanceList.clear();
      totalWages.value = 0;
      totalWorkers.value = 0;
      
      // ✅ Reset to full-month view and fetch fresh data
      selectedDate.value = null;
      await init(siteId.value);
      
      // ✅ Force complete UI rebuild
      update();
      
      // ✅ Close bottom sheet after data is refreshed
      Get.back();
    } else {
      showToastMessage("Something Went Wrong");
    }

    attendanceSave.value = false;
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

  /// Deletes attendance by [attendanceId] (individual record ID).
  deleteAttendance(int attendanceId) async {
    attendanceSave.value = true;
    update();

    bool hasError = false;

    print("🚀 [DELETE API] Calling delete API for Attendance ID: $attendanceId");
    
    var res = await ApiData().deleteAttendanceApi(attendanceId);
    
    if (res == null) {
      print("❌ [DELETE API] Failed - Response was null");
      hasError = true;
    } else {
      print("✅ [DELETE API] Success for ID: $attendanceId");
    }

    if (hasError) {
      showToastMessage("Failed to delete record ID $attendanceId.");
    }

    // Do NOT call init() here, because the UI loop will call it after ALL deletes are done.

    attendanceSave.value = false;
    update();
  }
}

