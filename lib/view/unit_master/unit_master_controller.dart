import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/api_data.dart';
import '../../model/unit_master_model.dart';

class UnitMasterController extends GetxController {
  var isLoading = false.obs;
  var units = <UnitMasterData>[].obs;
  var isSubmitLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUnits();
  }

  Future<void> fetchUnits() async {
    try {
      isLoading.value = true;
      final res = await ApiData().unitMasterListApi();
      if (res != null && res.status == true && res.data != null) {
        units.assignAll(res.data!);
      } else {
        units.clear();
      }
    } catch (e) {
      print('Error fetching units: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addUnit(String name) async {
    try {
      isSubmitLoading.value = true;
      final res = await ApiData().unitMasterAddApi({'name': name});
      if (res != null && (res.status == true || res.message != null)) {
        Get.snackbar('Success', res.message ?? 'Unit added successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchUnits();
      } else {
        Get.snackbar('Error', res?.message ?? 'Failed to add unit',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print('Error adding unit: $e');
    } finally {
      isSubmitLoading.value = false;
    }
  }

  Future<void> updateUnit(int id, String name) async {
    try {
      isSubmitLoading.value = true;
      final res = await ApiData().unitMasterUpdateApi(id, {'name': name});
      if (res != null && (res.status == true || res.message != null)) {
        Get.snackbar('Success', res.message ?? 'Unit updated successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchUnits();
      } else {
        Get.snackbar('Error', res?.message ?? 'Failed to update unit',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print('Error updating unit: $e');
    } finally {
      isSubmitLoading.value = false;
    }
  }

  Future<void> deleteUnit(int id) async {
    try {
      final res = await ApiData().unitMasterDeleteApi(id);
      if (res != null && (res.status == true || res.message != null)) {
        Get.snackbar('Success', res.message ?? 'Unit deleted successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchUnits();
      } else {
        Get.snackbar('Error', res?.message ?? 'Failed to delete unit',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print('Error deleting unit: $e');
    }
  }
}
