import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/customer_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class CustomerListController extends GetxController{

  RxBool isLoading=true.obs;
  var customerData = <Customers>[].obs;
  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }
  init()async{
    isLoading.value=true;

  CustomerModel ?customerModel=  await ApiData().customerList();

  if(customerModel!=null){
    customerData.value=customerModel.data!.customers??[];
  }

    isLoading.value=false;


  }

  deleteCustomer(int id)async{

    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().deleteCustomer(id);

    if(commonSuccessModel!=null){
      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      init();
    }

  }

}