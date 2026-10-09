import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/vendor_dashboard_model.dart';

class VendorDashboardController extends GetxController{

  var vendorDataList = <VendorData>[].obs;
  RxBool isLoading=true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }
  init()async{
    isLoading.value=true;
    try {
      VendorDashboardModel ?vendorDashboardModel=   await ApiData().vendorDashboardList();

      if(vendorDashboardModel!=null){
        vendorDataList.value=vendorDashboardModel.data??[];
      }
    } catch(e) {
      print("Error loading vendor dashboard: $e");
    } finally {
      isLoading.value=false;
    }
  }
}