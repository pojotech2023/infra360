import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/supervisor_list_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class SuperVisorManagementController extends GetxController{

  RxBool isLoading=true.obs;
  RxBool isSaveLoading=false.obs;

  var superVisorList = <SuperVisorData>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }

  init()async{
     isLoading.value=true;

    SuperVisorModel ?superVisorModel= await ApiData().superVisorList();

    if(superVisorModel!=null){
      superVisorList.value= superVisorModel.data??[];
    }
     isLoading.value=false;

  }

  addSupervisor(String name,String mobileNo,String emailId,String password,String confrimpassword)async{
    isSaveLoading.value=true;

    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().addSuperVisor(name, mobileNo, emailId,password,confrimpassword);

    if(commonSuccessModel!=null){
      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      Get.back();
      init();
    }

    isSaveLoading.value=false;
  }

  deleteSupervisor(int id)async{

    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().deleteSuperVisor(id);

    if(commonSuccessModel!=null){
      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      init();
    }

    isSaveLoading.value=false;
  }

  updateSupervisor(int id,String name,String mobileNo,String emailId,String password,String confrimpassword)async{
    isSaveLoading.value=true;

    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().updateSuperVisor(id,name, mobileNo, emailId,password,confrimpassword);

    if(commonSuccessModel!=null){
      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      Get.back();
      init();
    }

    isSaveLoading.value=false;
  }


}