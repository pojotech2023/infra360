
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/model/employee_list_model.dart';

import '../../api/api_data.dart';
import '../../model/common_success_model.dart';
import '../../model/site_management_model.dart';
import '../dashboard/dashboard_controller.dart';


class SiteController extends GetxController {

  TextEditingController siteNameEditingController = TextEditingController();
  TextEditingController durationEditingController = TextEditingController();
  TextEditingController builtupAreaController = TextEditingController();
  TextEditingController flatAreaController = TextEditingController();
  TextEditingController locationEditingController = TextEditingController();

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController mobileNumberEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController addressEditingController = TextEditingController();
  TextEditingController employeeEditingController = TextEditingController();

  TextEditingController dobPickerController = TextEditingController();
  Rxn<EmployeeListData> selectedEmployeeData = Rxn<EmployeeListData>();


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
siteID.value = arg!.id.toString();
      status.value = normalizeStatus(arg.status ?? '');
      selectedStatus.value = normalizeStatus(arg.status ?? '');


      supervisorID.value = arg!.supervisor!.id.toString();
      siteNameEditingController.text = arg!.siteName??"";
      durationEditingController.text = arg!.duration??"";
      builtupAreaController.text = arg!.builtupArea??"";
      flatAreaController.text = arg!.flatArea??"";
      locationEditingController.text = arg!.location??"";


update();

    }
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

  addSiteApi({required  File files}) async {
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
      siteName:siteNameEditingController.text,
     location:locationEditingController.text,
        flatArea:flatAreaController.text,
        builtupArea:builtupAreaController.text,
        duration:durationEditingController.text,
        supervisorId:selectedEmployeeData.value!.id.toString(),
        customerName:nameEditingController.text,
        mobileNo:mobileNumberEditingController.text,
        email:emailEditingController.text,
        dob:apiDate,
        address:addressEditingController.text,
        files: files
    );


    print("RESPONCSE CODE ${model!.status!}");
    print("RESPONCSE CODE ${model!.message!}");

    if (model != null) {

      DashboardController controller = Get.put(DashboardController());
     await controller.init();
      Get.back();
    }
    isSaveLoading.value = false;
    update();
  }


  updateSiteApi({File? files}) async {
    isSaveLoading.value = true;
    update();

    CommonSuccessResponseModel? model = await ApiData().updateSiteApi(
      id: siteID.value,
      siteName: siteNameEditingController.text,
      location: locationEditingController.text,
      flatArea: flatAreaController.text,
      builtupArea: builtupAreaController.text,
      duration: durationEditingController.text,
      supervisorId: selectedEmployeeData.value!.id.toString(),
      status: selectedStatus.toString(),
      files: files, // ✅ nullable, safe
    );

    if (model != null) {
      print("✅ Response Code: ${model.status}");
      print("✅ Message: ${model.message}");

      DashboardController controller = Get.put(DashboardController());
      await controller.init();
      Get.back();
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



}