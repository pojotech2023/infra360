import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/vendor_material_orders_model.dart';

class VendorMaterialOrdersController extends GetxController {
  final int vendorId;
  VendorMaterialOrdersController({required this.vendorId});

  RxBool isLoading = true.obs;
  Rx<VendorMaterialOrdersData?> ordersData = Rx<VendorMaterialOrdersData?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  void fetchData() async {
    isLoading.value = true;
    try {
      final res = await ApiData().vendorMaterialOrdersApi(vendorId);
      if (res != null && res.data != null) {
        ordersData.value = res.data;
      } else {
        Get.snackbar("Error", "Failed to fetch material orders");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
