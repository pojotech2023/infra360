import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/vendor_payment_details_model.dart';
import 'package:raptor_pro/model/vendor_material_orders_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class VendorPaymentDetailsController extends GetxController{

  RxBool isLoading=true.obs;
  RxBool isButtonLoading=false.obs;
  var vendorDataList = VendorPaymentDetailsData().obs;
  TextEditingController openingBalanceController = TextEditingController();
  RxnInt vendorId = RxnInt();

  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }

  init()async{
    isLoading.value=true;
    try {
      print("Fetching vendor payment details for ID: ${Get.arguments}");
      vendorId.value = Get.arguments as int?;
      print("Stored vendor ID: ${vendorId.value}");

      VendorPaymentDetailsModel ?vendorPaymentDetailsModel=   await ApiData().vendorPaymentDetail(Get.arguments);

      if(vendorPaymentDetailsModel!=null){
        vendorDataList.value=vendorPaymentDetailsModel.data?? VendorPaymentDetailsData();
        final payDetail = vendorDataList.value.payDetail;

        openingBalanceController.text = payDetail?.openingBalance ?? '';

        print("PayDetail totalUnits: ${payDetail?.totalUnits}");
        print("PayDetail totalUnitPrice: ${payDetail?.totalUnitPrice}");
        print("PayDetail balanceAmount: ${payDetail?.balanceAmount}");
        print("PayDetail paidAmount: ${payDetail?.paidAmount}");

        // Fetch vendor material orders to get site_name
        await fecthVendorMaterialOrders();
      } else {
        print("Failed to load vendor payment details - API returned null");
      }
    } catch (e) {
      print("Error loading vendor payment details: $e");
    } finally {
      isLoading.value=false;
    }
  }

  Future<void> fecthVendorMaterialOrders() async {
    try {
      print("Fetching vendor material orders for ID: ${Get.arguments}");
      VendorMaterialOrdersModel? materialOrdersModel = await ApiData().vendorMaterialOrdersApi(Get.arguments);

      if (materialOrdersModel != null) {
        print("Vendor Material Orders API Status: ${materialOrdersModel.status}");
        print("Vendor Material Orders Data: ${materialOrdersModel.data?.toJson()}");

        if (materialOrdersModel.data != null) {
          print("Total Orders: ${materialOrdersModel.data?.orders?.length}");

          // Get site_name from the first order (or any order)
          if (materialOrdersModel.data?.orders != null && materialOrdersModel.data!.orders!.isNotEmpty) {
            final firstOrder = materialOrdersModel.data!.orders!.first;
            final siteName = firstOrder.siteName;
            print("Site Name from first order: $siteName");
            print("First order data: ${firstOrder.toJson()}");

            // Update vendorDataList with site_name
            vendorDataList.value.siteName = siteName;
            print("Updated vendorDataList.siteName: ${vendorDataList.value.siteName}");
            vendorDataList.refresh();
          } else {
            print("No orders found in material orders data");
          }
        } else {
          print("Material orders data is null");
        }
      } else {
        print("Failed to load vendor material orders - API returned null");
      }
    } catch (e) {
      print("Error fetching vendor material orders: $e");
    }
  }

  paymentUpdate()async{
    isButtonLoading.value=true;
    final payDetail = vendorDataList.value.payDetail;

    final Map<String, dynamic> vendorPaymentMap = {
      "vendor_id": Get.arguments,
      "opening_balance": openingBalanceController.text,
      "total_units": payDetail!.totalUnits,
      "total_unit_price": payDetail.totalUnitPrice,
      "balance_amount": payDetail.balanceAmount,
      "paid_amount": payDetail.paidAmount,
    };
    CommonSuccessResponseModel ?commonSuccessResponseModel=   await ApiData().vendorPaymentUpdateDetail(vendorPaymentMap);
    if(commonSuccessResponseModel!=null){
      showToastMessage(commonSuccessResponseModel.message??"Something Went wrong");
      Get.back();
    }
    isButtonLoading.value=false;

  }
}