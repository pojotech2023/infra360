import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/subcontractor_payment_history_model.dart';

import '../../../model/subcontractor_dashboard_model.dart';

class SubContractorPaymentHistoryController extends GetxController {
  RxBool isLoading = true.obs;

  final   SubContractorData  argData = Get.arguments;

  var subContractorData = SubContractorPaymentHistory(
    paymentHistoryList: [],
    totalPaidAmount: 0,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    fetchPaymentHistory();
  }

  Future<void> fetchPaymentHistory() async {
    isLoading.value = true;

    SubContractorPaymentHistoryModel? model =
    await ApiData().subContractorPaymentHistoryApi(argData.subcontractorId.toString());

    if (model != null && model.data != null) {
      subContractorData.value = model.data!;
    }

    isLoading.value = false;
  }
}
