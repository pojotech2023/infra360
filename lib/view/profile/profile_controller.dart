import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../api/api_data.dart';
import '../../service/shared_preference_service.dart';
import '../dashboard/dashboard_controller.dart';
import '../widgets/toast.dart';

class ProfileController extends GetxController {
  var isLoading    = false.obs;
  var isSaveLoading = false.obs;

  var profileId    = ''.obs;
  var profileImage = ''.obs;

  // Profile info
  TextEditingController nameController    = TextEditingController();
  TextEditingController mobileController  = TextEditingController();
  TextEditingController emailController   = TextEditingController();

  // Password change
  TextEditingController newPasswordController       = TextEditingController();
  TextEditingController confirmPasswordController   = TextEditingController();

  @override
  void onInit() {
    viewProfileApi();
    super.onInit();
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // ─── GET Profile ──────────────────────────────────────────
  Future<void> viewProfileApi() async {
    isLoading.value = true;
    try {
      final role = Get.find<DashboardController>().profileRole.value.toLowerCase();
      final model = await ApiData().viewProfile(role);
      if (model != null && model.data != null) {
        profileId.value    = model.data!.id?.toString() ?? '';
        profileImage.value = model.data!.image?.toString() ?? '';
        nameController.text   = model.data!.name    ?? '';
        mobileController.text = model.data!.mobileNo ?? '';
        emailController.text  = model.data!.email   ?? '';
      } else {
        showToastMessage(model?.message ?? 'Failed to load profile');
      }
    } catch (e) {
      showToastMessage('Error loading profile: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // ─── POST Profile Update ─────────────────────────────────
  Future<void> updateProfileApi({File? files}) async {
    isSaveLoading.value = true;
    try {
      final role = Get.find<DashboardController>().profileRole.value.toLowerCase();
      final model = await ApiData().updateProfile(
        role: role,
        userID: profileId.value,
        name:   nameController.text.trim(),
        email:  emailController.text.trim(),
        newPassword: newPasswordController.text.isNotEmpty
            ? newPasswordController.text
            : null,
        confirmPassword: confirmPasswordController.text.isNotEmpty
            ? confirmPasswordController.text
            : null,
        files: files,
      );

      if (model != null && (model.status == true)) {

        // Clear password fields after successful update
        newPasswordController.clear();
        confirmPasswordController.clear();

        // Update shared preferences + DashboardController
        final userInfoStr = PreferenceUtils().getUserInfo();
        if (userInfoStr.isNotEmpty) {
          final userJson = jsonDecode(userInfoStr);
          userJson['data']['user']['name']  = nameController.text.trim();
          userJson['data']['user']['image'] = model.data?.image ?? profileImage.value;
          PreferenceUtils().setUserInfo(jsonEncode(userJson));
        }

        // Refresh dashboard header
        try {
          final d = Get.find<DashboardController>();
          d.updateFromPreference();
          d.update();
        } catch (_) {}

        // Reload profile image from response
        if (model.data?.image != null) {
          profileImage.value = model.data!.image.toString();
        }

        Get.back();
      } else {
        // Silently handle failure as requested
      }
    } catch (e) {
      // Silently handle error as requested
    } finally {
      isSaveLoading.value = false;
      update();
    }
  }
}