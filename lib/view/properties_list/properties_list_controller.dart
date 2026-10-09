import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/property_list_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class PropertiesController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isDeleteLoading = false.obs;
  var propertiesList = <PropertyListData>[].obs;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future<void> init() async {
    isLoading.value = true;
    try {
      PropertyListModel? propertyListModel = await ApiData().propertyList();
      if (propertyListModel != null) {
        propertiesList.value = (propertyListModel.data ?? [])
            .where((p) => p.isInactive != 1)
            .toList();
      }
    } catch (e) {
      print("Error fetching property list: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteProperty(int id) async {
    isDeleteLoading.value = true;
    try {
      CommonSuccessResponseModel? res = await ApiData().deleteProperty(id);
      if (res != null && (res.status ?? true)) {
        showToastMessage(res.message ?? "Property deleted successfully!");
        await init();
        return true;
      } else {
        showToastMessage(res?.message ?? "Failed to delete property");
        return false;
      }
    } catch (e) {
      print("Error deleting property: $e");
      showToastMessage("Error deleting property");
      return false;
    } finally {
      isDeleteLoading.value = false;
    }
  }
}