import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/subcontractor_dashboard_model.dart';

class SubContractorDashboardController extends GetxController{

  var subContractorData = <SubContractorData>[].obs;
  RxBool isLoading=true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }
  init()async{
    isLoading.value=true;
 SubContractorDashboardModel ?subContractor=   await ApiData().subContractorDashboardList();

 if(subContractor!=null){
   subContractorData.value=subContractor.data??[];
 }
    isLoading.value=false;

  }
}