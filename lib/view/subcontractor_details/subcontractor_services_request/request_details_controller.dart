import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/view/widgets/custom_date_picker.dart';
import 'package:raptor_pro/utils/file_download.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

import '../../../model/subcontractor_amount_model.dart';

class RequestDetailsController extends GetxController {
  RxnInt selectedWeek = RxnInt();
  RxString selectedMonthText = ''.obs;
  RxInt selectedYear = DateTime.now().year.obs;
  RxInt selectedMonth = DateTime.now().month.obs;
  List<Subcontractors> listModel = List<Subcontractors>.empty(growable: true);
  SubcontractorAmountModel model = SubcontractorAmountModel();

  final SubcontracorDetailsArgs? materialDetailsArgs;

  RequestDetailsController({this.materialDetailsArgs});

  @override
  void onInit() {
    updateMonthText();
    fetchData();
    super.onInit();
  }

  void updateMonthText() {
    selectedMonthText.value =
        "${monthNames[selectedMonth.value - 1]}-${selectedYear.value}";
  }

  Future<void> fetchData() async {
    try {
      final result = await ApiData().subcontractorsListApi(
        id: materialDetailsArgs!.itemKey.toString().toLowerCase(),
        siteId: materialDetailsArgs!.id.toString(),
        month: "${selectedYear.value}-${selectedMonth.value.toString().padLeft(2, '0')}",
        week: selectedWeek.value,
      );

      if (result != null) {
        model = result;
        listModel = model.subcontractors ?? [];
        print("✅ Loaded ${listModel.length} subcontractor services");
      } else {
        print("⚠️ No data found");
        model = SubcontractorAmountModel();
        listModel.clear();
      }
    } catch (e) {
      print("🚨 Exception while fetching data: $e");
    }
    update();
  }

  void onMonthSelected(int year, int month) {
    selectedYear.value = year;
    selectedMonth.value = month;
    updateMonthText();
    fetchData();
  }

  void onWeekSelected(int week) {
    if (selectedWeek.value == week) {
      selectedWeek.value = null;
    } else {
      selectedWeek.value = week;
    }
    fetchData();
  }

  Future<void> deleteService(int serviceId) async {
    final res = await ApiData().deleteSubcontractorServiceApi(serviceId);
    if (res != null && res.status == true) {
      showToastMessage(res.message ?? "Deleted successfully");
    } else {
      showToastMessage("Failed to delete. Please try again.");
    }
    await fetchData();
  }

  Future<void> updateService(int serviceId, Map<String, dynamic> data) async {
    final res = await ApiData().updateSubcontractorServiceApi(serviceId, data);
    if (res != null) {
      showToastMessage(res.message ?? "Updated successfully");
      await fetchData();
    } else {
      showToastMessage("Failed to update. Please try again.");
    }
  }

  Future<void> excelDownload(BuildContext context, {required String fromDate, required String toDate}) async {
    if (materialDetailsArgs == null) return;

    final String siteId = materialDetailsArgs!.id.toString();
    final String itemKey = materialDetailsArgs!.itemKey.toString().toLowerCase();
    final String month = "${selectedYear.value}-${selectedMonth.value.toString().padLeft(2, '0')}";

    final res = await ApiData().subcontractorExportApi(siteId, month);
    if (res != null && res.downloadUrl != null) {
      CommonFileDownloader.downloadAndOpen(
        urls: res.downloadUrl ?? "",
        context: context,
        fileName: "${itemKey}_report.xlsx",
      );
    } else {
      showToastMessage("Failed to generate export URL.");
    }
  }
}
