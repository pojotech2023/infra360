import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/customer_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class CustomerListController extends GetxController {
  RxBool isLoading = true.obs;
  var customerData = <Customers>[].obs;
  var sitesMap = <int, String>{}.obs;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    isLoading.value = true;
    try {
      // Fetch sites for fallback lookup if customer object only has siteId
      final siteModel = await ApiData().siteListApi();
      if (siteModel?.data != null) {
        for (var s in siteModel!.data!) {
          if (s.id != null && s.siteName != null && s.siteName!.isNotEmpty) {
            sitesMap[s.id!] = s.siteName!;
          }
        }
      }
    } catch (e) {
      print("Error loading sites in CustomerListController: $e");
    }

    try {
      CustomerModel? customerModel = await ApiData().customerList();
      if (customerModel != null && customerModel.data != null) {
        customerData.value = customerModel.data!.customers ?? [];
      }
    } catch (e) {
      print("Error loading customers in CustomerListController: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String getCustomerSiteName(Customers customer) {
    if (customer.displaySiteName.isNotEmpty) {
      return customer.displaySiteName;
    }
    if (customer.siteId != null && sitesMap.containsKey(customer.siteId)) {
      return sitesMap[customer.siteId] ?? '';
    }
    return '';
  }

  deleteCustomer(int id) async {
    CommonSuccessResponseModel? commonSuccessModel = await ApiData().deleteCustomer(id);

    if (commonSuccessModel != null) {
      showToastMessage(commonSuccessModel.message ?? "Something Went wrong");
      init();
    }
  }
}