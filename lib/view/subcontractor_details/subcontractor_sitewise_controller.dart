import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/subcontractor_list_model.dart';
import 'package:raptor_pro/utils/const_data.dart';

import '../../model/my_subcontractor_list_model.dart';
import '../../utils/res/images.dart';
import 'package:flutter/material.dart';
import 'package:raptor_pro/service/api_service.dart';

class SubcontractorController extends GetxController {
  // Observable list of subcontractor items (title, image, amount)
  var subcontractors = <SubcontractorItem>[].obs;

  // Loading indicator
  var isLoading = false.obs;

  RxnInt selectedWeek = RxnInt();
  RxString selectedMonthText = ''.obs;
  RxString displayMonthText = ''.obs;
  RxInt selectedYear = DateTime.now().year.obs;
  RxInt selectedMonth = DateTime.now().month.obs;
  RxInt totalWeeks = 1.obs;
  int? currentSiteId;

  final List<String> monthNames = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  @override
  void onInit() {
    updateMonthText();
    totalWeeks.value = ConstantData.getWeeksInMonth(selectedYear.value, selectedMonth.value);
    super.onInit();
  }

  void onWeekSelected(int week) {
    selectedWeek.value = week;
    if (currentSiteId != null) {
      init(currentSiteId!);
    }
  }

  void onMonthSelected(int year, int month) {
    selectedYear.value = year;
    selectedMonth.value = month;
    updateMonthText();
    selectedWeek.value = null; // Reset week on month change
    totalWeeks.value = ConstantData.getWeeksInMonth(year, month);
    if (currentSiteId != null) {
      init(currentSiteId!);
    }
  }

  void updateMonthText() {
    final mm = selectedMonth.value.toString().padLeft(2, '0');
    selectedMonthText.value = "${selectedYear.value}-$mm";
    displayMonthText.value = "${monthNames[selectedMonth.value - 1]}-${selectedYear.value}";
  }


  Future<void> init(int siteId) async {
    try {
      currentSiteId = siteId;
      isLoading(true);
      subcontractors.clear();

      // Call API with month and week
      SubcontractorResponse? response =
      await ApiData().subcontractorListApi(
        siteId,
        monthYear: selectedMonthText.value,
        week: selectedWeek.value,
      );

      // API data map (key → SubcontractorData)
      final apiData = response?.data ?? {};

      // First, add all dynamic types returned by API
      final dynamicTypes = response?.subcontractorTypes ?? [];
      final addedDynamicTitles = <String>{};
      for (var type in dynamicTypes) {
        final normalizedKey = type.name.toLowerCase();
        final totalAmount = apiData[normalizedKey]?.totalAmounts ?? 0;
        
        subcontractors.add(SubcontractorItem(
          id: type.id,
          title: type.name,
          image: Images.material, // fallback for dynamic
          networkImageUrl: type.imageUrl.isNotEmpty ? type.imageUrl : null,
          totalAmount: totalAmount,
        ));
        addedDynamicTitles.add(normalizedKey);
      }

      // Loop through static list (ensures consistent order for hardcoded ones)
      for (var key in ConstantData.allSubcontractorKeys) {
        final normalizedKey = key.toLowerCase();
        if (addedDynamicTitles.contains(normalizedKey)) continue; // skip if already added from dynamic

        final imagePath =
            ConstantData.allSubcontractorImages[key] ?? Images.material;

        final totalAmount = apiData[normalizedKey]?.totalAmounts ?? 0;

        subcontractors.add(SubcontractorItem(
          id: null,
          title: key,
          image: imagePath,
          totalAmount: totalAmount,
        ));
      }
    } catch (e) {
      print("Error loading subcontractor data: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteSubcontractorType(int id) async {
    isLoading(true);
    try {
      final res = await ApiData().deleteSubcontractorTypeApi(id);
      if (res != null && res.status == true) {
        Get.snackbar('Success', 'Subcontractor type deleted successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        if (currentSiteId != null) init(currentSiteId!);
      } else {
        Get.snackbar('Error', 'Failed to delete Subcontractor type',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }
}

/// UI-ready data model
class SubcontractorItem {
  final int? id;
  final String title;
  final String image;
  final String? networkImageUrl;
  final num totalAmount;

  SubcontractorItem({
    this.id,
    required this.title,
    required this.image,
    this.networkImageUrl,
    required this.totalAmount,
  });
}
