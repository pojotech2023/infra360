import 'package:flutter/material.dart';


import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:raptor_pro/model/common_success_model.dart';

import '../../api/api_data.dart';
import '../../model/checklist_model.dart';
import '../../model/login_response.dart';
import '../../service/shared_preference_service.dart';
import '../../utils/global_toast.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class CheckListController extends GetxController{
  List<Checklists> checkListManagement = [];
  var isLoading = false.obs;
  late final int siteId;
  late LoginResponse userDetails;
  String? selectedreqest;
  bool isManageMode = false;

  void toggleManageMode() {
    isManageMode = !isManageMode;
    update();
  }
  @override
  void onInit() {
    // TODO: implement onInit
    siteId = Get.arguments ?? 0;
    final data = jsonDecode(PreferenceUtils().getUserInfo());
    userDetails = LoginResponse.fromJson(data);
    init();
    super.onInit();
  }

  init() async {
    isLoading.value = true;
    update();
    CheckListModel? model = await ApiData().checkListApi(siteId);

    if (model != null) {
      checkListManagement = model.checklists ?? [];

    }
    isLoading.value = false;
    update();
  }

  supervisorAprroved({required Tasks tasks,required int taskId,String? remarks, List<File>? files}) async {
    isLoading.value = true;
    update();
    CommonSuccessResponseModel? model = await ApiData().supervisorApproverApi(
        siteId: siteId.toString(),
        taskId: taskId.toString(),
        remarks: remarks ?? '',
      files: files
    );

    if (model != null) {
      Get.back();
     /* GlobalToast.show(
        message: model.message ?? '',
        type: ToastType.success,
      );*/
      var d= 0;
      tasks.setStatus(d);

    }
    isLoading.value = false;
    update();
  }

  adminAprroved({required Tasks tasks,required int taskId,String? remarks}) async {
    isLoading.value = true;
    update();
    CommonSuccessResponseModel? model = await ApiData().adminApproverApi(siteId: siteId, taskId: taskId, status: selectedreqest!.toLowerCase() ?? '', remark: remarks ?? '');

    if (model != null) {
     /* GlobalToast.show(
        message: model.message ?? '',
        type: ToastType.success,
      );
*/
   var d= selectedreqest!.toLowerCase() == 'approved' ? 1 : 2;

      tasks.setStatus(d);


      Get.back();

    }
    isLoading.value = false;
    update();
  }

  Future<void> editStage(int id, String newName) async {
    isLoading.value = true;
    update();
    final res = await ApiData().editStageApi(id, newName);
    if (res != null) {
      showToastMessage(res.message ?? "Stage updated successfully");
      await init();
    } else {
      showToastMessage("Failed to update stage");
    }
    isLoading.value = false;
    update();
  }

  Future<void> deleteStage(int id) async {
    isLoading.value = true;
    update();
    final res = await ApiData().deleteStageApi(id);
    if (res != null) {
      showToastMessage(res.message ?? "Stage deleted successfully");
      await init();
    } else {
      showToastMessage("Failed to delete stage");
    }
    isLoading.value = false;
    update();
  }

  Future<void> addTask(int checklistId, String taskName) async {
    isLoading.value = true;
    update();
    final res = await ApiData().addTaskApi(checklistId, taskName);
    if (res != null) {
      showToastMessage(res.message ?? "Task added successfully");
      await init();
    } else {
      showToastMessage("Failed to add task");
    }
    isLoading.value = false;
    update();
  }

  Future<void> editTask(int id, String newName) async {
    isLoading.value = true;
    update();
    final res = await ApiData().editTaskApi(id, newName);
    if (res != null) {
      showToastMessage(res.message ?? "Task updated successfully");
      await init();
    } else {
      showToastMessage("Failed to update task");
    }
    isLoading.value = false;
    update();
  }

  Future<void> deleteTask(int id) async {
    isLoading.value = true;
    update();
    final res = await ApiData().deleteTaskApi(id);
    if (res != null) {
      showToastMessage(res.message ?? "Task deleted successfully");
      await init();
    } else {
      showToastMessage("Failed to delete task");
    }
    isLoading.value = false;
    update();
  }

  Future<void> reorderStages(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = checkListManagement.removeAt(oldIndex);
    checkListManagement.insert(newIndex, item);
    update();
    
    List<int> orderedIds = checkListManagement.map((e) => e.checklistId!).toList();
    final res = await ApiData().reorderStagesApi(orderedIds);
    if (res == null) {
      showToastMessage("Failed to reorder stages");
      await init(); // rollback
    }
  }

  Future<void> reorderTasks(int checklistIndex, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final stage = checkListManagement[checklistIndex];
    if (stage.tasks == null) return;
    
    final item = stage.tasks!.removeAt(oldIndex);
    stage.tasks!.insert(newIndex, item);
    update();
    
    List<int> orderedIds = stage.tasks!.map((e) => e.taskId!).toList();
    final res = await ApiData().reorderTasksApi(orderedIds);
    if (res == null) {
      showToastMessage("Failed to reorder tasks");
      await init(); // rollback
    }
  }
}

