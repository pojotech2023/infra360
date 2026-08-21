import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/api_data.dart';
import '../../model/terms_condition_model.dart';

class TermsConditionController extends GetxController {
  var isLoading = false.obs;
  var termsList = <TermsConditionData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTerms();
  }

  Future<void> fetchTerms() async {
    isLoading.value = true;
    update();
    try {
      final res = await ApiData().getTermsConditions();
      if (res != null && res.status == true) {
        termsList.value = res.data ?? [];
      } else {
        termsList.clear();
        Get.snackbar(
          'Error',
          res?.message ?? 'Failed to fetch Terms & Conditions',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error fetching terms & conditions: $e');
      termsList.clear();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<bool> addTerm(String title, String description) async {
    try {
      final res = await ApiData().addTermsCondition(title, description);
      if (res != null && (res.status == true || res.responseCode == 200 || res.responseCode == 201)) {
        Get.snackbar(
          'Success',
          res.message ?? 'Template added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchTerms();
        return true;
      } else {
        Get.snackbar(
          'Error',
          res?.message ?? 'Failed to add template',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error adding terms & conditions: $e');
    }
    return false;
  }

  Future<bool> updateTerm(int id, String title, String description) async {
    try {
      final res = await ApiData().updateTermsCondition(id, title, description);
      if (res != null && (res.status == true || res.responseCode == 200 || res.responseCode == 201)) {
        Get.snackbar(
          'Success',
          res.message ?? 'Template updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchTerms();
        return true;
      } else {
        Get.snackbar(
          'Error',
          res?.message ?? 'Failed to update template',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error updating terms & conditions: $e');
    }
    return false;
  }

  Future<bool> deleteTerm(int id) async {
    try {
      final res = await ApiData().deleteTermsCondition(id);
      if (res != null && res.status == true) {
        Get.snackbar(
          'Success',
          res.message ?? 'Template deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchTerms();
        return true;
      } else {
        Get.snackbar(
          'Error',
          res?.message ?? 'Failed to delete template',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error deleting terms & conditions: $e');
    }
    return false;
  }
}
