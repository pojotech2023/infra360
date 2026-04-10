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
 VendorDashboardModel ?vendorDashboardModel=   await ApiData().vendorDashboardList();

 if(vendorDashboardModel!=null){
   vendorDataList.value=vendorDashboardModel.data??[];
 }
    isLoading.value=false;

  }
}