import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/model/all_materials_data_model.dart';
import 'package:raptor_pro/model/login_response.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/model/vendor_model.dart';
import 'package:raptor_pro/service/shared_preference_service.dart';
import 'package:raptor_pro/utils/file_picker_helper.dart';
import 'package:raptor_pro/utils/res/sendWhatsAppMessage.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

class AllMaterialsController extends GetxController {
  final MaterialDetailsArgs args;

  AllMaterialsController({required this.args});

  // ── Tabs (0: Inward Order, 1: Material Request) ──
  final RxInt selectedTabIndex = 0.obs;

  // ── User Role ──
  late LoginResponse userDetails;
  String get userRole => userDetails.data?.role?.toLowerCase() ?? '';
  bool get isAdmin => userRole == 'admin';

  // ── Vendors ──
  final RxList<VendorData> vendorsList = <VendorData>[].obs;
  final RxBool isLoadingVendors = false.obs;
  final Rxn<VendorData> selectedVendor = Rxn<VendorData>();

  final TextEditingController vendorSearchController = TextEditingController();
  final TextEditingController vendorMobileController = TextEditingController();
  final TextEditingController vendorAddressController = TextEditingController();
  final TextEditingController vendorGstController = TextEditingController();

  // ── Tier 2: Selected Material Categories ──
  final RxList<String> selectedCategorySlugs = <String>[].obs;

  // ── Tier 3 & 4: Order Items ──
  final RxList<AllMaterialOrderItem> orderItems = <AllMaterialOrderItem>[].obs;

  // ── Step 4 / Dispatch Form Controllers ──
  final TextEditingController dateController = TextEditingController();
  final TextEditingController manualQuantityController = TextEditingController();
  final TextEditingController manualPriceController = TextEditingController();
  final TextEditingController supervisorNameController = TextEditingController();
  final TextEditingController supervisorMobController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController deliveryNeededByController = TextEditingController();

  // ── Attachment / Invoice ──
  final Rxn<File> invoiceFile = Rxn<File>();
  final RxString invoiceFileName = ''.obs;

  // ── Submission State ──
  final RxBool isSubmitting = false.obs;

  // Reactive trigger for table calculations
  final RxInt calculationTrigger = 0.obs;

  @override
  void onInit() {
    super.onInit();

    try {
      final data = jsonDecode(PreferenceUtils().getUserInfo());
      userDetails = LoginResponse.fromJson(data);
    } catch (_) {}

    // Initial date: today
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Pre-fill supervisor
    supervisorNameController.text = args.supervisorName;
    supervisorMobController.text = args.supervisorMob;

    manualQuantityController.addListener(() {
      calculationTrigger.value++;
    });
    manualPriceController.addListener(() {
      calculationTrigger.value++;
    });

    fetchVendors("");
  }

  @override
  void onClose() {
    vendorSearchController.dispose();
    vendorMobileController.dispose();
    vendorAddressController.dispose();
    vendorGstController.dispose();
    dateController.dispose();
    manualQuantityController.dispose();
    manualPriceController.dispose();
    supervisorNameController.dispose();
    supervisorMobController.dispose();
    remarksController.dispose();
    deliveryNeededByController.dispose();

    for (var item in orderItems) {
      item.dispose();
    }
    super.onClose();
  }

  // ── Fetch Vendors ──
  Future<void> fetchVendors(String query) async {
    try {
      isLoadingVendors.value = true;
      final res = await ApiData().vendorApi(query);
      if (res != null && res.data != null) {
        vendorsList.assignAll(res.data!);
      }
    } catch (e) {
      print("❌ Error fetching vendors: $e");
    } finally {
      isLoadingVendors.value = false;
    }
  }

  // ── Select Vendor ──
  void selectVendor(VendorData vendor) {
    selectedVendor.value = vendor;
    vendorSearchController.text = vendor.name ?? '';
    vendorMobileController.text = vendor.mobileNo ?? '';
    vendorAddressController.text = vendor.address ?? '';
    vendorGstController.text = vendor.gst ?? '';
  }

  void clearVendor() {
    selectedVendor.value = null;
    vendorSearchController.clear();
    vendorMobileController.clear();
    vendorAddressController.clear();
    vendorGstController.clear();
  }

  // ── Tier 2: Category Toggle ──
  void toggleCategory(String slug) {
    if (selectedCategorySlugs.contains(slug)) {
      selectedCategorySlugs.remove(slug);
      // Remove all items for this category from table
      final itemsToRemove = orderItems.where((i) => i.categorySlug == slug).toList();
      for (var item in itemsToRemove) {
        orderItems.remove(item);
        item.dispose();
      }
    } else {
      selectedCategorySlugs.add(slug);
    }
    calculationTrigger.value++;
  }

  bool isCategorySelected(String slug) => selectedCategorySlugs.contains(slug);

  String get selectedCategoriesDisplay {
    if (selectedCategorySlugs.isEmpty) return 'Select Material';
    final names = selectedCategorySlugs.map((slug) {
      final meta = AllMaterialsCatalog.getCategoryBySlug(slug);
      return meta?.name ?? slug;
    }).toList();
    return names.join(', ');
  }

  // ── Tier 3 & 4: Subtype Selection & Item Adding ──
  void addSubtypeItem(String categorySlug, String subItemName) {
    final meta = AllMaterialsCatalog.getCategoryBySlug(categorySlug);
    final categoryName = meta?.name ?? categorySlug;

    // Check if already added
    final exists = orderItems.any((i) => i.categorySlug == categorySlug && i.name == subItemName);
    if (exists) {
      showToastMessage("$subItemName already added in table.");
      return;
    }

    final newItem = AllMaterialOrderItem(
      id: "${categorySlug}_${subItemName}_${DateTime.now().millisecondsSinceEpoch}",
      categorySlug: categorySlug,
      categoryName: categoryName,
      name: subItemName,
      defaultUnit: meta?.defaultUnit ?? 'Nos',
      defaultGst: 18.0,
    );

    // Bind change listener
    newItem.changeNotifier.listen((_) {
      calculationTrigger.value++;
    });

    orderItems.add(newItem);
    calculationTrigger.value++;
  }

  void removeOrderItem(AllMaterialOrderItem item) {
    orderItems.remove(item);
    item.dispose();
    calculationTrigger.value++;
  }

  List<AllMaterialOrderItem> getItemsForCategory(String categorySlug) {
    return orderItems.where((i) => i.categorySlug == categorySlug).toList();
  }

  // ── Subtotals for a specific category ──
  double getCategorySubtotalQty(String categorySlug) {
    calculationTrigger.value; // trigger dependency
    double sum = 0.0;
    for (var i in orderItems.where((item) => item.categorySlug == categorySlug)) {
      sum += i.quantity;
    }
    return sum;
  }

  double getCategorySubtotalBase(String categorySlug) {
    calculationTrigger.value;
    double sum = 0.0;
    for (var i in orderItems.where((item) => item.categorySlug == categorySlug)) {
      sum += i.baseTotal;
    }
    return sum;
  }

  double getCategorySubtotalInclGst(String categorySlug) {
    calculationTrigger.value;
    double sum = 0.0;
    for (var i in orderItems.where((item) => item.categorySlug == categorySlug)) {
      sum += i.totalInclGst;
    }
    return sum;
  }

  // ── Overall Calculations ──
  double get overallTotalQuantity {
    calculationTrigger.value;
    if (orderItems.isNotEmpty) {
      double sum = 0.0;
      for (var i in orderItems) {
        sum += i.quantity;
      }
      return sum;
    }
    return double.tryParse(manualQuantityController.text.trim()) ?? 0.0;
  }

  double get overallTotalBasePrice {
    calculationTrigger.value;
    if (orderItems.isNotEmpty) {
      double sum = 0.0;
      for (var i in orderItems) {
        sum += i.baseTotal;
      }
      return sum;
    }
    return double.tryParse(manualPriceController.text.trim()) ?? 0.0;
  }

  double get overallTotalGstAmount {
    calculationTrigger.value;
    if (orderItems.isNotEmpty) {
      double sum = 0.0;
      for (var i in orderItems) {
        sum += i.gstAmount;
      }
      return sum;
    }
    return 0.0;
  }

  double get overallGrandTotal {
    calculationTrigger.value;
    return overallTotalBasePrice + overallTotalGstAmount;
  }

  // ── File Picking ──
  Future<void> pickInvoiceImage({bool fromCamera = false}) async {
    final file = await FilePickerHelper.pickImage(fromCamera: fromCamera);
    if (file != null) {
      invoiceFile.value = file;
      invoiceFileName.value = file.path.split(Platform.pathSeparator).last;
    }
  }

  Future<void> pickInvoiceDocument() async {
    final file = await FilePickerHelper.pickDocument();
    if (file != null) {
      invoiceFile.value = file;
      invoiceFileName.value = file.path.split(Platform.pathSeparator).last;
    }
  }

  void removeInvoice() {
    invoiceFile.value = null;
    invoiceFileName.value = '';
  }

  // ── Summary Items String Format ──
  String get formattedItemsSummary {
    if (orderItems.isNotEmpty) {
      return orderItems.map((i) {
        final qtyStr = i.quantity.toString().replaceAll(RegExp(r'\.0$'), '');
        return "${i.name} [$qtyStr ${i.unit.value}]";
      }).join(", ");
    }
    final qtyStr = overallTotalQuantity.toString().replaceAll(RegExp(r'\.0$'), '');
    return "$selectedCategoriesDisplay [$qtyStr Units]";
  }

  // ── Submit Order / Request ──
  Future<void> submit() async {
    if (selectedVendor.value == null) {
      showToastMessage("Please select a vendor.");
      return;
    }

    final isOrder = selectedTabIndex.value == 0;

    if (orderItems.isEmpty) {
      if (selectedCategorySlugs.isEmpty) {
        showToastMessage("Please select at least one material category.");
        return;
      }
      if (overallTotalQuantity <= 0) {
        showToastMessage("Please enter valid quantity.");
        return;
      }
      if (isOrder && overallTotalBasePrice <= 0) {
        showToastMessage("Please enter valid total price.");
        return;
      }
    } else {
      // Validate quantities
      for (var item in orderItems) {
        if (item.quantity <= 0) {
          showToastMessage("Please enter valid quantity for ${item.name}.");
          return;
        }
        if (isOrder && item.price <= 0) {
          showToastMessage("Please enter valid price for ${item.name}.");
          return;
        }
      }
    }

    try {
      isSubmitting.value = true;

      final apiUrl = isOrder ? "add-order" : "request-order";

      String itemsJson;
      String itemsSummaryText;
      if (orderItems.isNotEmpty) {
        final itemsPayload = orderItems.map((e) => e.toJson()).toList();
        itemsJson = jsonEncode(itemsPayload);
        itemsSummaryText = formattedItemsSummary;
      } else {
        final manualItem = {
          "name": selectedCategoriesDisplay,
          "item_name": selectedCategoriesDisplay,
          "material": selectedCategoriesDisplay,
          "category": selectedCategoriesDisplay,
          "quantity": overallTotalQuantity.toString().replaceAll(RegExp(r'\.0$'), ''),
          "unit": "Units",
          "price": overallTotalBasePrice.toStringAsFixed(2),
          "rate": overallTotalBasePrice.toStringAsFixed(2),
          "gst": "0",
          "gst_amount": "0.00",
          "total": overallGrandTotal.toStringAsFixed(2),
        };
        itemsJson = jsonEncode([manualItem]);
        itemsSummaryText = "$selectedCategoriesDisplay [${overallTotalQuantity.toString().replaceAll(RegExp(r'\.0$'), '')} Units]";
      }

      final Map<String, String> payload = {
        "site_id": args.id.toString(),
        "vendor_id": selectedVendor.value!.id.toString(),
        "material_type": "all",
        "quantity": overallTotalQuantity.toString().replaceAll(RegExp(r'\.0$'), ''),
        "unit": "Units",
        "price": overallTotalBasePrice.toStringAsFixed(2),
        "gst": overallTotalGstAmount.toStringAsFixed(2),
        "amount": overallGrandTotal.toStringAsFixed(2),
        "supervisor_name": supervisorNameController.text.trim(),
        "supervisor_mobile": supervisorMobController.text.trim(),
        "items": isOrder ? itemsJson : itemsSummaryText,
        "items_summary": itemsSummaryText,
      };

      if (isOrder) {
        payload["date"] = dateController.text.trim();
        // Add bracket-notation fields for Laravel multipart array validation
        if (orderItems.isNotEmpty) {
          for (int i = 0; i < orderItems.length; i++) {
            final itm = orderItems[i];
            payload["items[$i][name]"] = itm.name;
            payload["items[$i][item_name]"] = itm.name;
            payload["items[$i][category]"] = itm.categoryName;
            payload["items[$i][category_name]"] = itm.categoryName;
            payload["items[$i][category_slug]"] = itm.categorySlug;
            payload["items[$i][quantity]"] = itm.quantity.toString().replaceAll(RegExp(r'\.0$'), '');
            payload["items[$i][unit]"] = itm.unit.value;
            payload["items[$i][price]"] = itm.price.toStringAsFixed(2);
            payload["items[$i][rate]"] = itm.price.toStringAsFixed(2);
            payload["items[$i][gst]"] = itm.gstRate.value.toString();
            payload["items[$i][gst_amount]"] = itm.gstAmount.toStringAsFixed(2);
            payload["items[$i][total]"] = itm.totalInclGst.toStringAsFixed(2);
          }
        } else {
          payload["items[0][name]"] = selectedCategoriesDisplay;
          payload["items[0][item_name]"] = selectedCategoriesDisplay;
          payload["items[0][category]"] = selectedCategoriesDisplay;
          payload["items[0][quantity]"] = overallTotalQuantity.toString().replaceAll(RegExp(r'\.0$'), '');
          payload["items[0][unit]"] = "Units";
          payload["items[0][price]"] = overallTotalBasePrice.toStringAsFixed(2);
          payload["items[0][rate]"] = overallTotalBasePrice.toStringAsFixed(2);
          payload["items[0][gst]"] = "0";
          payload["items[0][gst_amount]"] = "0.00";
          payload["items[0][total]"] = overallGrandTotal.toStringAsFixed(2);
        }
      } else {
        payload["date_of_delivery"] = dateController.text.trim();
        if (deliveryNeededByController.text.isNotEmpty) {
          payload["delivery_needed_by"] = deliveryNeededByController.text.trim();
        }
        if (remarksController.text.isNotEmpty) {
          payload["remarks"] = remarksController.text.trim();
        }
      }

      print("📤 Submitting $apiUrl with payload: $payload");
      final res = await ApiData().bricksRequestApi(
        "$baseUrl$apiUrl",
        payload,
        invoiceFile.value,
      );

      if (res == null) {
        showToastMessage("Submission failed. Please check network connection.");
        return;
      }

      if (res.status != true) {
        showToastMessage(res.message ?? "Operation failed");
        return;
      }

      // Handle Success
      if (isOrder) {
        showToastMessage(res.message ?? "Inward Order placed successfully!");
        Get.back(result: true);
      } else {
        // Material Request
        if (userRole == 'supervisor') {
          showToastMessage(res.message ?? "Request submitted to Admin for approval.");
          Get.back(result: true);
        } else {
          // Admin: Send WhatsApp message to vendor
          String phone = selectedVendor.value?.mobileNo?.toString().trim() ?? "7540060694";
          phone = phone.replaceAll(RegExp(r'[ \-\(\)]'), '');
          if (phone.length == 10 && !phone.startsWith('+')) {
            phone = '+91$phone';
          }

          final pdfUrl = res.data?.materialRequest?.imageUrl;

          final itemsListText = orderItems.map((i) {
            final qtyStr = i.quantity.toString().replaceAll(RegExp(r'\.0$'), '');
            return "• ${i.name}: $qtyStr ${i.unit.value}";
          }).join("\n");

          final message = """
*Pojo infra 360*
Site Name: ${args.siteName} - Material Requisition
Location: ${args.siteLocation}
Vendor: ${selectedVendor.value?.name ?? 'N/A'}
Phone: ${selectedVendor.value?.mobileNo ?? 'N/A'}

Materials Requested:
$itemsListText

Delivery Date: ${dateController.text}
Supervisor: ${supervisorNameController.text} (${supervisorMobController.text})
${pdfUrl != null ? "Request PDF: $pdfUrl" : ""}
""";

          final whatsappUrl = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";
          extractAndOpenWhatsApp(whatsappUrl);

          showToastMessage(res.message ?? "Request created successfully!");
          Get.back(result: true);
        }
      }
    } catch (e, stack) {
      print("❌ Exception during submit: $e");
      print(stack);
      showToastMessage("An error occurred: $e");
    } finally {
      isSubmitting.value = false;
    }
  }
}
