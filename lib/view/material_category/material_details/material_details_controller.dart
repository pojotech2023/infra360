import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/material_list_model.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/service/shared_preference_service.dart';

class MaterialDetailsController extends GetxController{

  void hideDefaultMaterial(String key) {
    if (currentSiteId == null) return;
    final prefsKey = 'hidden_materials_$currentSiteId';
    final hidden = PreferenceUtils.pref.getStringList(prefsKey) ?? [];
    if (!hidden.contains(key.toLowerCase())) {
      hidden.add(key.toLowerCase());
      PreferenceUtils.pref.setStringList(prefsKey, hidden);
    }
  }

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

    /// 2) Temporary map to merge built-in, existing data, and dynamic material_types
    final Map<String, MaterialItem> finalMaterials = {};

    // ── Calculate "All Materials" consolidated totals ──
    int totalUnits = 0;
    int totalValues = 0;
    if (materialModel?.data != null) {
      materialModel!.data!.forEach((k, v) {
        final lk = k.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
        if (lk != 'allmaterials' && lk != 'total') {
          totalUnits += v.units;
          totalValues += v.values;
        }
      });
    }

    if (materialModel?.totalUnits != null && materialModel!.totalUnits! > totalUnits) {
      totalUnits = materialModel!.totalUnits!;
    }
    if (materialModel?.totalValues != null && materialModel!.totalValues! > totalValues) {
      totalValues = materialModel!.totalValues!;
    }

    finalMaterials['All Materials'] = MaterialItem(
      name: 'All Materials',
      slug: 'all',
      units: totalUnits,
      values: totalValues,
    );

    // First, populate all materials from material_types (Dynamic Materials)
    if (materialModel != null && materialModel.materialTypes != null) {
      for (var mType in materialModel.materialTypes!) {
        final key = mType.slug;
        final displayKey = mType.name;
        // Skip if it's all materials
        if (displayKey.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '') == 'allmaterials' ||
            displayKey.toLowerCase() == 'all') {
          continue;
        }
        // Check if there is data for this dynamic material
        final existingItem = materialModel.data?[mType.slug] ??
                             materialModel.data?[key] ??
                             materialModel.data?[mType.name] ??
                             materialModel.data?[mType.name.toLowerCase()];
        
        finalMaterials[displayKey] = MaterialItem(
          id: mType.id,
          name: mType.name,
          slug: mType.slug,
          imageUrl: mType.imageUrl,
          units: existingItem?.units ?? 0,
          values: existingItem?.values ?? 0,
        );
      }
    }

    // Read hidden defaults for this site from Backend
    final prefsKey = 'hidden_materials_$siteId';
    List<String> hiddenDefaults;
    // If backend returns a valid list of hidden materials (even empty), use it and sync local cache
    if (materialModel?.hiddenMaterials != null) {
      hiddenDefaults = materialModel!.hiddenMaterials!;
      PreferenceUtils.pref.setStringList(prefsKey, hiddenDefaults);
    } else {
      // Fallback to local cache ONLY if backend doesn't provide the hiddenMaterials key yet
      hiddenDefaults = PreferenceUtils.pref.getStringList(prefsKey) ?? [];
    }

    // Next, populate standard/built-in materials
    for (var key in ConstantData.allMaterialKeys) {
      final String safeKey = key.toLowerCase();
      final existingItem = materialModel?.data?[key] ??
                           materialModel?.data?[safeKey] ??
                           materialModel?.data?[key.replaceAll(' ', '_').toLowerCase()] ??
                           materialModel?.data?[key.replaceAll(' ', '')] ??
                           materialModel?.data?[key.replaceAll('&', 'and').toLowerCase()] ??
                           materialModel?.data?[key.replaceAll('&', '_').toLowerCase()] ??
                           materialModel?.data?[key.replaceAll('/', '_').toLowerCase()] ??
                           materialModel?.data?[key.replaceAll('/', '').toLowerCase()];

      // Skip if this built-in material was hidden by the user AND has no active data
      if (hiddenDefaults.contains(safeKey) && (existingItem == null || (existingItem.units == 0 && existingItem.values == 0))) {
        continue;
      }

      // Only add if not already added by material_types
      if (!finalMaterials.keys.any((k) => k.toLowerCase() == safeKey)) {
        finalMaterials[key] = existingItem ?? MaterialItem(units: 0, values: 0);
      }
    }

    // Add any remaining keys from data that weren't captured above
    if (materialModel != null && materialModel.data != null) {
      materialModel.data!.forEach((key, value) {
        final String safeKey = key.toLowerCase();
        final String cleanKey = safeKey.replaceAll(RegExp(r'[^a-z]'), '');
        if (cleanKey == 'all' || cleanKey == 'allmaterials') return;

        // Check if already in finalMaterials
        if (!finalMaterials.keys.any((k) => k.toLowerCase() == safeKey)) {
          final String displayKey = key.isEmpty ? key : key[0].toUpperCase() + key.substring(1);
          finalMaterials[displayKey] = value;
        }
      });
    }

    data.value = finalMaterials;

  }

}

