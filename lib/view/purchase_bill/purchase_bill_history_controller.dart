import 'package:get/get.dart';
import '../../api/api_data.dart';
import '../../model/purchase_bill_model.dart';
import '../widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchaseBillHistoryController extends GetxController {
  late int siteId;
  var isLoading = true.obs;
  var isDeleting = false.obs;
  List<PurchaseBillItemModel> historyList = [];
  var siteName = ''.obs;

  @override
  void onInit() {
    siteId = Get.arguments as int;
    fetchSiteName();
    fetchHistory();
    super.onInit();
  }

  void fetchSiteName() async {
    try {
      final res = await ApiData().siteListApi();
      if (res != null && res.data != null) {
        final site = res.data!.firstWhere((element) => element.id == siteId);
        siteName.value = site.siteName ?? '';
      }
    } catch (e) {
      print("Error fetching site name: $e");
    }
  }

  void fetchHistory() async {
    isLoading.value = true;
    try {
      final res = await ApiData().purchaseBillsListApi(siteId);
      if (res != null) {
        if (res.status == true && res.data != null) {
          historyList = res.data!;
        } else {
          historyList = [];
        }
      }
    } catch (e) {
      print("Error fetching purchase bill history: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void deleteBill(int id) async {
    isDeleting.value = true;
    update();
    try {
      final res = await ApiData().purchaseBillDeleteApi(id);
      if (res != null && res.status == true) {
        showToastMessage(res.message ?? "Deleted successfully");
        fetchHistory();
      } else {
        showToastMessage(res?.message ?? "Failed to delete");
      }
    } catch (e) {
      print("Error deleting purchase bill: $e");
    } finally {
      isDeleting.value = false;
      update();
    }
  }

  void openPdf(String? pdfUrl) async {
    if (pdfUrl == null || pdfUrl.isEmpty) {
      showToastMessage("PDF not available");
      return;
    }
    final url = Uri.parse(pdfUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      showToastMessage("Could not launch PDF");
    }
  }

  void shareWhatsapp(String? whatsappUrl) async {
    if (whatsappUrl == null || whatsappUrl.isEmpty) {
      showToastMessage("WhatsApp link not available");
      return;
    }
    final url = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      showToastMessage("Could not launch WhatsApp");
    }
  }

  void downloadPdf(String? pdfUrl) async {
    openPdf(pdfUrl);
  }
}
