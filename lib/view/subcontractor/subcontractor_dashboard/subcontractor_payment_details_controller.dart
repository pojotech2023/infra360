import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/subcontractor_payment_details_model.dart';
import 'package:raptor_pro/model/subcontractor_material_orders_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class SubcontractorPaymentDetailsController extends GetxController{

  RxBool isLoading=true.obs;
  RxBool isButtonLoading=false.obs;
  var subcontractorDataList = SubcontractorPaymentDetailsData().obs;
  TextEditingController openingBalanceController = TextEditingController();
  // Read-only display controllers — populated after API load
  TextEditingController totalUnitsController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController paidAmountController = TextEditingController();
  TextEditingController balanceAmountController = TextEditingController();
  RxnInt subcontractorId = RxnInt();

  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }

  init()async{
    isLoading.value=true;
    try {
      print("Fetching subcontractor payment details for ID: ${Get.arguments}");
      subcontractorId.value = Get.arguments as int?;
      print("Stored subcontractor ID: ${subcontractorId.value}");

      SubcontractorPaymentDetailsModel ?subcontractorPaymentDetailsModel=   await ApiData().subcontractorPaymentDetail(Get.arguments);

      if(subcontractorPaymentDetailsModel!=null){
        subcontractorDataList.value=subcontractorPaymentDetailsModel.data?? SubcontractorPaymentDetailsData();
        final payDetail = subcontractorDataList.value.payDetail;

        print("payDetail from API: totalUnits=${payDetail?.totalUnits}, totalUnitPrice=${payDetail?.totalUnitPrice}, paidAmount=${payDetail?.paidAmount}, balanceAmount=${payDetail?.balanceAmount}");
        print("Top-level totalUnits=${subcontractorDataList.value.totalUnits}, totalAmount=${subcontractorDataList.value.totalAmount}");

        openingBalanceController.text = payDetail?.openingBalance ?? '';
        // Populate display controllers — this is the fix for blank fields
        totalUnitsController.text = payDetail?.totalUnits ?? subcontractorDataList.value.totalUnits ?? '';
        totalAmountController.text = payDetail?.totalUnitPrice ?? subcontractorDataList.value.totalAmount ?? '';
        paidAmountController.text = payDetail?.paidAmount ?? '';
        balanceAmountController.text = payDetail?.balanceAmount ?? '';

        print("Final Total Units set in controller: '${totalUnitsController.text}'");

        // Fetch subcontractor material orders to get site_name
        await fetchSubcontractorMaterialOrders();
      } else {
        print("Failed to load subcontractor payment details - API returned null");
      }
    } catch (e) {
      print("Error loading subcontractor payment details: $e");
    } finally {
      isLoading.value=false;
    }
  }

  Future<void> fetchSubcontractorMaterialOrders() async {
    try {
      print("Fetching subcontractor material orders for ID: ${Get.arguments}");
      SubcontractorMaterialOrdersModel? materialOrdersModel = await ApiData().subcontractorMaterialOrdersApi(Get.arguments);

      if (materialOrdersModel != null) {
        print("Subcontractor Material Orders API Status: ${materialOrdersModel.status}");

        if (materialOrdersModel.data != null) {
          print("Total Orders: ${materialOrdersModel.data?.orders?.length}");

          // Get site_name from the first order (or any order)
          if (materialOrdersModel.data?.orders != null && materialOrdersModel.data!.orders!.isNotEmpty) {
            final firstOrder = materialOrdersModel.data!.orders!.first;
            final siteName = firstOrder.siteName;
            print("Site Name from first order: $siteName");

            // Update subcontractorDataList with site_name
            subcontractorDataList.value.siteName = siteName;
            print("Updated subcontractorDataList.siteName: ${subcontractorDataList.value.siteName}");
            subcontractorDataList.refresh();
          } else {
            print("No orders found in material orders data");
          }
        } else {
          print("Material orders data is null");
        }
      } else {
        print("Failed to load subcontractor material orders - API returned null");
      }
    } catch (e) {
      print("Error fetching subcontractor material orders: $e");
    }
  }

  paymentUpdate()async{
    isButtonLoading.value=true;
    final payDetail = subcontractorDataList.value.payDetail;

    final Map<String, dynamic> subcontractorPaymentMap = {
      "subcontractor_id": Get.arguments,
      "opening_balance": openingBalanceController.text,
      "total_units": payDetail!.totalUnits,
      "total_counts": payDetail.totalUnits,
      "total_unit_price": payDetail.totalUnitPrice,
      "total_amount": payDetail.totalUnitPrice,
      "balance_amount": payDetail.balanceAmount,
      "paid_amount": payDetail.paidAmount,
    };

    CommonSuccessResponseModel ?model= await ApiData().subcontractorPaymentUpdateDetail(subcontractorPaymentMap);

    if(model!=null){
      showToastMessage(model.message??"Something Went wrong");
      Get.back();
    }

    isButtonLoading.value=false;

  }
}
