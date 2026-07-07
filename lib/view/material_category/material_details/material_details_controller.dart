import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/material_list_model.dart';
import 'package:raptor_pro/utils/const_data.dart';

class MaterialDetailsController extends GetxController{

  var data = <String, MaterialItem>{}.obs;

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


  /*init(int sideId)async{

    MaterialResponse? materialModel = await ApiData().materialListApi(sideId);
    final materials = <String, MaterialItem>{};
    if (materialModel != null && materialModel.data!.isNotEmpty) {
      materials.addAll(materialModel.data!);
    }
    for (var key in ConstantData.allMaterialKeys) {
      materials.putIfAbsent(key, () => MaterialItem(units: 0, values: 0));
    }

    data.value = materials;
  }*/


   init(int siteId) async {
    print("🚀 Initializing MaterialDetailsController for site: $siteId");
    currentSiteId = siteId;
    /// 1) Call API
    MaterialResponse? materialModel = await ApiData().materialListApi(
      siteId,
      monthYear: selectedMonthText.value,
      week: selectedWeek.value,
    );

    /// 2) Temporary map using LOWERCASE keys for safe merging
    final Map<String, MaterialItem> temp = {};

    // Load API data safely
    if (materialModel != null && materialModel.data != null) {
      materialModel.data!.forEach((key, value) {
        temp[key.toLowerCase()] = value;
      });
    }

    /// 3) Add missing required keys (bricks, sand, cement, RMC, gravel)
    for (var key in ConstantData.allMaterialKeys) {
      temp.putIfAbsent(key.toLowerCase(), () => MaterialItem(units: 0, values: 0));
    }

    /// 4) Rebuild final map using original casing (RMC stays uppercase)
    final Map<String, MaterialItem> finalMaterials = {};

    for (var key in ConstantData.allMaterialKeys) {
      finalMaterials[key] = temp[key.toLowerCase()]!;
    }


    data.value = finalMaterials;

  }

}

