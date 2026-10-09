import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
  AttendanceListModel? cachedFullMonthData;
  final Map<String, Map<String, dynamic>> datePhotoLookup = {};

  RxnInt totalWages = RxnInt();
  RxInt totalWorkers = 0.obs;

  RxBool attendanceSave = false.obs;

  RxnString checkInTime = RxnString();
  RxnString checkOutTime = RxnString();
  Rxn<File> checkInImage = Rxn<File>();
  Rxn<File> checkOutImage = Rxn<File>();
  RxnString checkInImageUrl = RxnString();
  RxnString checkOutImageUrl = RxnString();

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
    
    cachedFullMonthData = attendanceListModel;
    _buildDatePhotoLookup(attendanceListModel);

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
          final String date = dayData['date'] ?? '';
          final dayPhotosForDate = _resolveDayPhotos(
            date,
            attendanceListModel.dayPhotos?[date],
          );
          allMapped.addAll(convertDataToAttendances(dayData, id, dayPhotosForDate));
        }
        print("📊 Mapped ${allMapped.length} records from grouped_by_date");

        // Inject real IDs from attendances array
        final Map<String, int> idLookup = {};
        if (attendanceListModel.attendances != null) {
          for (var rec in attendanceListModel.attendances!) {
            if (rec.id != null && rec.date != null && rec.category != null) {
              final k = "${rec.date}_${rec.category?.toLowerCase()}";
              if (!idLookup.containsKey(k) || idLookup[k]! < rec.id!) {
                idLookup[k] = rec.id!;
              }
            }
          }
        }

        for (var item in allMapped) {
          if (item.id == null && item.date != null && item.category != null) {
            final lookupKey = "${item.date}_${item.category?.toLowerCase()}";
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

        _applyDatePhotosToRecords(filtered);

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

        _applyDatePhotosToRecords(filtered);

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
          final dayPhotosForDate = _resolveDayPhotos(
            d.date ?? '',
            model.dayPhotos?[d.date] ?? cachedFullMonthData?.dayPhotos?[d.date],
          );
          converted.addAll(convertDataToAttendances(d.toJson(), id, dayPhotosForDate));
        }
      } else if (model.data != null) {
        final dayPhotosForDate = _resolveDayPhotos(
          model.data!.date ?? '',
          model.dayPhotos?[model.data!.date] ?? cachedFullMonthData?.dayPhotos?[model.data!.date],
        );
        converted.addAll(convertDataToAttendances(model.data!.toJson(), id, dayPhotosForDate));
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
        final dayPhotosForDate = _resolveDayPhotos(
          model.data!.date ?? '',
          model.dayPhotos?[model.data!.date] ?? cachedFullMonthData?.dayPhotos?[model.data!.date],
        );
        final converted = convertDataToAttendances(model.data!.toJson(), id, dayPhotosForDate);
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

  void _purgeDateCache(String date) {
    if (date.isEmpty) return;
    datePhotoLookup.remove(date);
    cachedFullMonthData?.dayPhotos?.remove(date);
    if (cachedFullMonthData?.groupedByDate != null) {
      cachedFullMonthData!.groupedByDate!.removeWhere(
        (day) => day['date']?.toString() == date,
      );
    }
    attendanceList.removeWhere((item) => item.date == date);
  }

  void _buildDatePhotoLookup(AttendanceListModel? model) {
    datePhotoLookup.clear();
    if (model == null) return;

    void merge(String? date, Map<String, dynamic> info, {bool overwrite = true}) {
      if (date == null || date.isEmpty) return;
      final existing = datePhotoLookup.putIfAbsent(date, () => <String, dynamic>{});
      for (final entry in info.entries) {
        final value = entry.value;
        if (value == null || value.toString().trim().isEmpty) continue;
        if (!overwrite && existing.containsKey(entry.key)) continue;
        existing[entry.key] = value;
      }
    }

    // Lowest priority: per-category attendances (fallback only).
    for (final day in model.attendances ?? <Attendances>[]) {
      merge(day.date?.toString(), {
        'check_in_time': day.time,
        'check_in_photo': day.imageUrl,
        'check_out_time': day.checkOutTime,
        'check_out_photo': day.checkOutPhoto,
      }, overwrite: false);
    }

    model.dayPhotos?.forEach((date, value) {
      if (value is Map) {
        merge(date, Map<String, dynamic>.from(value));
      }
    });

    // Highest priority: grouped_by_date is authoritative for day-level check-in/out.
    for (final day in model.groupedByDate ?? <Map<String, dynamic>>[]) {
      merge(day['date']?.toString(), {
        'check_in_time': day['check_in_time'] ?? day['time'],
        'check_in_photo': day['check_in_photo'] ?? day['image_url'],
        'check_out_time': day['check_out_time'] ?? day['out_time'],
        'check_out_photo': day['check_out_photo'] ?? day['out_image_url'],
      }, overwrite: true);
    }

    // If backend copied check-in time to check-out without a real checkout, discard it.
    datePhotoLookup.forEach((date, data) {
      if (data['check_in_time'] != null && data['check_out_time'] == data['check_in_time']) {
        data.remove('check_out_time');
        data.remove('check_out_photo');
      }
    });
  }

  Map<String, dynamic>? _resolveDayPhotos(String date, dynamic dayPhotosForDate) {
    final merged = <String, dynamic>{};

    void addFrom(dynamic source) {
      if (source is! Map) return;
      for (final entry in Map<String, dynamic>.from(source).entries) {
        final value = entry.value;
        if (value != null && value.toString().trim().isNotEmpty) {
          merged[entry.key] = value;
        }
      }
    }

    addFrom(datePhotoLookup[date]);
    addFrom(dayPhotosForDate);
    return merged.isEmpty ? null : merged;
  }

  String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  String? _resolveCheckOutTime(Map<String, dynamic> data, String date, Map<String, dynamic>? dayPhotosForDate) {
    final hasExplicitField = data.containsKey('check_out_time') || data.containsKey('out_time');
    if (hasExplicitField) {
      return _firstNonEmpty([data['check_out_time'], data['out_time']]);
    }
    return _firstNonEmpty([
      dayPhotosForDate?['check_out_time'],
      datePhotoLookup[date]?['check_out_time'],
    ]);
  }

  String? _resolveCheckOutPhoto(Map<String, dynamic> data, String date, Map<String, dynamic>? dayPhotosForDate) {
    final hasExplicitField = data.containsKey('check_out_photo') || data.containsKey('out_image_url');
    if (hasExplicitField) {
      return _firstNonEmpty([data['check_out_photo'], data['out_image_url']]);
    }
    return _firstNonEmpty([
      dayPhotosForDate?['check_out_photo'],
      datePhotoLookup[date]?['check_out_photo'],
    ]);
  }

  void _applyDatePhotosToRecords(List<Attendances> records) {
    for (final record in records) {
      final photos = datePhotoLookup[record.date ?? ''];
      if (photos == null) continue;

      // Only backfill check-in fields. Check-out values are set in
      // convertDataToAttendances from the authoritative grouped_by_date payload
      // so stale cached checkout times are not re-applied after delete/re-entry.
      record.time ??= photos['check_in_time']?.toString();
      record.imageUrl ??= photos['check_in_photo']?.toString();
    }
  }

  List<Attendances> convertDataToAttendances(Map<String, dynamic> data, int siteId, [Map<String, dynamic>? dayPhotosForDate]) {
    final String date = data['date'] ?? '';
    final String? checkInTime = _firstNonEmpty([
      data['check_in_time'],
      data['time'],
      dayPhotosForDate?['check_in_time'],
      datePhotoLookup[date]?['check_in_time'],
    ]);
    final String? checkInPhoto = _firstNonEmpty([
      data['check_in_photo'],
      data['image_url'],
      dayPhotosForDate?['check_in_photo'],
      datePhotoLookup[date]?['check_in_photo'],
    ]);
    String? checkOutTime = _resolveCheckOutTime(data, date, dayPhotosForDate);
    String? checkOutPhoto = _resolveCheckOutPhoto(data, date, dayPhotosForDate);

    // If backend automatically copied Check-In time to Check-Out, discard it.
    if (checkInTime != null && checkOutTime == checkInTime) {
      checkOutTime = null;
      checkOutPhoto = null;
    }

    // Discard check-out times that are before check-in.
    if (checkInTime != null && checkOutTime != null) {
      try {
        final format = DateFormat("HH:mm:ss");
        final inTime = format.parse(checkInTime);
        final outTime = format.parse(checkOutTime);
        if (outTime.isBefore(inTime)) {
          checkOutTime = null;
          checkOutPhoto = null;
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }
    
    print("DEBUG_API_MAPPING_EXTREME: date=$date");
    print("DEBUG_API_MAPPING_EXTREME: data keys = ${data.keys.toList()}");
    print("DEBUG_API_MAPPING_EXTREME: data['check_in_photo'] = ${data['check_in_photo']}");
    print("DEBUG_API_MAPPING_EXTREME: dayPhotosForDate = $dayPhotosForDate");
    print("DEBUG_API_MAPPING_EXTREME: check_in_photo = $checkInPhoto");
    
    final List<Attendances> list = [];
    final reservedKeys = {
      'date', 'total', 'check_in_time', 'check_in_photo', 'check_out_time', 'check_out_photo',
      'time', 'image_url', 'out_time', 'out_image_url', 'id', 'site_id', 'created_at',
      'updated_at', 'created_by', 'updated_by'
    };

    final Map<String, String> categoryLabels = {
      'mason': 'Mason',
      'helper': 'Helper',
      'fitter': 'Fitter',
      'centring_helper': 'Centring Helper',
    };

    for (var key in data.keys) {
      if (reservedKeys.contains(key) || key.endsWith('_wage') || key.endsWith('_id')) {
        continue;
      }
      
      final label = categoryLabels[key] ?? (key.isNotEmpty ? key[0].toUpperCase() + key.substring(1).replaceAll('_', ' ') : key);
      final count = data[key] ?? 0;
      final rawWage = data['${key}_wage'];
      final amount = double.tryParse(rawWage?.toString() ?? '0') ?? 0.0;
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
          time: checkInTime,
          imageUrl: checkInPhoto,
          checkOutTime: checkOutTime,
          checkOutPhoto: checkOutPhoto,
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

  attendanceAddWages(String date, String type, {String? attendanceRowsJson}) async {
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

    if (attendanceRowsJson != null && attendanceRowsJson.isNotEmpty) {
      sendOutput['attendance_rows'] = attendanceRowsJson;
    }

    if (checkInTime.value != null && checkInTime.value!.isNotEmpty) {
      sendOutput['check_in_time'] = checkInTime.value;
    }
    if (checkOutTime.value != null && checkOutTime.value!.isNotEmpty) {
      sendOutput['check_out_time'] = checkOutTime.value;
    }

    CommonSuccessResponseModel? commonSuccessResponseModel =
        await ApiData().addWagesApi(
          sendOutput, 
          type,
          checkInFile: checkInImage.value,
          checkOutFile: checkOutImage.value,
        );
    
    if (commonSuccessResponseModel != null) {
      showToastMessage(commonSuccessResponseModel.message ?? "Updated successfully");
      
      // ✅ Close bottom sheet immediately after data is saved
      Get.back();

      // ✅ Clear old state completely
      attendanceList.clear();
      totalWages.value = 0;
      totalWorkers.value = 0;
      
      // ✅ Reset to full-month view and fetch fresh data
      selectedDate.value = null;
      init(siteId.value); // Fetch in background without blocking
      
      // ✅ Force complete UI rebuild
      update();
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

    checkInTime.value = null;
    checkOutTime.value = null;
    checkInImage.value = null;
    checkOutImage.value = null;
    checkInImageUrl.value = null;
    checkOutImageUrl.value = null;
  }

  Future<void> pickTime(BuildContext context, bool isCheckIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final formattedTime = picked.format(context);
      if (isCheckIn) {
        checkInTime.value = formattedTime;
      } else {
        checkOutTime.value = formattedTime;
      }
    }
  }

  Future<void> pickImage(bool isCheckIn, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 70);
    if (image != null) {
      final file = File(image.path);
      print("📸 Image Picked -> Path: ${file.path}");
      file.length().then((size) => print("📸 Image Picked -> Size: $size bytes"));
      print("📸 Image Picked -> Ext: ${file.path.split('.').last}");

      if (isCheckIn) {
        checkInImage.value = file;
      } else {
        checkOutImage.value = file;
      }
    }
  }

  /// Deletes all attendance and wages for a date, then refreshes from the API.
  Future<bool> deleteAttendanceForDate(String isoDate) async {
    if (siteId.value == null || isoDate.isEmpty) return false;

    attendanceSave.value = true;
    update();

    _purgeDateCache(isoDate);

    bool hasError = false;
    print("🚀 [DELETE BY DATE] site=${siteId.value}, date=$isoDate");

    final attendanceRes = await ApiData().deleteAttendanceByDateApi(siteId.value!, isoDate);
    if (attendanceRes == null) {
      print("❌ [DELETE BY DATE] Attendance delete failed");
      hasError = true;
    }

    final wagesRes = await ApiData().deleteWagesRowApi({
      "site_id": siteId.value,
      "date": isoDate,
    });
    if (wagesRes == null) {
      print("❌ [DELETE BY DATE] Wages delete failed");
      hasError = true;
    }

    selectedDate.value = null;
    await init(siteId.value);

    if (hasError) {
      showToastMessage("Failed to delete attendance for $isoDate.");
    }

    attendanceSave.value = false;
    update();
    return !hasError;
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

