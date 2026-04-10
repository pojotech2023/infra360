import 'dart:convert';

import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/site_management_model.dart';

import '../../model/login_response.dart';
import '../../service/shared_preference_service.dart';
import '../site/site_add_screen.dart';
import '../widgets/toast.dart';
import 'package:flutter/material.dart';

class DashboardController extends GetxController {
  List<SiteManagementList> siteManagementList = [];
  bool isLoading = false;

  late LoginResponse userDetails;
  var profileImage =''.obs;
  var profileName =''.obs;
  var profileRole =''.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    final data = jsonDecode(PreferenceUtils().getUserInfo());
     userDetails = LoginResponse.fromJson(data);
    profileImage.value = userDetails.data!.user!.image ??'';
    profileName.value =userDetails.data!.user!.name ??'';
    profileRole.value =userDetails.data!.role ??'';


    init();
    super.onInit();
  }

  updateFromPreference() {
    final data = jsonDecode(PreferenceUtils().getUserInfo());
    userDetails = LoginResponse.fromJson(data);

    profileImage.value = userDetails.data?.user?.image ?? '';
    profileName.value = userDetails.data?.user?.name ?? '';
    profileRole.value = userDetails.data?.role ?? '';
    update();
  }


  init() async {
    isLoading = true;
    update();
    SiteManagementModel? siteManagementModel = await ApiData().siteListApi();

    if (siteManagementModel != null) {
      siteManagementList = siteManagementModel.data ?? [];
      
      // If limit is reached, set the persistent flag
      int siteLimit = userDetails.data?.siteLimit ?? 0;
      if (siteManagementList.length >= siteLimit && siteLimit > 0) {
        PreferenceUtils().setHasReachedLimit(true);
      }
    }
    isLoading = false;
    update();
  }


  deleteSite(int siteId) async {
    isLoading = true;
    update();
    CommonSuccessResponseModel? siteManagementModel = await ApiData().deleteSiteApi(siteId);

    if (siteManagementModel != null) {
      showToastMessage(siteManagementModel.message ?? 'Delete Successfully');
     await init();

    }
    isLoading = false;
    update();
  }

  void checkSiteLimitAndNavigate() {
    bool hasReachedLimit = PreferenceUtils().getHasReachedLimit();
    int siteLimit = userDetails.data?.siteLimit ?? 0;

    // Even if not previously reached, check current count
    int currentCount = siteManagementList.length;
    if (currentCount >= siteLimit && siteLimit > 0) {
        PreferenceUtils().setHasReachedLimit(true);
        hasReachedLimit = true;
    }

    if (hasReachedLimit) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
              SizedBox(width: 10),
              Text("Limit Reached"),
            ],
          ),
          content: const Text(
            "You have reached your plan limit. You cannot add more sites",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      );
    } else {
      Get.to(() => SiteAddScreen());
    }
  }
}
