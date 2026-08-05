import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/vendor_payment_history_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class AddVendorPaymentController extends GetxController{

  RxBool isLoading= false.obs;

  TextEditingController paymentController =TextEditingController();
  final TextEditingController datePickerController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  RxnString ?selectedPayment = RxnString();

  bool isEditMode = false;
  PaymentHistoryList? editItem;
  dynamic vendorId;

  @override
  void onInit() {
    _parseArguments();
    super.onInit();
  }

  void _parseArguments() {
    if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      isEditMode = args['isEditMode'] ?? false;
      editItem = args['item'];
      vendorId = args['vendorId'];

      if (isEditMode && editItem != null) {
        paymentController.text = editItem!.payment?.toString() ?? '';
        remarksController.text = editItem!.remarks ?? '';
        if (editItem!.paymentMode != null && editItem!.paymentMode!.isNotEmpty) {
          selectedPayment!.value = editItem!.paymentMode;
        }
        try {
          if (editItem!.date != null && editItem!.date!.isNotEmpty) {
            final dt = DateTime.parse(editItem!.date!);
            datePickerController.text = DateFormat('dd-MM-yyyy').format(dt);
          }
        } catch (_) {
          datePickerController.text = editItem!.date ?? '';
        }
      }
    } else {
      vendorId = Get.arguments;
    }
  }

  addPayment()async{
    isLoading.value =true;

    if (vendorId == null) {
      showToastMessage("Vendor ID is missing. Please try again.");
      isLoading.value = false;
      return;
    }

    String formattedDate = datePickerController.text.trim();
    if (formattedDate.isNotEmpty) {
      if (isEditMode) {
        // Update API expects YYYY-MM-DD
        if (formattedDate.length == 10 && (formattedDate[2] == '-' || formattedDate[2] == '/')) {
          formattedDate = "${formattedDate.substring(6, 10)}-${formattedDate.substring(3, 5)}-${formattedDate.substring(0, 2)}";
        } else if (formattedDate.length >= 10 && formattedDate[4] == '-') {
          formattedDate = formattedDate.substring(0, 10);
        } else {
          try {
            final dt = DateFormat('dd-MM-yyyy').parse(formattedDate);
            formattedDate = DateFormat('yyyy-MM-dd').format(dt);
          } catch (_) {}
        }
      } else {
        // Add API expects DD-MM-YYYY
        if (formattedDate.length >= 10 && formattedDate[4] == '-') {
          formattedDate = "${formattedDate.substring(8, 10)}-${formattedDate.substring(5, 7)}-${formattedDate.substring(0, 4)}";
        } else if (formattedDate.length == 10 && formattedDate[2] == '/') {
          formattedDate = formattedDate.replaceAll('/', '-');
        }
      }
    }

    Map<String,dynamic> postData ={
      "vendor_id": vendorId,
      "payment": paymentController.text,
      "date": formattedDate,
      "payment_mode":selectedPayment!.value,
      "remarks": remarksController.text
    };

    CommonSuccessResponseModel ?model;
    
    if (isEditMode && editItem != null) {
      model = await ApiData().updatePaymentApi(editItem!.id!, postData);
    } else {
      model = await ApiData().vendorPaymentUpdate(postData);
    }

    if(model!=null){
      showToastMessage(model.message??"Success");
      Get.back(result: true);
    }

    isLoading.value=false;

  }
}