import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/agent_list_model.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class AgentManagementController extends GetxController{

  RxBool isLoading=true.obs;
  RxBool isSaveLoading=false.obs;

  var agentList = <AgentListData>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }

  init()async{
    isLoading.value=true;

    AgentListModel ?agentModel= await ApiData().agentList();

    if(agentModel!=null){
      agentList.value= agentModel.data??[];
    }
    isLoading.value=false;

  }

  addAgent(String name,String mobileNo,String companyName)async{
    isSaveLoading.value=true;

    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().addAgent(name, mobileNo, companyName);

    if(commonSuccessModel!=null){
      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      Get.back();
      init();
    }

    isSaveLoading.value=false;
  }

  deleteAgent(int id)async{

    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().deleteAgent(id);

    if(commonSuccessModel!=null){
      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      init();
    }

    isSaveLoading.value=false;
  }

  updateAgent(int id,String name,String mobileNo,String emailId)async{
    isSaveLoading.value=true;

    CommonSuccessResponseModel ?commonSuccessModel = await ApiData().updateAgent(id,name, mobileNo, emailId);

    if(commonSuccessModel!=null){
      showToastMessage(commonSuccessModel.message??"Something Went wrong");
      Get.back();
      init();
    }

    isSaveLoading.value=false;
  }


}