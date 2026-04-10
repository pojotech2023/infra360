import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/vendor_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

import '../../../base_url.dart';
import '../../../model/login_response.dart';
import '../../../model/material_details_argument_model.dart';
import '../../../model/material_request_success_model.dart';
import '../../../model/units_model.dart';
import '../../../service/shared_preference_service.dart';
import '../../../utils/const_data.dart';
import '../../../utils/res/sendWhatsAppMessage.dart';

class NewRequestController extends GetxController{

  MaterialDetailsArgs args = Get.arguments;

  RxList<VendorData> getBricksLists = <VendorData>[].obs;
  RxList<UnitsData> getUnitsLists = <UnitsData>[].obs;


  late LoginResponse userDetails;
  late VendorData selectedVendorData ;
var selectedUnit = ''.obs;
  var selectedDeliveryNeeded =''.obs;

  TextEditingController mobileNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController reMarksController = TextEditingController();

  TextEditingController supervisorNameController = TextEditingController();
  TextEditingController supervisorMobController = TextEditingController();

  List<String> units = List<String>.empty(growable: true);
  List<String> categories = List<String>.empty(growable: true);
  Rxn<String> selectedCategory = Rxn<String>();

  var itemKey  = ''.obs;





  @override
  void onInit() {
    getVendorApi("");
    print("-------------${args.id}");

    itemKey.value = args.itemKey;

    final data = jsonDecode(PreferenceUtils().getUserInfo());
    userDetails = LoginResponse.fromJson(data);


    materialUnitsListApi();
    supervisorNameController.text = args.supervisorName;
    supervisorMobController.text = args.supervisorMob;

    super.onInit();
  }

  getVendorApi(String vendorName)async{
   VendorModel ?vendorModel= await ApiData().vendorApi(vendorName);

   if(vendorModel!=null){
     getBricksLists.value=vendorModel.data??[];


   }
  }


  Future<void> materialUnitsListApi() async {

    try {
      UnitsModel? model = await ApiData().materialUnitsListApi();
      units.clear();
      categories.clear();

      if (model == null) {
        print("❌ UnitsModel is null");
        return;
      }

      getUnitsLists.value = model.data ?? [];

      if (getUnitsLists.isEmpty) {
        print("⚠️ No unit data found in API response");
        return;
      }

      // 🔍 Find the material that matches the itemKey
      UnitsData? matchedMaterial;

      print("ITEM KEY : ${args.itemKey.toString()}");
      try {
        matchedMaterial = getUnitsLists.firstWhere((element) {
          return element.materialType?.toLowerCase() == args.itemKey.toLowerCase();
        });
      } catch (e) {
        // fallback to default if not found
        try {
          matchedMaterial = getUnitsLists.firstWhere(
                (e) => e.materialType?.toLowerCase() == 'default',
          );
        } catch (e2) {
          matchedMaterial = null;
        }
      }

      if (matchedMaterial == null) {
        print("⚠️ No matching material found for ${args.itemKey}");
        return;
      }

      print("✅ Matched Material: ${matchedMaterial.materialType}");

      // 🧱 Case 1: Bricks
      if (matchedMaterial.materialType?.toLowerCase() == 'bricks') {
        if (matchedMaterial.attachment == true) {
          units.clear();
        } else {
          if (matchedMaterial.categoryName?.isNotEmpty ?? false) {
            categories.addAll(matchedMaterial.categoryName!);
          }
          if (matchedMaterial.unit?.isNotEmpty ?? false) {
            units.addAll(matchedMaterial.unit!);
          }
        }
      }

      // 🧩 Case 2: Known materials
      else if (ConstantData.allMaterialKeys
          .contains(matchedMaterial.materialType)) {
        if (matchedMaterial.attachment == true) {
          units.clear();
        } else if (matchedMaterial.unit?.isNotEmpty ?? false) {
          units.addAll(matchedMaterial.unit!);
        }
      }

      // ⚙️ Case 3: Unknown → use default
      else {
        UnitsData? defaultMaterial;
        try {
          defaultMaterial = getUnitsLists.firstWhere(
                (e) => e.materialType?.toLowerCase() == 'default',
          );
        } catch (e) {
          defaultMaterial = null;
        }

        if (defaultMaterial != null && defaultMaterial.attachment == false) {
          units.addAll(defaultMaterial.unit ?? []);
        } else {
          units.clear();
        }
      }

      print("✅ Units: $units");
      print("✅ Categories: $categories");
    } catch (e, stack) {
      print("❌ Error in materialUnitsListApi: $e");
      print(stack);
    }
    update();
  }


  addMaterialApi(File? attachment, int type) async {
    final siteId = args.id;
    final itemKey = args.itemKey.toString().toLowerCase();
    final role = userDetails.data!.role!.toLowerCase();


   var requestMaterialDateForamte =  DateFormat('yyyy-MM-dd')
        .format(DateFormat('dd-MM-yyyy').parse( dateController.text));


    // ------------------ COMMON MAP ------------------
    Map<String, String> requestData = {
      "site_id": siteId.toString(),
      "material_type": itemKey,
      "items": itemKey,
      "price": amountController.text,
      "quantity": quantityController.text,
      "unit": selectedUnit.value,
      "date_of_delivery": requestMaterialDateForamte,
      "amount": amountController.text,
      //"remarks": reMarksController.text,
    };


    if (itemKey.toLowerCase() == "bricks") {
      requestData["category_name"] = selectedCategory.value!.toString();
    }
    // Add only for admin
    if (role == "admin") {
      requestData["vendor_id"] = selectedVendorData!.id.toString();
    }

    // ------------------ ORDER MAP ------------------


    Map<String, String> orderData = {
      "site_id": siteId.toString(),
      "material_type": itemKey,
      "quantity": quantityController.text,
      "date": dateController.text,
      "unit": selectedUnit.value,
      "price": amountController.text,
    };



    if (type == 2) {
      orderData["vendor_id"] = selectedVendorData!.id.toString();
    }

    if (itemKey.toLowerCase() == "bricks") {
      orderData["category_name"] = selectedCategory.value!.toString();
    }

    // ------------------ FINAL POST DATA ------------------
    final postedData = type == 1 ? requestData : orderData;
    final apiUrl = type == 1 ? "request-order" : "add-order";

    MaterialRequestSuccessModel? res = await ApiData()
        .bricksRequestApi("$baseUrl$apiUrl", postedData, attachment);

    if (res == null) return;
    if (res.status != true) {
      showToastMessage(res.message ?? "");
      return;
    }

    // ------------------ MESSAGE BUILDER ------------------

    bool showVendorDetails =
        (role == 'admin') || (role == 'supervisor' && type == 2);

    String buildMessage({
      required String title,
      required bool hasAttachment,
      required String? attachmentUrl,
      required String? role,
    }) {
      return """
*SS Builders*
Site Name: ${args.siteName} - $title
Location: ${args.siteLocation}
${showVendorDetails ? "Vendor Name: ${selectedVendorData.name}\n" : ""}
${showVendorDetails ? "Vendor Address: ${selectedVendorData.address}\n" : ""}
${showVendorDetails ? "Vendor Mobile: ${selectedVendorData.mobileNo}\n" : ""}
Material Type: ${args.itemKey}\n
Unit : ${args.itemKey.toLowerCase() == 'bricks'
          ? "${selectedCategory.value} (${selectedUnit.value})"
          : selectedUnit.value}
\nDelivery Date: ${dateController.text}
\nQuantity: ${quantityController.text}
${type == 1 ? "Supervisor: ${supervisorNameController.text} (${supervisorMobController.text})" : ""}
${type == 2 ? "Price: ₹${amountController.text}" : ""}
${hasAttachment ? "Attachment: $attachmentUrl" : ""}
""";
    }

    // ------------------ FINAL MESSAGE LOGIC ------------------
    String message;

    if (type == 1) {
      // Material Request
      bool hasAttachment = res.data?.materialRequest?.imageUrl != null;
      message = buildMessage(
        title: "Material Request",
        hasAttachment: hasAttachment,
        attachmentUrl: res.data?.materialRequest?.imageUrl,
        role: userDetails.data!.role
      );
    } else {
      // Material Order
      bool hasAttachment = res.data?.materialOrder?.imageUrl != null;
      message = buildMessage(
        title: "Material Order",
        hasAttachment: hasAttachment,
        attachmentUrl: res.data?.materialOrder?.imageUrl,
          role: userDetails.data!.role
      );
    }

    // ------------------ WHATSAPP URL ------------------
    String phone = type == 1 ? "7540060694" : selectedVendorData.mobileNo.toString();

    String whatsappUrl =
        "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";

    extractAndOpenWhatsApp(whatsappUrl);

    showToastMessage(res.message ?? "");
    Get.back();
  }



/*
  addMaterialApi(File? attachement,int type)async{

   var siteId =   args.id;
   var itemKey  = args.itemKey;


    Map<String,String> requestData={
      "site_id":siteId.toString(),
      "material_type":itemKey,
      "quantity":quantityController.text,
      "unit":selectedUnit.value,
      "category_name":selectedCategory.value.toString(),
      "delivery_needed_by":selectedDeliveryNeeded.value,
     // "amount":amountController.text,
      "amount":"",
      "remarks":reMarksController.text,
    };


   // Add vendor_id ONLY for admin
   if (userDetails.data!.role!.toLowerCase() == "admin") {
     requestData["vendor_id"] = selectedVendorData!.id.toString();
   }

   Map<String,String> orderData={
     "site_id":siteId.toString(),
     "material_type":itemKey,
     "quantity":quantityController.text,
     "date":dateController.text,
     "unit":selectedUnit.value,
     "price":amountController.text,
     "category_name":selectedCategory.value.toString(),

   };
   // Add vendor_id ONLY for admin
   if (userDetails.data!.role!.toLowerCase() == "admin") {
     orderData["vendor_id"] = selectedVendorData!.id.toString();
   }

     var postedData  = type == 1 ? requestData : orderData;
   var urls  = type == 1 ? "request-order" : "add-order";


   MaterialRequestSuccessModel ?commonSuccessResponseModel= await ApiData()
       .bricksRequestApi("$baseUrl$urls",postedData,attachement);

   if(commonSuccessResponseModel!=null){
    if(commonSuccessResponseModel.status==true){



       var whatappUrls;
       var message;

       if(type == 1){

         if(itemKey.toLowerCase() == 'bricks'){

         message = """
*SS Builders*
Site Name: ${args.siteName} - Material Request
Location: ${args.siteLocation}
Vendor Name: ${selectedVendorData.name}
Vendor Address: ${selectedVendorData.address}
Vendor Mobile Number: ${selectedVendorData.mobileNo}
Material Type: $itemKey
Category:  ${selectedCategory}(${selectedUnit})
Delivery:${selectedDeliveryNeeded.value}
Quantity: ${quantityController.text}
Supervisor: ${supervisorNameController.text} (${supervisorMobController.text} 
Remarks: ${reMarksController.text}
""";}
         else if(commonSuccessResponseModel.data!.materialRequest!.imageUrl !=null){


           message = """
*SS Builders*
Site Name: ${args.siteName} - Material Request
Location: ${args.siteLocation}
Vendor Name: ${selectedVendorData.name}
Vendor Address: ${selectedVendorData.address}
Vendor Mobile Number: ${selectedVendorData.mobileNo}
Material Type: $itemKey
Unit:  ${selectedUnit}
Delivery:${selectedDeliveryNeeded.value}
Quantity: ${quantityController.text}
Supervisor: ${supervisorNameController.text} (${supervisorMobController.text} 
Remarks: ${reMarksController.text}
Attachment: ${commonSuccessResponseModel.data!.materialRequest!.imageUrl}
""";

         }else{


           message = """
*SS Builders*
Site Name: ${args.siteName} - Material Request
Location: ${args.siteLocation}
Vendor Name: ${selectedVendorData.name}
Vendor Address: ${selectedVendorData.address}
Vendor Mobile Number: ${selectedVendorData.mobileNo}
Material Type: $itemKey
Unit:  ${selectedUnit}
Delivery:${selectedDeliveryNeeded.value}
Quantity: ${quantityController.text}
Supervisor: ${supervisorNameController.text} (${supervisorMobController.text} 
Remarks: ${reMarksController.text}
""";
         }

         whatappUrls = "https://wa.me/${7540060694}?text=${Uri.encodeComponent(message)}";


       }else{


         if(itemKey.toLowerCase() == 'breaks'){
          message = """
*SS Builders*
Site Name: ${args.siteName} - Material Order
Location: ${args.siteLocation}
Vendor Name: ${selectedVendorData.name}
Vendor Address: ${selectedVendorData.address}
Mobile Number: ${selectedVendorData.mobileNo}
Material Type: $itemKey
Category:  ${selectedCategory}(${selectedUnit})
Date:${dateController.text}
Quantity: ${quantityController.text}
Price: ₹${amountController.text}
""";}



         else if(commonSuccessResponseModel.data!.materialOrder!.imageUrl !=null){


           message = """
*SS Builders*
Site Name: ${args.siteName} - Material Order
Location: ${args.siteLocation}
Vendor Name: ${selectedVendorData.name}
Vendor Address: ${selectedVendorData.address}
Mobile Number: ${selectedVendorData.mobileNo}
Material Type: $itemKey
Units:  ${selectedUnit}
Date:${dateController.text}
Quantity: ${quantityController.text}
Price: ₹${amountController.text}
Attachment: ${commonSuccessResponseModel.data!.materialOrder!.imageUrl}
""";

         }

         else{
           message = """
*SS Builders*
Site Name: ${args.siteName} - Material Order
Location: ${args.siteLocation}
Vendor Name: ${selectedVendorData.name}
Vendor Address: ${selectedVendorData.address}
Mobile Number: ${selectedVendorData.mobileNo}
Material Type: $itemKey
Units:  ${selectedUnit}
Date:${dateController.text}
Quantity: ${quantityController.text}
Price: ₹${amountController.text}
""";
         }

         whatappUrls = "https://wa.me/${selectedVendorData.mobileNo}?text=${Uri.encodeComponent(message)}";

       }

       extractAndOpenWhatsApp(whatappUrls);
       showToastMessage(commonSuccessResponseModel.message??"");
       Get.back();
     }
     else{
       showToastMessage(commonSuccessResponseModel.message??"");

     }
   }

  }*/

  void setUnits(List<dynamic>? list, {bool hasAttachment = false}) {
    if (hasAttachment) {
      units.clear(); // ✅ if attachment true, clear
    } else {
      units = list?.map((e) => e.toString()).toList() ?? [];
    }
  }

  // Example method to clear attachment

}