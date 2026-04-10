import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/property_list_model.dart';

class PropertiesController extends GetxController{

  RxBool isLoading=false.obs;

  var propertiesList = <PropertyListData>[].obs;
  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }

  init()async{
    isLoading.value=true;

   PropertyListModel ?propertyListModel= await ApiData().propertyList();

   if(propertyListModel!=null){
     propertiesList.value = propertyListModel.data??[];
   }


    isLoading.value=false;

  }
}