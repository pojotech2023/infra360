import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/subcontractor_material_orders_model.dart';

class SubcontractorMaterialOrdersController extends GetxController {
  final int subcontractorId;
  RxBool isLoading = true.obs;
  var ordersData = SubcontractorMaterialOrdersData().obs;

  SubcontractorMaterialOrdersController({required this.subcontractorId});

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    isLoading.value = true;
    try {
      SubcontractorMaterialOrdersModel? model = await ApiData().subcontractorOrdersApi(subcontractorId);
      if (model != null && model.data != null) {
        ordersData.value = model.data!;
      }
    } catch (e) {
      print("Error loading subcontractor material orders: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
