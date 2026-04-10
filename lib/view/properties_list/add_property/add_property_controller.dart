import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/view/properties_list/properties_list_controller.dart';
import 'package:raptor_pro/view/widgets/toast.dart';
import 'package:image_picker/image_picker.dart';

class AddPropertyController extends GetxController{
  RxBool isLoading=false.obs;
  final ImagePicker picker = ImagePicker();
  Rxn<File> propertyImage = Rxn<File>();

  TextEditingController nameController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  RxString propertyType =RxString("Plot");

  addProperty() async{
    isLoading.value=true;
    CommonSuccessResponseModel  ?model=await ApiData().addProperty(
        nameController.text,
        locationController.text,
        propertyType.value,
        amountController.text,
        remarksController.text,
        propertyImage.value);

    isLoading.value=false;

    if(model!=null){
      showToastMessage(model.message??"Something Went wrong");
       Get.find<PropertiesController>().init();
      Get.back();
    }

  }

  getImage()async{
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image!=null){
      propertyImage.value=File(image.path);
    }
  }
}