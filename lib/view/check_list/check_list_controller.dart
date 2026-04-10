

import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:raptor_pro/model/common_success_model.dart';

import '../../api/api_data.dart';
import '../../model/checklist_model.dart';
import '../../model/login_response.dart';
import '../../service/shared_preference_service.dart';
import '../../utils/global_toast.dart';

class CheckListController extends GetxController{
  List<Checklists> checkListManagement = [];
  var isLoading = false.obs;
  late final int siteId;
  late LoginResponse userDetails;
  String? selectedreqest;

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
}


