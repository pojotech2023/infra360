import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/subcontractor_list_model.dart';
import 'package:raptor_pro/utils/const_data.dart';

import '../../model/my_subcontractor_list_model.dart';
import '../../utils/res/images.dart';

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

      // Loop through static list (ensures consistent order)
      for (var key in ConstantData.allSubcontractorKeys) {
        final normalizedKey = key.toLowerCase();
        final imagePath =
            ConstantData.allSubcontractorImages[key] ?? Images.material;

        final totalAmount = apiData[normalizedKey]?.totalAmounts ?? 0;

        subcontractors.add(SubcontractorItem(
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
}

/// UI-ready data model
class SubcontractorItem {
  final String title;
  final String image;
  final num totalAmount;

  SubcontractorItem({
    required this.title,
    required this.image,
    required this.totalAmount,
  });
}
