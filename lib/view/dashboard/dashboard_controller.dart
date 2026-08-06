import 'dart:async';
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
  var selectedTab = 'All'.obs;

  List<SiteManagementList> get filteredSiteList {
    if (selectedTab.value == 'All') {
      return siteManagementList;
    }
    return siteManagementList.where((site) => site.status?.toLowerCase() == selectedTab.value.toLowerCase()).toList();
  }

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
    startPermissionPolling();
    
    super.onInit();
  }

  @override
  void onClose() {
    stopPermissionPolling();
    super.onClose();
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

    try {
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
    } catch (e, stacktrace) {
      print("🚨 Exception in DashboardController.init: $e\n$stacktrace");
    } finally {
      isLoading = false;
      update();
    }
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

    if (model != null) {
      if (model.permissions != null) {
        supervisorPermissions.value = model.permissions;
      }
      
      if (model.assignedSites != null) {
        final assignedIds = model.assignedSites!.map((s) => s.id).toSet();
        siteManagementList = siteManagementList.where((site) => assignedIds.contains(site.id)).toList();
        print("✅ [PERMISSIONS] Assigned sites applied to dashboard. Count: ${siteManagementList.length}");
        for (final site in siteManagementList) {
          print("Assigned Site: ${site.id} - ${site.siteName}");
        }
      }

      // Cache the full model JSON for offline/restart usage
      final encoded = jsonEncode(model.toJson());
      PreferenceUtils().setSupervisorPermissions(encoded);
      print("💾 [PERMISSIONS] Cached to SharedPreferences");
      
      // Force UI update to reflect permission changes
      update();
    } else {
      // Fallback: restore from cache — do NOT reset to null (that causes menu flicker)
      print("⚠️ [PERMISSIONS] API failed — attempting to load from cache...");
      final cached = PreferenceUtils().getSupervisorPermissions();
      if (cached.isNotEmpty) {
        try {
          final cachedModel = SupervisorPermissionsModel.fromJson(jsonDecode(cached));
          if (cachedModel.permissions != null) {
            supervisorPermissions.value = cachedModel.permissions;
          }
          if (cachedModel.assignedSites != null) {
            final assignedIds = cachedModel.assignedSites!.map((s) => s.id).toSet();
            siteManagementList = siteManagementList.where((site) => assignedIds.contains(site.id)).toList();
            print("📦 [PERMISSIONS] Assigned sites loaded from cache. Count: ${siteManagementList.length}");
          }
          print("📦 [PERMISSIONS] Loaded from cache successfully");
        } catch (e) {
          print("❌ [PERMISSIONS] Failed to parse cached permissions: $e");
          // Keep existing value rather than resetting to null
        }
      } else {
        // No cache — keep last known value, don't reset to null which shows everything
        print("⚠️ [PERMISSIONS] No cache found — keeping current permissions state");
      }
      update();
    }
  }

  /// Refreshes supervisor permissions from API and updates UI immediately.
  /// Call this when permissions may have changed (e.g., after admin updates).
  Future<void> refreshPermissions() async {
    if (profileRole.value.toLowerCase() != 'supervisor') {
      print("ℹ️ [PERMISSIONS] Not a supervisor — skipping permission refresh");
      return;
    }

    print("🔄 [PERMISSIONS] Refreshing permissions...");
    
    // Clear cached permissions to force fresh API call
    PreferenceUtils().clearSupervisorPermissions();
    
    // Reload from API
    await _loadSupervisorPermissions();
    
    print("✅ [PERMISSIONS] Refresh complete");
  }

  void stopPermissionPolling() {
    _permissionPollTimer?.cancel();
    _permissionPollTimer = null;
  }

  void startPermissionPolling() {
    // Only poll for supervisors
    if (profileRole.value.toLowerCase() != 'supervisor') return;

    // Prevent duplicate timers
    stopPermissionPolling();

    _permissionPollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Fetch permissions silently without showing loading UI
      _loadSupervisorPermissions();
    });
  }

  // Keep _permissionPollTimer as a nullable field for logout cleanup
  Timer? _permissionPollTimer;

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
