import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io' as dart_io;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api/api_data.dart';
import '../../model/unit_master_model.dart';
import '../../model/purchase_bill_model.dart';
import '../../utils/res/sendWhatsAppMessage.dart';
class PurchaseBillItem {
  TextEditingController particular = TextEditingController();
  TextEditingController count = TextEditingController();
  String? selectedUnit;
  TextEditingController amount = TextEditingController(); // this is Rate
  TextEditingController total = TextEditingController();
}
class PurchaseBillController extends GetxController {
  // Site ID passed via arguments
  late int siteId;

  // Form controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  final TextEditingController termsTitleController = TextEditingController();
  final TextEditingController termsController = TextEditingController();
  final GlobalKey autocompleteKey = GlobalKey();

  // New PO Fields
  TextEditingController vendorGstNoController = TextEditingController();
  TextEditingController projectRefNumberController = TextEditingController();
  TextEditingController poNumberController = TextEditingController();
  TextEditingController descriptionOfWorkController = TextEditingController();
  TextEditingController descriptionOfMaterialsController = TextEditingController();
  TextEditingController recommendedFirmController = TextEditingController();
  TextEditingController paymentTermsController = TextEditingController();
  TextEditingController scheduledDateFromController = TextEditingController();
  TextEditingController scheduledDateToController = TextEditingController();
  TextEditingController deliveryAddressController = TextEditingController();
  TextEditingController siteContactPersonController = TextEditingController();
  TextEditingController siteContactMobileController = TextEditingController();
  TextEditingController gstPercentageController = TextEditingController(text: '18');

  var subTotalAmount = 0.0.obs;
  var gstAmount = 0.0.obs;

  Future<List<String>> getTermsSuggestions(String query) async {
    if (query.isEmpty) return [];
    return await ApiData().termsConditionSearchApi(query);
  }

  Future<void> onTermsSelected(String title) async {
    final desc = await ApiData().termsConditionDescriptionApi(title);
    if (desc.isNotEmpty) {
      termsController.text = desc;
      update();
    }
  }
  
  FocusNode vendorFocusNode = FocusNode();

  // Vendor List
  List<VendorInfo> vendors = [];
  List<VendorInfo> filteredVendors = [];
  VendorInfo? selectedVendor;
  bool isVendorListVisible = false;

  // Unit Master List
  List<UnitMasterData> unitMasterList = [];

  // Particulars list
  var itemList = <PurchaseBillItem>[].obs;

  // Total
  var totalAmount = 0.0.obs;

  // Loading
  var isFormLoading = false.obs;
  var isSubmitLoading = false.obs;

  // Date Parsing helper
  DateTime parsedDate = DateTime.now();

  @override
  void onInit() {
    siteId = Get.arguments as int;
    // Add one blank row by default
    itemList.add(PurchaseBillItem());
    // Set today's date
    dateController.text = DateFormat('dd-MM-yyyy').format(parsedDate);
    // Load form details (pre-fill vendor info)
    _loadFormDetails();

    vendorFocusNode.addListener(() {
      if (vendorFocusNode.hasFocus) {
        isVendorListVisible = true;
      } else {
        // Use a short delay so tap on list item can register before it hides
        Future.delayed(const Duration(milliseconds: 150), () {
          isVendorListVisible = false;
          update();
        });
      }
      update();
    });
    super.onInit();
  }
  @override
  void onClose() {
    vendorFocusNode.dispose();
    super.onClose();
  }

  void resetForm() {
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    parsedDate = DateTime.now();
    dateController.text = DateFormat('dd-MM-yyyy').format(parsedDate);
    subjectController.clear();
    locationController.clear();
    termsTitleController.clear();
    termsController.clear();
    itemList.clear();
    itemList.add(PurchaseBillItem());
    selectedVendor = null;
    isVendorListVisible = false;
    filteredVendors = List.from(vendors);
    recalcTotal();
    update();
  }
  Future<void> _loadFormDetails() async {
    isFormLoading.value = true;
    update();
    try {
      final res = await ApiData().purchaseBillFormApi(siteId);
      final vendorRes = await ApiData().vendorManagementList();

      print("DEBUG: Form API Status: ${res?.status}");
      print("DEBUG: Vendor API Status: ${vendorRes?.status}");

      if (res != null && res.status == true) {
        // Prefill location from site if empty
        if (locationController.text.isEmpty && res.data?.site?.location != null) {
          locationController.text = res.data!.site!.location!;
        }
      }

      if (vendorRes != null && vendorRes.status == true && vendorRes.data != null) {
        vendors = vendorRes.data!.map((v) => VendorInfo(
          id: v.id,
          name: v.name,
          mobileNo: v.mobileNo,
          email: v.email,
          address: v.address,
        )).toList();
        filteredVendors = List.from(vendors);
        print("DEBUG: Controller stored vendors count: ${vendors.length}");
      } else {
        print("DEBUG: Vendor API returned empty or null data");
      }

      // Fetch Unit Master List
      final unitRes = await ApiData().unitMasterListApi();
      if (unitRes != null && unitRes.status == true && unitRes.data != null) {
        unitMasterList = unitRes.data!;
      }
    } catch (e) {
      print("DEBUG: Exception in _loadFormDetails: $e");
    } finally {
      isFormLoading.value = false;
      update();
    }
  }

  void onVendorSelected(VendorInfo vendor) {
    selectedVendor = vendor;
    nameController.text = vendor.name ?? '';
    mobileController.text = vendor.mobileNo ?? '';
    emailController.text = vendor.email ?? '';
    if (vendor.address != null && vendor.address!.isNotEmpty) {
      locationController.text = vendor.address!;
    }
    isVendorListVisible = false;
    vendorFocusNode.unfocus();
    update();
  }

  void filterVendors(String query) {
    print("DEBUG: filterVendors called with query: '$query'");
    if (query.isEmpty) {
      filteredVendors = List.from(vendors);
    } else {
      filteredVendors = vendors.where((v) {
        final nameMatches = v.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
        final mobileMatches = v.mobileNo?.contains(query) ?? false;
        return nameMatches || mobileMatches;
      }).toList();
    }
    update();
  }

  void addItem() {
    itemList.add(PurchaseBillItem());
    update();
  }

  void removeItem(int index) {
    if (itemList.length > 1) {
      itemList.removeAt(index);
      recalcTotal();
    }
  }

  void recalcTotal() {
    double sum = 0;
    for (var item in itemList) {
      double countVal = double.tryParse(item.count.text) ?? 0.0;
      double rateVal = double.tryParse(item.amount.text) ?? 0.0;
      double itemTotal = countVal * rateVal;
      
      // Update the read-only total controller for this item
      if (item.count.text.isNotEmpty && item.amount.text.isNotEmpty) {
        item.total.text = itemTotal.toStringAsFixed(2);
      } else {
        item.total.clear();
      }
      
      sum += itemTotal;
    }
    
    subTotalAmount.value = sum;
    double gstPercent = double.tryParse(gstPercentageController.text) ?? 0.0;
    gstAmount.value = sum * (gstPercent / 100);
    totalAmount.value = sum;
    update();
  }

  Map<String, dynamic> _buildPayload({String? email}) {
    final particulars = itemList.map((i) => i.particular.text.trim()).toList();
    final counts = itemList.map((i) => i.count.text.trim()).toList();
    final units = itemList.map((i) => i.selectedUnit ?? '').toList();
    final amounts = itemList.map((i) => i.amount.text.trim()).toList();

    return {
      'site_id': siteId,
      'name': nameController.text.trim(),
      'subject': subjectController.text.trim(),
      'date': DateFormat('yyyy-MM-dd').format(parsedDate),
      'mobile_no': mobileController.text.trim(),
      'location': locationController.text.trim(),
      if (termsController.text.isNotEmpty) 'terms_conditions': termsController.text.trim(),
      if (email != null && email.isNotEmpty) 'email': email,
      if (selectedVendor != null) 'vendor_id': selectedVendor!.id,
      
      // New PO Fields mapping
      if (vendorGstNoController.text.isNotEmpty) 'vendor_gst_no': vendorGstNoController.text.trim(),
      if (projectRefNumberController.text.isNotEmpty) 'project_ref_number': projectRefNumberController.text.trim(),
      if (poNumberController.text.isNotEmpty) 'po_number': poNumberController.text.trim(),
      if (descriptionOfWorkController.text.isNotEmpty) 'description_of_work': descriptionOfWorkController.text.trim(),
      if (descriptionOfMaterialsController.text.isNotEmpty) 'description_of_materials': descriptionOfMaterialsController.text.trim(),
      if (recommendedFirmController.text.isNotEmpty) 'recommended_firm': recommendedFirmController.text.trim(),
      if (paymentTermsController.text.isNotEmpty) 'payment_terms': paymentTermsController.text.trim(),
      if (scheduledDateFromController.text.isNotEmpty) 'scheduled_date_from': DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(scheduledDateFromController.text.trim())),
      if (scheduledDateToController.text.isNotEmpty) 'scheduled_date_to': DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(scheduledDateToController.text.trim())),
      if (deliveryAddressController.text.isNotEmpty) 'delivery_address': deliveryAddressController.text.trim(),
      if (siteContactPersonController.text.isNotEmpty) 'site_contact_person': siteContactPersonController.text.trim(),
      if (siteContactMobileController.text.isNotEmpty) 'site_contact_mobile': siteContactMobileController.text.trim(),
      if (gstPercentageController.text.isNotEmpty) 'gst_percentage': gstPercentageController.text.trim(),

      'particular': particulars,
      'count': counts,
      'unit': units,
      'amount': amounts,
    };
  }

  Future<PurchaseBillStoredModel?> _submitBill({String? email}) async {
    isSubmitLoading.value = true;
    update();
    try {
      final payload = _buildPayload(email: email);
      print('📦 PurchaseBill PAYLOAD: $payload');
      return await ApiData().purchaseBillAddApi(payload);
    } catch (e) {
      print('Error submitting purchase bill: $e');
      return null;
    } finally {
      isSubmitLoading.value = false;
      update();
    }
  }

  Future<void> sendWhatsApp() async {
    final res = await _submitBill();
    if (res == null || res.status != true) {
      Get.snackbar('Error', res?.message ?? 'Failed to generate Purchase Bill.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    final url = res.whatsappUrl;
    if (url != null && url.isNotEmpty) {
      extractAndOpenWhatsApp(url);
    } else {
      Get.snackbar('Error', 'WhatsApp URL not available.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> sendMail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Email Required', 'Please enter an email address.',
          backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return;
    }
    final res = await _submitBill(email: email);
    if (res == null || res.status != true) {
      Get.snackbar('Error', res?.message ?? 'Failed to send mail.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    if (res.mailSent == true) {
      Get.snackbar('Success', 'Purchase Bill mail sent successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('Info', res.message ?? 'Bill created. Mail status unavailable.',
          backgroundColor: Colors.blueGrey, colorText: Colors.white);
    }
  }

  Future<void> downloadPdf() async {
    final res = await _submitBill();
    if (res == null || res.status != true) {
      Get.snackbar('Error', res?.message ?? 'Failed to generate PDF.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    final pdfUrl = res.pdfUrl;
    if (pdfUrl != null && pdfUrl.isNotEmpty) {
      final Uri uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Cannot open PDF URL.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } else {
      Get.snackbar('Error', 'PDF URL not available.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
