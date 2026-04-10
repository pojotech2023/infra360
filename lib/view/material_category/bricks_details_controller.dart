import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/bricks_model.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/service/api_service.dart';
import 'package:raptor_pro/view/widgets/custom_date_picker.dart';

class BricksDetailsController extends GetxController {
  RxList<BricksList> getBricksLists = <BricksList>[].obs;
  RxnInt selectedWeek = RxnInt();
  RxString selectedMonthText = ''.obs;
  RxInt selectedYear = DateTime.now().year.obs;
  RxInt selectedMonth = DateTime.now().month.obs;
  Rxn<BricksModel> ?bricksModel = Rxn<BricksModel>();

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
}
