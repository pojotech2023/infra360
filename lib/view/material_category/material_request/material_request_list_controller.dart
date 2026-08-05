import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/material_request_list_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class MaterialRequestListController extends GetxController {
  final int siteId;
  final String siteName;

  MaterialRequestListController({required this.siteId, required this.siteName});

  RxList<MaterialRequestItem> requests = <MaterialRequestItem>[].obs;
  RxBool isLoading = false.obs;
  RxBool isActioning = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    print("🔍 [MaterialRequestListController] Fetching requests for siteId=$siteId");
    try {
      final result = await ApiData().getMaterialRequestsApi(siteId);
      print("📥 [MaterialRequestListController] Got ${result?.data?.length ?? 0} requests");
      if (result != null && result.data != null) {
        requests.assignAll(result.data!);
      } else {
        requests.clear();
        print("⚠️ [MaterialRequestListController] No data returned or API error");
      }
    } catch (e) {
      print("❌ [MaterialRequestListController] fetchRequests exception: $e");
      requests.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveRequest(int id) async {
    isActioning.value = true;
    print("✅ [MaterialRequestListController] Approving request id=$id");
    try {
      final res = await ApiData().approveMaterialRequestApi(id);
      print("📥 [MaterialRequestListController] Approve response: status=${res?.status} message=${res?.message}");
      if (res != null && res.status == true) {
        showToastMessage(res.message ?? "Request approved");
        await fetchRequests();
      } else {
        showToastMessage(res?.message ?? "Failed to approve request");
      }
    } catch (e) {
      print("❌ [MaterialRequestListController] approveRequest exception: $e");
      showToastMessage("Error approving request");
    } finally {
      isActioning.value = false;
    }
  }

  Future<void> rejectRequest(int id, {String? adminRemark}) async {
    isActioning.value = true;
    print("❌ [MaterialRequestListController] Rejecting request id=$id  adminRemark=$adminRemark");
    try {
      final res = await ApiData().rejectMaterialRequestApi(id, adminRemark: adminRemark);
      print("📥 [MaterialRequestListController] Reject response: status=${res?.status} message=${res?.message}");
      if (res != null && res.status == true) {
        showToastMessage(res.message ?? "Request rejected");
        await fetchRequests();
      } else {
        showToastMessage(res?.message ?? "Failed to reject request");
      }
    } catch (e) {
      print("❌ [MaterialRequestListController] rejectRequest exception: $e");
      showToastMessage("Error rejecting request");
    } finally {
      isActioning.value = false;
    }
  }
}
