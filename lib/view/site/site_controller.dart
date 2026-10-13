
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/model/employee_list_model.dart';

import '../../api/api_data.dart';
import '../../model/common_success_model.dart';
import '../../model/customer_model.dart';
import '../../model/site_management_model.dart';
import '../dashboard/dashboard_controller.dart';
import '../../utils/file_download.dart';
import '../widgets/toast.dart';


class SiteController extends GetxController {

  TextEditingController siteNameEditingController = TextEditingController();
  TextEditingController durationEditingController = TextEditingController();
  TextEditingController builtupAreaController = TextEditingController();
  TextEditingController flatAreaController = TextEditingController();
  TextEditingController locationEditingController = TextEditingController();
  TextEditingController contractValueController = TextEditingController();

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController mobileNumberEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController addressEditingController = TextEditingController();
  TextEditingController employeeEditingController = TextEditingController();

  TextEditingController dobPickerController = TextEditingController();
  Rxn<EmployeeListData> selectedEmployeeData = Rxn<EmployeeListData>();

  // ── Customer Type ──
  /// 'new' or 'existing'
  var customerType = 'new'.obs;

  // Search by mobile (used when customerType == 'existing')
  TextEditingController searchMobileController = TextEditingController();
  var isSearchLoading = false.obs;
  var searchStatusMessage = ''.obs;
  var searchStatusIsError = false.obs;
  /// Holds the fetched existing customer's id so we can link it on submit
  var existingCustomerId = Rxn<int>();

  var isSaveLoading = false.obs;
  List<EmployeeListData> employeeList = [];

  var isEditForm = false.obs;
  var selectedStatus = ''.obs;
  var siteID =''.obs;
  var supervisorID =''.obs;
  var status =''.obs;

  @override
  void onInit() {
    super.onInit();

    fetchEmployeeList();
  }

  preFillData(SiteManagementList? arg){


    if(arg!= null){
      isEditForm.value = true;
      siteID.value = arg.id.toString();
      status.value = normalizeStatus(arg.status ?? '');
      selectedStatus.value = normalizeStatus(arg.status ?? '');

      supervisorID.value = arg.supervisor?.id?.toString() ?? '';
      siteNameEditingController.text = arg.siteName??"";
      locationEditingController.text = arg.location??"";
      durationEditingController.text = arg.duration??"";
      builtupAreaController.text = arg.builtupArea??"";
      flatAreaController.text = arg.flatArea??"";
      final val = arg.value ?? "";
      contractValueController.text = val.endsWith(".00") ? val.substring(0, val.length - 3) : val;

      if (employeeList.isNotEmpty && supervisorID.value.isNotEmpty) {
        for (var element in employeeList) {
          if (element.id.toString() == supervisorID.value) {
            selectedEmployeeData.value = element;
            break;
          }
        }
      }

      update();
    }
  }

  // ── Customer helpers ──

  /// Switch between New / Existing customer and clear relevant state
  void setCustomerType(String type) {
    customerType.value = type;
    resetCustomerFields();
    searchStatusMessage.value = '';
    searchStatusIsError.value = false;
    existingCustomerId.value = null;
    update();
  }

  void resetCustomerFields() {
    nameEditingController.clear();
    mobileNumberEditingController.clear();
    emailEditingController.clear();
    dobPickerController.clear();
    addressEditingController.clear();
  }

  void clearSiteForm() {
    siteNameEditingController.clear();
    durationEditingController.clear();
    builtupAreaController.clear();
    flatAreaController.clear();
    locationEditingController.clear();
    contractValueController.clear();
    selectedEmployeeData.value = null;
    resetCustomerFields();
  }

  /// Search for an existing customer by mobile number and auto-fill fields
  Future<void> searchCustomerByMobile() async {
    final mobile = searchMobileController.text.trim();
    if (mobile.length != 10) {
      searchStatusMessage.value = 'Please enter a valid 10-digit mobile number.';
      searchStatusIsError.value = true;
      update();
      return;
    }

    isSearchLoading.value = true;
    searchStatusMessage.value = '';
    searchStatusIsError.value = false;
    update();

    try {
      final CustomerModel? model = await ApiData().customerList();
      if (model != null && model.data != null && model.data!.customers != null) {
        final customers = model.data!.customers!;
        final match = customers.firstWhereOrNull(
          (c) => (c.mobileNo ?? '').trim() == mobile,
        );
        if (match != null) {
          // Populate fields
          nameEditingController.text = match.name ?? '';
          mobileNumberEditingController.text = match.mobileNo ?? '';
          emailEditingController.text = match.email ?? '';
          // Format dob for display: API returns yyyy-MM-dd → dd-MM-yyyy
          if (match.dob != null && match.dob!.isNotEmpty) {
            try {
              final parsed = DateFormat('yyyy-MM-dd').parse(match.dob!);
              dobPickerController.text = DateFormat('dd-MM-yyyy').format(parsed);
            } catch (_) {
              dobPickerController.text = match.dob!;
            }
          }
          addressEditingController.text = match.address ?? '';
          existingCustomerId.value = match.id;
          searchStatusMessage.value = 'Customer found and details loaded.';
          searchStatusIsError.value = false;
        } else {
          resetCustomerFields();
          existingCustomerId.value = null;
          searchStatusMessage.value = 'No customer found with this mobile number.';
          searchStatusIsError.value = true;
        }
      } else {
        searchStatusMessage.value = 'Unable to fetch Customer Management. Please try again.';
        searchStatusIsError.value = true;
      }
    } catch (e) {
      searchStatusMessage.value = 'Error: $e';
      searchStatusIsError.value = true;
    }

    isSearchLoading.value = false;
    update();
  }

  /// Fetch employee list from API
  Future<void> fetchEmployeeList() async {
    try {
      EmployeeListModel? model = await ApiData().getEmployeeListApi();

      if (model != null && model.data != null) {
        employeeList = model.data!;
        if (employeeList.isNotEmpty && isEditForm.value) {
          for (var element in employeeList) {
            if (element.id.toString() == supervisorID.value) {
              selectedEmployeeData.value = element;
              break;
            }
          }
        }
        print("✅ LENGTH OF EMPLOYEE: ${employeeList.length}");
      } else {
        print("⚠️ No employee data found.");
      }
    } catch (e) {
      print("❌ Error fetching employee list: $e");
    }
    update();
  }

  addSiteApi({File? files}) async {
    isSaveLoading.value = true;
    update();

    String apiDate ='' ;

    if (dobPickerController.text.isNotEmpty) {
      // Convert dd-MM-yyyy → yyyy-MM-dd
      DateTime parsed = DateFormat('dd-MM-yyyy').parse(dobPickerController.text);
       apiDate = DateFormat('yyyy-MM-dd').format(parsed);

      print('Date for API: $apiDate'); // 👉 2025-09-02
    }

    print('Date for API: $apiDate');
    CommonSuccessResponseModel? model = await ApiData().addSiteApi(
      siteName: siteNameEditingController.text,
      location: locationEditingController.text,
      flatArea: flatAreaController.text,
      builtupArea: builtupAreaController.text,
      duration: durationEditingController.text,
      supervisorId: selectedEmployeeData.value?.id?.toString() ?? '',
      customerName: nameEditingController.text,
      mobileNo: mobileNumberEditingController.text,
      email: emailEditingController.text,
      dob: apiDate,
      address: addressEditingController.text,
      contractValue: contractValueController.text.trim(),
      files: files,
    );

    if (model != null) {
      print("RESPONSE STATUS: ${model.status}");
      print("RESPONSE MESSAGE: ${model.message}");

      if (model.status == true) {
        showToastMessage(model.message ?? 'Site created successfully');
        DashboardController dashController = Get.put(DashboardController());
        await dashController.init();
        Get.back();
      } else {
        showToastMessage(model.message ?? 'Something went wrong. Please try again.');
      }
    } else {
      showToastMessage('Failed to create site. Please check your details and try again.');
    }

    isSaveLoading.value = false;
    update();
  }


  updateSiteApi({File? files}) async {
    void showError(String message) {
      showToastMessage(message);
    }

    if (siteNameEditingController.text.trim().isEmpty) {
      return showError('Please enter Site Name');
    }
    if (locationEditingController.text.trim().isEmpty) {
      return showError('Please enter Location');
    }
    if (flatAreaController.text.trim().isEmpty) {
      return showError('Please enter Flat Area');
    }
    if (builtupAreaController.text.trim().isEmpty) {
      return showError('Please enter Built-up Area');
    }
    if (durationEditingController.text.trim().isEmpty) {
      return showError('Please enter Duration');
    }
    final supId = selectedEmployeeData.value?.id?.toString() ?? supervisorID.value;
    if (supId.isEmpty) {
      return showError('Please select a Supervisor');
    }

    // ── API call ────────────────────────────────────────────────────────────
    isSaveLoading.value = true;
    update();

    CommonSuccessResponseModel? model = await ApiData().updateSiteApi(
      id: siteID.value,
      siteName: siteNameEditingController.text,
      location: locationEditingController.text,
      flatArea: flatAreaController.text,
      builtupArea: builtupAreaController.text,
      duration: durationEditingController.text,
      supervisorId: supId,
      status: selectedStatus.toString(),
      contractValue: contractValueController.text.trim(),
      files: files,
    );

    if (model != null) {
      print("✅ Response Code: ${model.status}");
      print("✅ Message: ${model.message}");

      if (model.status == true) {
        showToastMessage(model.message ?? 'Site updated successfully');
        DashboardController dashController = Get.put(DashboardController());
        await dashController.init();
        Get.back();
      } else {
        showToastMessage(model.message ?? 'Failed to update site. Please try again.');
      }
    } else {
      showToastMessage('Failed to update site. Please check your details and try again.');
    }

    isSaveLoading.value = false;
    update();
  }
  String normalizeStatus(String raw) {
    raw = raw.trim().toLowerCase();

    switch (raw) {
      case "coating":
        return "Coated";     // ← Match your list
      case "pending":
        return "Pending";
      case "active":
        return "Active";
      default:
        return raw.capitalizeFirst!;
    }
  }

  void siteFullExport(BuildContext context) {
    if (siteID.value.isNotEmpty) {
      final String reportUrl = "http://pojoinfra360.pojotech.in/api/sites/${siteID.value}/full-report";
      CommonFileDownloader.downloadAndOpen(
        urls: reportUrl,
        context: context,
        fileName: "site_${siteID.value}_full_report.xlsx",
      );
    } else {
      Get.snackbar("Error", "Site ID is empty, cannot export report.");
    }
  }
}
