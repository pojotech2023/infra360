import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../api/api_data.dart';
import '../../model/material_estimation_model.dart';
import '../../model/common_success_model.dart';

class MaterialEstimationItem {
  TextEditingController particular = TextEditingController();
  TextEditingController quantity = TextEditingController();
  int? unitId;
  String? unitName;
  TextEditingController date = TextEditingController();
  DateTime selectedDate = DateTime.now();
  
  MaterialEstimationItem() {
    date.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }
}

class MaterialEstimationController extends GetxController {
  late int siteId;

  var itemList = <MaterialEstimationItem>[].obs;
  List<UnitInfo> units = [];
  List<RequestedMaterial> requestedMaterials = [];

  var isLoading = false.obs;
  var isSubmitLoading = false.obs;

  @override
  void onInit() {
    siteId = Get.arguments as int;
    itemList.add(MaterialEstimationItem());
    _loadData();
    super.onInit();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    update();
    try {
      final res = await ApiData().materialEstimationFormApi(siteId);
      final unitRes = await ApiData().unitMasterListApi();

      if (res != null && res.status == true) {
        if (res.data?.requestedMaterials != null) {
          requestedMaterials = res.data!.requestedMaterials!;
        }
      }

      if (unitRes != null && unitRes.data != null) {
        units = unitRes.data!.map((u) => UnitInfo(id: u.id, name: u.unitName)).toList();
      }

    } catch (e) {
      print('Error loading material estimation form: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void addItem() {
    if (itemList.isNotEmpty) {
      final lastItem = itemList.last;
      if (lastItem.particular.text.trim().isEmpty || 
          lastItem.quantity.text.trim().isEmpty || 
          lastItem.unitId == null || 
          lastItem.date.text.trim().isEmpty) {
        Get.snackbar('Validation', 'Please fill all fields of the current item before adding a new row', 
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }
    }
    itemList.add(MaterialEstimationItem());
    update();
  }

  void removeItem(int index) {
    if (itemList.length > 1) {
      itemList.removeAt(index);
      update();
    }
  }

  void updateUnit(int index, UnitInfo unit) {
    itemList[index].unitId = unit.id;
    itemList[index].unitName = unit.name;
    update();
  }

  Future<void> selectDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: itemList[index].selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      itemList[index].selectedDate = picked;
      itemList[index].date.text = DateFormat('dd-MM-yyyy').format(picked);
      update();
    }
  }

  Future<void> submit() async {
    isSubmitLoading.value = true;
    update();
    
    try {
      final particulars = itemList.map((i) => i.particular.text.trim()).toList();
      final quantities = itemList.map((i) => i.quantity.text.trim()).toList();
      final unitIds = itemList.map((i) => i.unitId.toString()).toList();
      final unitNames = itemList.map((i) => i.unitName ?? '').toList();
      final dates = itemList.map((i) => DateFormat('yyyy-MM-dd').format(i.selectedDate)).toList();

      final payload = {
        'site_id': siteId,
        'particular': particulars,
        'quantity': quantities,
        'unit_id': unitIds,
        'unit': unitNames,
        'date': dates,
      };

      print('📦 MaterialEstimation PAYLOAD: $payload');
      final res = await ApiData().materialEstimationAddApi(payload);
      
      if (res != null && res.status == true) {
        Get.snackbar('Success', res.message ?? 'Added successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        
        // Reset form
        itemList.clear();
        itemList.add(MaterialEstimationItem());
        
        // Refresh list
        _loadData();
      } else {
        Get.snackbar('Error', res?.message ?? 'Failed to add material estimation.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print('Error submitting material estimation: $e');
    } finally {
      isSubmitLoading.value = false;
      update();
    }
  }

  Future<void> deleteMaterial(int id) async {
    try {
      final res = await ApiData().materialEstimationDeleteApi(id);
      if (res != null && res.status == true) {
        Get.snackbar('Success', res.message ?? 'Deleted successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        _loadData();
      } else {
        Get.snackbar('Error', res?.message ?? 'Failed to delete.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print('Error deleting material estimation: $e');
    }
  }

  Future<void> updateMaterial(int id, String particular, String quantity, int? unitId, String? unitName, String date) async {
    try {
      final payload = {
        'particular': particular,
        'quantity': quantity,
        'unit_id': unitId?.toString() ?? '',
        'unit': unitName ?? '',
        'date': date,
      };
      
      final res = await ApiData().materialEstimationUpdateApi(id, payload);
      if (res != null && res.status == true) {
        Get.snackbar('Success', res.message ?? 'Updated successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        _loadData();
      } else {
        Get.snackbar('Error', res?.message ?? 'Failed to update.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print('Error updating material estimation: $e');
    }
  }
}
