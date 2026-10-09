import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/property_list_model.dart';
import 'package:raptor_pro/view/properties_list/properties_list_controller.dart';
import 'package:raptor_pro/view/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class AddPropertyController extends GetxController {
  RxBool isLoading = false.obs;
  final ImagePicker picker = ImagePicker();
  Rxn<File> propertyImage = Rxn<File>();
  RxString existingImageUrl = RxString("");
  RxString selectedFileName = RxString("No file chosen");

  TextEditingController nameController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  RxString amountInWords = RxString("");

  RxString propertyType = RxString("Plot");
  RxList<String> propertyTypes = <String>["Plot", "Land"].obs;

  PropertyListData? editProperty;

  void initData(PropertyListData? property) {
    editProperty = property;
    if (property != null) {
      nameController.text = property.name ?? "";
      locationController.text = property.location ?? "";
      propertyType.value = (property.type != null && property.type!.isNotEmpty) ? property.type! : "Plot";
      amountController.text = property.amount ?? "";
      remarksController.text = property.remarks ?? "";
      existingImageUrl.value = property.imageUrl ?? "";
      updateAmountInWords(property.amount ?? "");
    } else {
      amountInWords.value = "";
    }
    fetchPropertyTypes();
  }

  void updateAmountInWords(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    final num = int.tryParse(clean);
    if (num == null || num <= 0) {
      amountInWords.value = "";
    } else {
      amountInWords.value = convertNumberToIndianWords(num);
    }
  }

  Future<void> fetchPropertyTypes() async {
    try {
      final types = await ApiData().propertyFormApi();
      final list = List<String>.from(types);
      if (editProperty?.type != null && editProperty!.type!.isNotEmpty && !list.contains(editProperty!.type!)) {
        list.add(editProperty!.type!);
      }
      propertyTypes.value = list;
      if (!list.contains(propertyType.value)) {
        propertyType.value = list.first;
      }
    } catch (e) {
      print("Error fetching property types: $e");
    }
  }

  Future<void> getImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      propertyImage.value = File(image.path);
      selectedFileName.value = image.name;
    }
  }

  /// Saves property and then launches WhatsApp with property details
  Future<bool> savePropertyAndShareOnWhatsApp() async {
    isLoading.value = true;
    try {
      // Add mode requires image
      if (propertyImage.value == null) {
        showToastMessage("Please select a property image");
        isLoading.value = false;
        return false;
      }

      final name = nameController.text.trim();
      final location = locationController.text.trim();
      final type = propertyType.value;
      final amount = amountController.text.trim();
      final remarks = remarksController.text.trim();

      CommonSuccessResponseModel? model = await ApiData().addProperty(
        name,
        location,
        type,
        amount,
        remarks,
        propertyImage.value,
      );

      if (model != null && (model.status ?? true)) {
        showToastMessage(model.message ?? "Property added successfully!");
        if (Get.isRegistered<PropertiesController>()) {
          Get.find<PropertiesController>().init();
        }

        // Share on WhatsApp
        final whatsappMessage =
            "*Pojo Infra 360 — New Property Added*\n\n"
            "🏡 *Property Name:* $name\n"
            "📍 *Location:* $location\n"
            "🏷️ *Type:* $type\n"
            "💰 *Amount:* ₹$amount"
            "${amountInWords.value.isNotEmpty ? ' ($amountInWords)' : ''}\n"
            "📝 *Remarks:* $remarks\n\n"
            "Shared via Pojo Infra 360 Mobile App";

        final url = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(whatsappMessage)}");
        try {
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            await launchUrl(url);
          }
        } catch (e) {
          print("Could not launch WhatsApp: $e");
        }

        Get.back();
        return true;
      } else {
        showToastMessage(model?.message ?? "Failed to save property");
        return false;
      }
    } catch (e) {
      print("Error saving property: $e");
      showToastMessage("Error saving property");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates existing property (Screenshot 4)
  Future<bool> updateProperty() async {
    if (editProperty == null) return false;
    isLoading.value = true;
    try {
      CommonSuccessResponseModel? model = await ApiData().updateProperty(
        editProperty!.id!,
        nameController.text.trim(),
        locationController.text.trim(),
        propertyType.value,
        amountController.text.trim(),
        remarksController.text.trim(),
        propertyImage.value,
      );

      if (model != null && (model.status ?? true)) {
        showToastMessage(model.message ?? "Property updated successfully!");
        if (Get.isRegistered<PropertiesController>()) {
          Get.find<PropertiesController>().init();
        }
        Get.back();
        return true;
      } else {
        showToastMessage(model?.message ?? "Failed to update property");
        return false;
      }
    } catch (e) {
      print("Error updating property: $e");
      showToastMessage("Error updating property");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  static String convertNumberToIndianWords(int number) {
    if (number == 0) return "Zero Rupees Only";

    final units = [
      "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
      "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
      "Seventeen", "Eighteen", "Nineteen"
    ];
    final tens = [
      "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
    ];

    String convertBelowThousand(int n) {
      String res = "";
      if (n >= 100) {
        res += "${units[n ~/ 100]} Hundred ";
        n %= 100;
      }
      if (n >= 20) {
        res += "${tens[n ~/ 10]} ";
        n %= 10;
      }
      if (n > 0) {
        res += "${units[n]} ";
      }
      return res.trim();
    }

    String words = "";
    int temp = number;

    if (temp >= 10000000) {
      words += "${convertBelowThousand(temp ~/ 10000000)} Crore ";
      temp %= 10000000;
    }
    if (temp >= 100000) {
      words += "${convertBelowThousand(temp ~/ 100000)} Lakh ";
      temp %= 100000;
    }
    if (temp >= 1000) {
      words += "${convertBelowThousand(temp ~/ 1000)} Thousand ";
      temp %= 1000;
    }
    if (temp > 0) {
      words += "${convertBelowThousand(temp)} ";
    }

    return "${words.trim()} Rupees Only";
  }
}