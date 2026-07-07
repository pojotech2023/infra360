import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/api_data.dart';
import '../../model/common_success_model.dart';

class AddChecklistController extends GetxController {
  TextEditingController stageController = TextEditingController();

  List<TextEditingController> taskControllers = [];

  var isLoading = false.obs;
  late final int siteId;

  @override
  void onInit() {
    siteId = Get.arguments ?? 0;
    addTaskField();
    super.onInit();
  }

  @override
  void onClose() {
    stageController.dispose();
    for (var c in taskControllers) {
      c.dispose();
    }
    super.onClose();
  }

  void addTaskField() {
    taskControllers.add(TextEditingController());
    update();
  }

  void removeTaskField(int index) {
    if (taskControllers.length > 1) {
      taskControllers[index].dispose();
      taskControllers.removeAt(index);
      update();
    }
  }

  Future<void> submitChecklist() async {
    if (stageController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Please enter a Stage name.',
          backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return;
    }

    final List<String> tasks = taskControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (tasks.isEmpty) {
      Get.snackbar('Validation', 'Please enter at least one Task.',
          backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    update();

    CommonSuccessResponseModel? result = await ApiData().addChecklistApi(
      siteId: siteId,
      stage: stageController.text.trim(),
      tasks: tasks,
    );

    isLoading.value = false;
    update();

    if (result != null && result.status == true) {
      // ✅ Navigate back FIRST before showing snackbar to avoid
      // LateInitializationError on SnackbarController._controller
      Get.back(result: true);
      // Small delay so the route transition completes before snackbar appears
      await Future.delayed(const Duration(milliseconds: 300));
      Get.snackbar(
        'Success',
        result.message ?? 'Checklist added successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        result?.message ?? 'Failed to add checklist.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
