import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/vendor_payment_history_model.dart';

class VendorPaymentHistoryController extends GetxController{

  RxBool isLoading= true.obs;

  var paymentHistoryData = VendorPaymentHistoryData().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }

  init()async{
    isLoading.value =true;


    VendorPaymentHistoryModel ?model= await ApiData().vendorPaymentHistory(Get.arguments);

    if(model!=null){
      paymentHistoryData.value=  model.data!;
    }

    isLoading.value=false;

  }
}