import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/bricks_model.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/service/api_service.dart';
import 'package:raptor_pro/view/widgets/custom_date_picker.dart';

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
      model = (await ApiData().subcontractorsListApi(
        id: materialDetailsArgs!.itemKey.toString(),
        siteId: materialDetailsArgs!.id.toString(),
        month: "${selectedYear.value}-${selectedMonth.value}",
        week: selectedWeek.value,
      ))!;

      if (model != null) {
        listModel = model.subcontractors ?? [];
        print("✅ Loaded ${listModel.length} subcontractors");
      } else {
        print("⚠️ No data found");
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
    selectedWeek.value = week;
    fetchData();
  }
}
