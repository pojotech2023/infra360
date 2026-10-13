import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/vendor_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

import '../../../base_url.dart';
import '../../../model/login_response.dart';
import '../../../model/material_details_argument_model.dart';
import '../../../model/units_model.dart';
import '../../../service/shared_preference_service.dart';
import '../../../utils/res/sendWhatsAppMessage.dart';
import '../bricks_details_controller.dart';

class NewRequestController extends GetxController{

  MaterialDetailsArgs args = Get.arguments;

  RxList<VendorData> getBricksLists = <VendorData>[].obs;
  RxList<UnitsData> getUnitsLists = <UnitsData>[].obs;


  late LoginResponse userDetails;
  VendorData? selectedVendorData;
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
  TextEditingController gstController = TextEditingController();
  TextEditingController vendorGstController = TextEditingController();
  TextEditingController invoiceNoController = TextEditingController();

  TextEditingController specificationController = TextEditingController();
  TextEditingController itemsController = TextEditingController();

  List<String> units = List<String>.empty(growable: true);
  List<String> categories = List<String>.empty(growable: true);
  Rxn<String> selectedCategory = Rxn<String>();
  Rxn<String> selectedBrickType = Rxn<String>();

  RxList<InwardOrderItemModel> inwardOrderItems = <InwardOrderItemModel>[].obs;

  var itemKey  = ''.obs;

  void addInwardOrderItem() {
    inwardOrderItems.add(InwardOrderItemModel(
      defaultUnit: units.isNotEmpty ? units.first : 'Nos',
      defaultGst: 18.0,
    ));
    update();
  }

  void removeInwardOrderItem(int index) {
    if (inwardOrderItems.length > 1) {
      inwardOrderItems.removeAt(index);
      update();
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  void syncItemsField() {
    final matName = _capitalize(itemKey.value.isNotEmpty ? itemKey.value : 'Bricks');
    final typeName = selectedBrickType.value ?? selectedCategory.value ?? '';
    final spec = specificationController.text.trim();

    if (typeName.isNotEmpty && spec.isNotEmpty) {
      itemsController.text = "$matName - $typeName ($spec)";
    } else if (typeName.isNotEmpty) {
      itemsController.text = "$matName - $typeName";
    } else if (spec.isNotEmpty) {
      itemsController.text = "$matName ($spec)";
    } else {
      itemsController.text = matName;
    }
  }

  @override
  void onInit() {
    getVendorApi("");
    print("-------------${args.id}");

    itemKey.value = args.itemKey;

    final data = jsonDecode(PreferenceUtils().getUserInfo());
    userDetails = LoginResponse.fromJson(data);

    // Reset dropdown state to avoid cross-category assertion crashes
    selectedBrickType.value = null;
    selectedCategory.value = null;
    selectedVendorData = null;
    specificationController.clear();
    syncItemsField();

    materialUnitsListApi();
    supervisorNameController.text = args.supervisorName;
    supervisorMobController.text = args.supervisorMob;

    // Initialize 1 row for Inward Order
    if (inwardOrderItems.isEmpty) {
      inwardOrderItems.add(InwardOrderItemModel());
    }

    super.onInit();
  }

  getVendorApi(String vendorName)async{
   VendorModel ?vendorModel= await ApiData().vendorApi(vendorName);

   if(vendorModel!=null){
     getBricksLists.value=vendorModel.data??[];
   }
  }

  static List<String> getSubItemsForMaterial(String rawKey) {
    final key = rawKey.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    if (key.contains('brick') || key.contains('block')) {
      return [
        'Red Clay Brick',
        'Fly Ash Bricks',
        'AAC Blocks (Autoclaved Aerated Concrete)',
        'Solid Concrete Blocks',
        'Hollow Concrete Blocks',
        'Wire Cut Bricks',
        'Clay Paver Bricks',
        'Stone / Rubble',
      ];
    } else if (key.contains('electric') || key.contains('wire') || key.contains('cable')) {
      return [
        '1.0 sq mm Wire',
        '1.5 sq mm Wire',
        '2.5 sq mm Wire',
        '4.0 sq mm Wire',
        'PVC Conduit Pipes',
        'Modular Switches & Sockets',
        'MCB & Distribution Board',
        'LED Lights & Fixtures',
      ];
    } else if (key.contains('jally') || key.contains('aggregate') || key.contains('gravel')) {
      return [
        '10mm Aggregate (Chips)',
        '20mm Aggregate (Roofing & Columns)',
        '40mm Aggregate (Foundations)',
        'GSB (Granular Sub Base)',
        'Quarry Dust',
        'Stone Boulder',
      ];
    } else if (key.contains('cement')) {
      return [
        'OPC 53 Grade',
        'OPC 43 Grade',
        'PPC (Portland Pozzolana Cement)',
        'White Cement',
        'Waterproof Cement',
        'Rapid Hardening Cement',
        'Slag Cement',
      ];
    } else if (key.contains('steel') || key.contains('tmt')) {
      return [
        'TMT 8mm',
        'TMT 10mm',
        'TMT 12mm',
        'TMT 16mm',
        'TMT 20mm',
        'TMT 25mm',
        'Binding Wire',
        'MS Flat / Angle',
        'Structural Steel (Beams / Channels)',
      ];
    } else if (key.contains('sand')) {
      return [
        'M-Sand (Manufactured Sand for Concreting)',
        'P-Sand (Plastering Sand)',
        'River Sand',
        'Pit Sand / Filling Sand',
      ];
    } else if (key.contains('tile')) {
      return [
        'Vitrified Floor Tiles (2x2 ft)',
        'Vitrified Floor Tiles (4x2 ft)',
        'Ceramic Wall Tiles',
        'Anti-Skid Bathroom Tiles',
        'Parking / Exterior Paver Tiles',
        'Kitchen Dado Tiles',
        'Step & Riser Tiles',
      ];
    } else if (key.contains('granite') || key.contains('marble')) {
      return [
        'Black Galaxy Granite',
        'Tan Brown Granite',
        'Jet Black Granite',
        'Kashmir White Granite',
        'Steel Grey Granite',
        'Ruby Red Granite',
        'Indian Marble Slabs',
      ];
    } else if (key.contains('door') || key.contains('window') || key.contains('wood') || key.contains('timber')) {
      return [
        'Flush Doors',
        'Panel Doors (Teak / Wood)',
        'UPVC Windows',
        'Aluminum Sliding Windows',
        'Teak Wood',
        'Sal Wood',
        'Plywood (Commercial MR)',
        'Plywood (Marine / BWP)',
        'MDF / Particle Board',
      ];
    } else if (key.contains('paint')) {
      return [
        'Wall Putty',
        'Interior Primer',
        'Exterior Primer',
        'Interior Emulsion',
        'Exterior Apex Emulsion',
        'Enamel Paint (Wood & Metal)',
        'Waterproofing Chemical',
      ];
    } else if (key.contains('plumb')) {
      return [
        'CPVC Pipes & Fittings',
        'UPVC Pipes & Fittings',
        'PVC Drainage Pipes',
        'Water Storage Tank (Sintex / Overhead)',
        'Sanitaryware / WC / Wash Basins',
        'Taps, Valves & Faucets',
      ];
    } else if (key.contains('rmc') || key.contains('concrete')) {
      return [
        'M15 Concrete',
        'M20 Concrete',
        'M25 Concrete',
        'M30 Concrete',
        'M35 Concrete',
        'M40 Concrete',
      ];
    }
    return [
      'Standard Type',
      'General Item',
    ];
  }

  static String getDefaultUnitForMaterial(String rawKey) {
    final key = rawKey.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (key.contains('brick') || key.contains('block')) return 'Nos';
    if (key.contains('cement')) return 'Bags';
    if (key.contains('steel') || key.contains('tmt')) return 'Ton';
    if (key.contains('sand') || key.contains('jally') || key.contains('aggregate') || key.contains('gravel')) return 'Units';
    if (key.contains('tile') || key.contains('granite') || key.contains('marble') || key.contains('interior')) return 'Sq.Ft';
    if (key.contains('electric') || key.contains('wire') || key.contains('cable')) return 'Coil';
    if (key.contains('paint')) return 'Litre';
    if (key.contains('wood') || key.contains('timber') || key.contains('door') || key.contains('window')) return 'Nos';
    if (key.contains('rmc') || key.contains('concrete')) return 'Cum';
    if (key.contains('lorry') || key.contains('transport')) return 'Load';
    return 'Nos';
  }

  Future<void> materialUnitsListApi() async {
    try {
      final unitRes = await ApiData().unitMasterListApi();
      units.clear();
      
      if (unitRes != null && unitRes.data != null) {
        units.addAll(unitRes.data!.map((u) => u.unitName ?? '').where((u) => u.isNotEmpty));
      }

      // Also fetch categories if needed
      UnitsModel? model = await ApiData().materialUnitsListApi();
      categories.clear();

      if (model != null && model.data != null) {
        getUnitsLists.value = model.data ?? [];
        UnitsData? matchedMaterial;
        final rawKey = args.itemKey.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        try {
          matchedMaterial = getUnitsLists.firstWhere(
            (element) {
              final elemKey = (element.materialType ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
              return elemKey == rawKey || (rawKey.isNotEmpty && elemKey.contains(rawKey)) || (elemKey.isNotEmpty && rawKey.contains(elemKey));
            }
          );
        } catch (_) {}
        
        if (matchedMaterial != null && matchedMaterial.categoryName != null && matchedMaterial.categoryName!.isNotEmpty) {
          categories.addAll(matchedMaterial.categoryName!);
        }
      }
      
      // Fallback to our comprehensive catalog for the specific material
      if (categories.isEmpty) {
        categories.addAll(getSubItemsForMaterial(args.itemKey));
      }
      
      // Ensure categories are de-duplicated
      categories = categories.toSet().toList();

      if (units.isEmpty) {
        units.addAll(['Nos', 'Units', 'Bags', 'Ton', 'Kg', 'Sq.Ft', 'Cft', 'Cum', 'Coil', 'Litre']);
      }
      units = units.toSet().toList();

      if (selectedUnit.value.isEmpty) {
        final defUnit = getDefaultUnitForMaterial(args.itemKey);
        selectedUnit.value = units.contains(defUnit) ? defUnit : units.first;
      }
      
      syncItemsField();
      
      print("✅ Units: $units");
      print("✅ Categories for ${args.itemKey}: $categories");
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

    // Check if this is an edit operation
    final isEdit = Get.arguments is MaterialDetailsArgs && 
                   (Get.arguments as MaterialDetailsArgs).editItem != null;
    final editItem = isEdit ? (Get.arguments as MaterialDetailsArgs).editItem : null;

    final chosenType = selectedBrickType.value ?? selectedCategory.value ?? '';
    final spec = specificationController.text.trim();

    final reqItems = [
      {
        "name": chosenType.isNotEmpty ? chosenType : itemKey,
        "item_name": chosenType.isNotEmpty ? chosenType : itemKey,
        "category": chosenType.isNotEmpty ? chosenType : itemKey,
        "category_name": chosenType.isNotEmpty ? chosenType : itemKey,
        "specification": spec,
        "spec": spec,
        "size": spec,
        "size_specification": spec,
        "quantity": quantityController.text.trim(),
        "unit": selectedUnit.value,
        "price": amountController.text.trim(),
        "rate": amountController.text.trim(),
        "gst": gstController.text.isNotEmpty ? gstController.text : "0",
        "total": amountController.text.trim(),
      }
    ];

    final summaryStr = spec.isNotEmpty
        ? "$chosenType ($spec) [${quantityController.text.trim()} ${selectedUnit.value}]"
        : "$chosenType [${quantityController.text.trim()} ${selectedUnit.value}]";

    // ------------------ COMMON MAP ------------------
    Map<String, String> requestData = {
      "site_id": siteId.toString(),
      "material_type": itemKey,
      "items": summaryStr.isNotEmpty ? summaryStr : (itemsController.text.isNotEmpty ? itemsController.text : itemKey),
      "item_name": itemsController.text.isNotEmpty ? itemsController.text : itemKey,
      "category": chosenType,
      "category_name": chosenType,
      "specification": spec,
      "spec": spec,
      "size": spec,
      "size_specification": spec,
      "size_spec": spec,
      "price": amountController.text.trim(),
      "quantity": quantityController.text.trim(),
      "unit": selectedUnit.value,
      "date_of_delivery": dateController.text.trim(), // Backend requires d-m-Y format
      "amount": amountController.text.trim(),
      "gst": gstController.text.isNotEmpty ? gstController.text : "0",
      "supervisor_name": supervisorNameController.text.trim(),
      "supervisor_mobile": supervisorMobController.text.trim(),
      "items_summary": summaryStr,
      //"remarks": reMarksController.text,
    };

    // Add vendor_id for all roles (if selected)
    if (selectedVendorData != null) {
      requestData["vendor_id"] = selectedVendorData!.id.toString();
    }

    // ------------------ ORDER MAP ------------------
    Map<String, String> orderData = {
      "site_id": siteId.toString(),
      "material_type": itemKey,
      "category": chosenType,
      "category_name": chosenType,
      "specification": spec,
      "spec": spec,
      "size": spec,
      "size_specification": spec,
      "size_spec": spec,
      "quantity": quantityController.text.trim(),
      "date": dateController.text.trim(), // Backend requires d-m-Y format
      "unit": selectedUnit.value,
      "price": amountController.text.trim(),
      "gst": gstController.text.isNotEmpty ? gstController.text : "0",
      "supervisor_name": supervisorNameController.text.trim(),
      "supervisor_mobile": supervisorMobController.text.trim(),
      "items": jsonEncode(reqItems),
      "items_summary": summaryStr,
    };

    if (type == 2 && selectedVendorData != null) {
      orderData["vendor_id"] = selectedVendorData!.id.toString();
    }

    // ------------------ EDIT MODE: Use update API ------------------
    if (isEdit && editItem != null && type == 2) {
      CommonSuccessResponseModel? res = await ApiData().updateMaterialApi(editItem.id!, orderData);
      if (res != null && res.status == true) {
        showToastMessage(res.message ?? "Updated successfully");
        try {
          final parentController = Get.find<BricksDetailsController>();
          parentController.fetchData();
        } catch (_) {}
        Get.back();
      } else {
        showToastMessage(res?.message ?? "Failed to update");
      }
      return;
    }

    // ------------------ FINAL POST DATA ------------------
    final postedData = type == 1 ? requestData : orderData;
    final apiUrl = type == 1 ? "request-order" : "add-order";

    dynamic res = await ApiData()
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
*Pojo infra 360*
Site Name: ${args.siteName} - $title
Location: ${args.siteLocation}
${showVendorDetails ? "Vendor Name: ${selectedVendorData?.name ?? 'N/A'}\n" : ""}
${showVendorDetails ? "Vendor Address: ${selectedVendorData?.address ?? 'N/A'}\n" : ""}
${showVendorDetails ? "Vendor Mobile: ${selectedVendorData?.mobileNo ?? 'N/A'}\n" : ""}
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
    if (type == 2) {
      // DO NOT send to WhatsApp for Inward Orders
      showToastMessage(res.message ?? "Inward Order added successfully.");
      Get.back();
    } else if (type == 1 && role == 'supervisor') {
      // DO NOT send to WhatsApp immediately for Material Requests by Supervisor.
      showToastMessage(res.message ?? "Request submitted to Admin for approval.");
      Get.back();
    } else {
      // Use the selected vendor's phone number for all cases where WhatsApp is opened
      String phone = selectedVendorData?.mobileNo?.toString().trim() ?? "7540060694";
      
      // Clean up phone number (remove spaces, dashes, etc.)
      phone = phone.replaceAll(RegExp(r'[ \-\(\)]'), '');
      
      // WhatsApp requires country code. If it's a 10-digit Indian number, add +91
      if (phone.length == 10 && !phone.startsWith('+')) {
        phone = '+91$phone';
      }

      String whatsappUrl =
          "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";

      extractAndOpenWhatsApp(whatsappUrl);

      showToastMessage(res.message ?? "");
      Get.back();
    }
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
*Pojo infra 360*
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
*Pojo infra 360*
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
*Pojo infra 360*
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
*Pojo infra 360*
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
*Pojo infra 360*
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
*Pojo infra 360*
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

  Future<bool> submitInwardOrder(File? invoiceFile) async {
    if (selectedVendorData == null) {
      showToastMessage("Please select a Vendor");
      return false;
    }
    if (dateController.text.trim().isEmpty) {
      showToastMessage("Please select Date");
      return false;
    }
    if (selectedBrickType.value == null || selectedBrickType.value!.isEmpty) {
      showToastMessage("Please select Brick / Block Type");
      return false;
    }

    final validItems = inwardOrderItems.where((i) => i.quantity > 0 && i.pricePerItem > 0).toList();
    if (validItems.isEmpty) {
      showToastMessage("Please enter Quantity and Price for at least one item");
      return false;
    }

    double totalQuantity = 0.0;
    double totalBasePrice = 0.0;
    double totalGstAmount = 0.0;

    List<Map<String, dynamic>> itemsPayload = [];
    List<String> summaryParts = [];

    for (var itm in validItems) {
      totalQuantity += itm.quantity;
      totalBasePrice += itm.basePrice;
      totalGstAmount += itm.gstAmount;

      final typeName = selectedBrickType.value ?? itemKey.value;
      final spec = itm.specCtrl.text.trim();
      final displayName = spec.isNotEmpty ? "$typeName ($spec)" : typeName;

      itemsPayload.add({
        "name": typeName,
        "item_name": typeName,
        "category": typeName,
        "category_name": typeName,
        "specification": spec,
        "spec": spec,
        "size": spec,
        "size_specification": spec,
        "quantity": itm.quantity.toString().replaceAll(RegExp(r'\.0$'), ''),
        "unit": itm.unit.value,
        "price": itm.pricePerItem.toStringAsFixed(2),
        "rate": itm.pricePerItem.toStringAsFixed(2),
        "gst": itm.gst.value.toString(),
        "gst_amount": itm.gstAmount.toStringAsFixed(2),
        "total": itm.totalInclGst.toStringAsFixed(2),
      });

      summaryParts.add("$displayName [${itm.quantity.toString().replaceAll(RegExp(r'\.0$'), '')} ${itm.unit.value}]");
    }

    final grandTotal = totalBasePrice + totalGstAmount;
    final itemsSummary = summaryParts.join(", ");

    final firstSpec = validItems.first.specCtrl.text.trim();

    final Map<String, String> payload = {
      "site_id": args.id.toString(),
      "vendor_id": selectedVendorData!.id.toString(),
      "material_type": itemKey.value.toLowerCase(),
      "category": selectedBrickType.value ?? itemKey.value,
      "category_name": selectedBrickType.value ?? itemKey.value,
      "specification": firstSpec,
      "spec": firstSpec,
      "size": firstSpec,
      "size_specification": firstSpec,
      "size_spec": firstSpec,
      "quantity": totalQuantity.toString().replaceAll(RegExp(r'\.0$'), ''),
      "unit": validItems.first.unit.value,
      "price": totalBasePrice.toStringAsFixed(2),
      "gst": totalGstAmount.toStringAsFixed(2),
      "amount": grandTotal.toStringAsFixed(2),
      "supervisor_name": supervisorNameController.text.trim(),
      "supervisor_mobile": supervisorMobController.text.trim(),
      "date": dateController.text.trim(),
      if (invoiceNoController.text.trim().isNotEmpty) "invoice_no": invoiceNoController.text.trim(),
      "items": jsonEncode(itemsPayload),
      "items_summary": itemsSummary,
    };

    for (int i = 0; i < itemsPayload.length; i++) {
      final itm = itemsPayload[i];
      payload["items[$i][name]"] = itm["name"];
      payload["items[$i][item_name]"] = itm["item_name"];
      payload["items[$i][category]"] = itm["category"];
      payload["items[$i][category_name]"] = itm["category_name"];
      payload["items[$i][specification]"] = itm["specification"] ?? "";
      payload["items[$i][spec]"] = itm["specification"] ?? "";
      payload["items[$i][size]"] = itm["specification"] ?? "";
      payload["items[$i][size_specification]"] = itm["specification"] ?? "";
      payload["items[$i][quantity]"] = itm["quantity"];
      payload["items[$i][unit]"] = itm["unit"];
      payload["items[$i][price]"] = itm["price"];
      payload["items[$i][rate]"] = itm["rate"];
      payload["items[$i][gst]"] = itm["gst"];
      payload["items[$i][gst_amount]"] = itm["gst_amount"];
      payload["items[$i][total]"] = itm["total"];
    }

    final bool isEdit = args.editItem != null;
    print("📤 Submitting inward order (isEdit=$isEdit) payload: $payload");

    dynamic res;
    if (isEdit) {
      res = await ApiData().updateMaterialApi(args.editItem!.id!, payload, attachment: invoiceFile);
    } else {
      res = await ApiData().bricksRequestApi("$baseUrl" "add-order", payload, invoiceFile);
    }

    if (res == null) {
      showToastMessage("Submission failed. Please check network connection.");
      return false;
    }

    if (res.status != true) {
      showToastMessage(res.message ?? "Operation failed");
      return false;
    }

    showToastMessage(res.message ?? (isEdit ? "Inward Order updated successfully." : "Inward Order added successfully."));
    try {
      final parent = Get.find<BricksDetailsController>();
      parent.fetchData();
    } catch (_) {}
    Get.back(result: true);
    return true;
  }
}

class InwardOrderItemModel {
  final TextEditingController specCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController priceCtrl;
  final RxString unit;
  final RxDouble gst;

  InwardOrderItemModel({
    String spec = '',
    String qty = '',
    String price = '',
    String defaultUnit = 'Nos',
    double defaultGst = 18.0,
  })  : specCtrl = TextEditingController(text: spec),
        qtyCtrl = TextEditingController(text: qty),
        priceCtrl = TextEditingController(text: price),
        unit = defaultUnit.obs,
        gst = defaultGst.obs;

  double get quantity => double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
  double get pricePerItem => double.tryParse(priceCtrl.text.trim()) ?? 0.0;
  double get basePrice => quantity * pricePerItem;
  double get gstAmount => basePrice * (gst.value / 100.0);
  double get totalInclGst => basePrice + gstAmount;
}
