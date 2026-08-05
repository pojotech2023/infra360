import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/subcontractor_payment_history_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class AddSubcontractorPaymentController extends GetxController{

  RxBool isLoading= false.obs;

  TextEditingController paymentController =TextEditingController();
  final TextEditingController datePickerController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  RxnString ?selectedPayment = RxnString();

  bool isEditMode = false;
  PaymentHistoryList? editItem;
  dynamic subcontractorId;

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
      subcontractorId = args['subcontractorId'];

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
      subcontractorId = Get.arguments;
    }
  }

  addPayment()async{
    isLoading.value =true;

    if (subcontractorId == null) {
      showToastMessage("Subcontractor ID is missing. Please try again.");
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
      "subcontractor_id": subcontractorId,
      "payment": paymentController.text,
      "date": formattedDate,
      "payment_mode":selectedPayment!.value,
      "remarks": remarksController.text
    };

    CommonSuccessResponseModel ?model;
    
    if (isEditMode && editItem != null) {
      model = await ApiData().updateSubPaymentApi(editItem!.id!, postData);
    } else {
      model = await ApiData().subcontractorPaymentUpdate(postData);
    }

    if(model!=null){
      showToastMessage(model.message??"Success");
      Get.back(result: true);
    } else {
      showToastMessage("Failed to process payment. Please check your input and try again.");
    }

    isLoading.value=false;

  }
}
