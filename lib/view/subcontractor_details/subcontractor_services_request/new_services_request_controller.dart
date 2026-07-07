import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/model/subcontractor_amount_model.dart' as amt;
import 'package:raptor_pro/model/subcontractor_list_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

import '../subcontractor_sitewise_controller.dart';
import 'request_details_controller.dart';

class NewServicesRequestController extends GetxController {

  RxList<Subcontractor> getLists = <Subcontractor>[].obs;
  Rxn<Subcontractor> selectedSubContractorData = Rxn<Subcontractor>();

  var isLoading = false.obs;
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController countController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController remarksController = TextEditingController();

  // For edit mode
  amt.Subcontractors? editItem;
  bool get isEditMode => editItem != null;

  @override
  void onInit() {
    // Check if we're in edit mode by reading the args
    final args = Get.arguments;
    if (args is SubcontracorDetailsArgs && args.editServiceItem != null) {
      editItem = args.editServiceItem;
      _prefillForEdit();
    }
    getSubcontractorApi();
    super.onInit();
  }

  void _prefillForEdit() {
    if (editItem == null) return;
    amountController.text = editItem!.amount ?? '';
    countController.text = editItem!.noCounts ?? '0';
    remarksController.text = editItem!.remarks ?? '';
    try {
      if (editItem!.date != null && editItem!.date!.isNotEmpty) {
        final dt = DateTime.parse(editItem!.date!);
        dateController.text = DateFormat('dd-MM-yyyy').format(dt);
      }
    } catch (_) {
      dateController.text = editItem!.date ?? '';
    }
  }

  getSubcontractorApi() async {
    isLoading.value = true;
    SubcontractorModel? subcontractorModel = await ApiData().subContractorManagementList();
    if (subcontractorModel != null) {
      getLists.value = subcontractorModel.data ?? [];
      // Pre-select the subcontractor if editing
      if (editItem?.subcontractorId != null) {
        try {
          final match = getLists.firstWhere((s) => s.id == editItem!.subcontractorId);
          selectedSubContractorData.value = match;
          mobileNoController.text = match.mobileNo;
          addressController.text = match.address;
        } catch (_) {}
      }
    }
    isLoading.value = false;
  }

  addServicesApi(int siteId) async {
    isLoading.value = true;
    String apiDate = dateController.text; // Backend expects dd-MM-yyyy

    Map<String, dynamic> postedData = {
      "site_id": siteId,
      'subcontractor_id': selectedSubContractorData.value!.id,
      'subcontractor_type': selectedSubContractorData.value!.subcontractors,
      'date': apiDate,
      'amount': amountController.text,
      'no_counts': countController.text,
    };

    CommonSuccessResponseModel? res = await ApiData().addSubcontractorServicesApi(postedData);

    if (res != null) {
      if (res.responseCode == 200 || res.status == true) {
        showToastMessage(res.message ?? "Added successfully");
        try {
          SubcontractorController subCtrl = Get.find();
          subCtrl.init(siteId);
        } catch (_) {}
        try {
          RequestDetailsController detailsController = Get.find();
          detailsController.fetchData();
        } catch (_) {}
        Get.back();
      } else {
        showToastMessage(res.message ?? "Failed to add");
      }
    }
    isLoading.value = false;
    update();
  }

  updateServicesApi(int siteId) async {
    if (editItem == null) return;
    isLoading.value = true;
    String apiDate = dateController.text; // Backend expects dd-MM-yyyy

    Map<String, dynamic> postedData = {
      "id": editItem!.id,
      "site_id": siteId,
      'subcontractor_id': selectedSubContractorData.value?.id ?? editItem!.subcontractorId,
      'subcontractor_type': selectedSubContractorData.value?.subcontractors ?? editItem!.subcontractorType,
      'date': apiDate,
      'amount': amountController.text,
      'no_counts': countController.text.isNotEmpty ? countController.text : (editItem!.noCounts ?? '0'),
      'remarks': remarksController.text,
    };

    // Ensure no_counts is never empty
    if (postedData['no_counts'] == null || postedData['no_counts'].toString().isEmpty) {
      postedData['no_counts'] = '0';
    }

    CommonSuccessResponseModel? res = await ApiData().updateSubcontractorServiceApi(editItem!.id!, postedData);

    if (res != null && (res.responseCode == 200 || res.status == true)) {
      showToastMessage(res.message ?? "Updated successfully");
      try {
        RequestDetailsController detailsController = Get.find();
        detailsController.fetchData();
      } catch (_) {}
      Get.back();
    } else {
      showToastMessage(res?.message ?? "Failed to update");
    }
    isLoading.value = false;
    update();
  }
}