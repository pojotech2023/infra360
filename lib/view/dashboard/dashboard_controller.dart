import 'dart:convert';

import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/site_management_model.dart';
import 'package:raptor_pro/model/supervisor_permissions_model.dart';

import '../../model/login_response.dart';
import '../../service/shared_preference_service.dart';
import '../site/site_add_screen.dart';
import '../widgets/toast.dart';
import 'package:flutter/material.dart';

class DashboardController extends GetxController {
  List<SiteManagementList> siteManagementList = [];
  bool isLoading = false;

  late LoginResponse userDetails;
  var profileImage = ''.obs;
  var profileName  = ''.obs;
  var profileRole  = ''.obs;

  /// Holds the full permissions object for the logged-in supervisor.
  /// null = admin login or permissions not yet loaded.
  var supervisorPermissions = Rxn<PermissionsData>();

  @override
  void onInit() {
    final data = jsonDecode(PreferenceUtils().getUserInfo());
    userDetails = LoginResponse.fromJson(data);
    profileImage.value = userDetails.data!.user!.image ?? '';
    profileName.value  = userDetails.data!.user!.name  ?? '';
    profileRole.value  = userDetails.data!.role         ?? '';

    init();
    super.onInit();
  }

  updateFromPreference() {
    final data = jsonDecode(PreferenceUtils().getUserInfo());
    userDetails = LoginResponse.fromJson(data);

    profileImage.value = userDetails.data?.user?.image ?? '';
    profileName.value  = userDetails.data?.user?.name  ?? '';
    profileRole.value  = userDetails.data?.role         ?? '';
    update();
  }

  init() async {
    isLoading = true;
    update();

    // ── 1. Load site list ────────────────────────────────────────────────────
    SiteManagementModel? siteManagementModel = await ApiData().siteListApi();
    if (siteManagementModel != null) {
      siteManagementList = siteManagementModel.data ?? [];

      int siteLimit = userDetails.data?.siteLimit ?? 0;
      if (siteManagementList.length >= siteLimit && siteLimit > 0) {
        PreferenceUtils().setHasReachedLimit(true);
      }
    }

    // ── 2. Load permissions if supervisor ────────────────────────────────────
    if (profileRole.value.toLowerCase() == 'supervisor') {
      await _loadSupervisorPermissions();
    } else {
      // Admin: clear any stale cached permissions
      supervisorPermissions.value = null;
      PreferenceUtils().clearSupervisorPermissions();
      print("ℹ️ [PERMISSIONS] Role='${profileRole.value}' → skipping permissions load");
    }

    isLoading = false;
    update();
  }

  /// Fetches permissions from API using the logged-in supervisor's user ID.
  /// Falls back to SharedPrefs cache on failure.
  Future<void> _loadSupervisorPermissions() async {
    final int? supervisorId = userDetails.data?.user?.id;

    if (supervisorId == null) {
      print("❌ [PERMISSIONS] Cannot fetch — supervisor user ID is null");
      return;
    }

    print("🔐 [PERMISSIONS] Loading for supervisorId=$supervisorId ...");

    final model = await ApiData().getSupervisorPermissions(supervisorId);

    if (model != null && model.permissions != null) {
      supervisorPermissions.value = model.permissions;

      // Cache the permissions JSON for offline/restart usage
      final encoded = jsonEncode(model.permissions!.toJson());
      PreferenceUtils().setSupervisorPermissions(encoded);
      print("💾 [PERMISSIONS] Cached to SharedPreferences: $encoded");
    } else {
      // Fallback: restore from cache
      print("⚠️ [PERMISSIONS] API failed — attempting to load from cache...");
      final cached = PreferenceUtils().getSupervisorPermissions();
      if (cached.isNotEmpty) {
        try {
          supervisorPermissions.value =
              PermissionsData.fromJson(jsonDecode(cached));
          print("📦 [PERMISSIONS] Loaded from cache successfully");
        } catch (e) {
          print("❌ [PERMISSIONS] Failed to parse cached permissions: $e");
          supervisorPermissions.value = null;
        }
      } else {
        print("❌ [PERMISSIONS] No cache found — all options default to VISIBLE");
        supervisorPermissions.value = null;
      }
    }
  }

  deleteSite(int siteId) async {
    isLoading = true;
    update();
    CommonSuccessResponseModel? result = await ApiData().deleteSiteApi(siteId);
    if (result != null) {
      showToastMessage(result.message ?? 'Delete Successfully');
      await init();
    }
    isLoading = false;
    update();
  }

  void checkSiteLimitAndNavigate() {
    bool hasReachedLimit = PreferenceUtils().getHasReachedLimit();
    int siteLimit = userDetails.data?.siteLimit ?? 0;
    int currentCount = siteManagementList.length;

    if (currentCount >= siteLimit && siteLimit > 0) {
      PreferenceUtils().setHasReachedLimit(true);
      hasReachedLimit = true;
    }

    if (hasReachedLimit) {
      Get.dialog(
        AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              child: const Text("OK",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      );
    } else {
      Get.to(() => SiteAddScreen());
    }
  }
}
