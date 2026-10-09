import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/site_management_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

import '../../model/customer_model.dart';
import '../../utils/res/date_picker.dart';
import 'customer_list_controller.dart';

class CustomerManagementController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool isSaveLoading = false.obs;

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController mobileNumberEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController dobEditingController = TextEditingController();
  TextEditingController marrageDateEditingController = TextEditingController();
  TextEditingController addressEditingController = TextEditingController();
  TextEditingController siteNameEditingController = TextEditingController();

  var siteList = <SiteManagementList>[].obs;
  Rxn<int> selectedSiteId = Rxn<int>();

  Customers? customerData = Get.arguments;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    isLoading.value = true;
    customerData = Get.arguments;
    if (customerData != null) {
      nameEditingController.text = customerData!.name ?? "";
      mobileNumberEditingController.text = customerData!.mobileNo ?? "";
      emailEditingController.text = customerData!.email ?? "";
      dobEditingController.text = formatDate(customerData!.dob ?? "");
      marrageDateEditingController.text = formatDate(customerData!.marriageDate ?? '');
      addressEditingController.text = customerData!.address ?? "";
      selectedSiteId.value = customerData!.siteId;
      siteNameEditingController.text = customerData!.displaySiteName;
    }

    try {
      final siteModel = await ApiData().siteListApi();
      if (siteModel?.data != null) {
        siteList.value = siteModel!.data!;
        if (selectedSiteId.value != null && siteNameEditingController.text.isEmpty) {
          final matched = siteList.firstWhereOrNull((s) => s.id == selectedSiteId.value);
          if (matched != null) {
            siteNameEditingController.text = matched.siteName ?? '';
          }
        }
      }
    } catch (e) {
      print("Error loading sites in CustomerManagementController: $e");
    }

    isLoading.value = false;
    update();
  }

  updateCustomer() async {
    if (customerData == null) return;
    int customerid = customerData!.id ?? 0;
    int siteid = selectedSiteId.value ?? customerData!.siteId ?? 0;

    isSaveLoading.value = true;

    CommonSuccessResponseModel? commonSuccessModel = await ApiData().updateCustomer(
        customerid,
        siteid,
        nameEditingController.text,
        mobileNumberEditingController.text,
        emailEditingController.text,
        dobEditingController.text,
        marrageDateEditingController.text,
        addressEditingController.text);

    if (commonSuccessModel != null) {
      if (Get.isRegistered<CustomerListController>()) {
        CustomerListController list = Get.find<CustomerListController>();
        list.init();
      }

      showToastMessage(commonSuccessModel.message ?? "Something Went wrong");
      Get.back();
      update();
    }

    isSaveLoading.value = false;
  }
}