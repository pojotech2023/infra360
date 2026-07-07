import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/bricks_model.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:raptor_pro/utils/file_download.dart';
import 'package:raptor_pro/view/widgets/custom_date_picker.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class BricksDetailsController extends GetxController {
  RxList<BricksList> getBricksLists = <BricksList>[].obs;
  RxnInt selectedWeek = RxnInt();
  RxString selectedMonthText = ''.obs;
  RxInt selectedYear = DateTime.now().year.obs;
  RxInt selectedMonth = DateTime.now().month.obs;
  Rxn<BricksModel> ?bricksModel = Rxn<BricksModel>();
  RxBool isDeleting = false.obs;

  final MaterialDetailsArgs ?materialDetailsArgs;

  BricksDetailsController({this.materialDetailsArgs});

  @override
  void onInit() {
    updateMonthText();
    fetchData();
    super.onInit();
  }

  void updateMonthText() {
    selectedMonthText.value = "${monthNames[selectedMonth.value - 1]}-${selectedYear.value}";
  }

  Future<void> fetchData() async {
    final result = await ApiData().bricksListApi(
      materialDetailsArgs!.id,
      "${selectedYear.value}-${selectedMonth.value.toString().padLeft(2, '0')}",
      selectedWeek.value, materialDetailsArgs!.itemKey
    );
    
    bricksModel?.value = result;
    if (result != null) {
      getBricksLists.assignAll(result.bricks ?? []);
    } else {
      getBricksLists.clear();
    }
    print("📦 MATERIAL DEBUG: Fetched ${getBricksLists.length} records for ${materialDetailsArgs!.itemKey}. TotalUnits=${result?.totalUnits}");
  }

  void onMonthSelected(int year, int month) {
    selectedYear.value = year;
    selectedMonth.value = month;
    updateMonthText();
    fetchData();
  }

  void onWeekSelected(int week) {
    selectedWeek.value = week;
    fetchData();
  }

  Future<void> deleteMaterial(int materialId) async {
    isDeleting.value = true;
    final res = await ApiData().deleteMaterialApi(materialId);
    if (res != null) {
      showToastMessage(res.message ?? "Deleted successfully");
      await fetchData();
    } else {
      showToastMessage("Failed to delete. Please try again.");
    }
    isDeleting.value = false;
  }

  Future<void> updateMaterial(int materialId, Map<String, dynamic> data) async {
    final res = await ApiData().updateMaterialApi(materialId, data);
    if (res != null) {
      showToastMessage(res.message ?? "Updated successfully");
      await fetchData();
    } else {
      showToastMessage("Failed to update. Please try again.");
    }
  }

  Future<void> materialExcelDownload(BuildContext context, {String? fromDate, String? toDate}) async {
    final String siteId = materialDetailsArgs?.id.toString() ?? "";
    final String itemKey = materialDetailsArgs?.itemKey ?? "";
    final String month = "${selectedYear.value}-${selectedMonth.value.toString().padLeft(2, '0')}";

    final res = await ApiData().materialExportApi(siteId, itemKey, month);

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

  Future<void> materialPdfDownload(BuildContext context, int materialId) async {
    final res = await ApiData().materialPdfDownloadApi(materialId);

    if (res != null && res.downloadUrl != null) {
      CommonFileDownloader.downloadAndOpen(
        urls: res.downloadUrl ?? "",
        context: context,
        fileName: "material_${materialId}.pdf",
      );
    } else {
      showToastMessage("Failed to generate PDF URL.");
    }
  }
}
