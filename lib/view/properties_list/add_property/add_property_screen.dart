import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/property_list_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/utils/url_helper.dart';
import 'package:raptor_pro/view/properties_list/add_property/add_property_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

class AddPropertyScreen extends StatefulWidget {
  final PropertyListData? property;

  const AddPropertyScreen({super.key, this.property});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  late AddPropertyController controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get isEdit => widget.property != null;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AddPropertyController());
    controller.initData(widget.property);
  }

  @override
  void dispose() {
    Get.delete<AddPropertyController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? "Edit Property" : "Add New property";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: CommonAppBar.appBar(
        title: title,
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title inside card matching Screenshots 2 & 4
                  Center(
                    child: Text(
                      isEdit ? "Edit Property" : "Add New property",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 18),

                  // ── Property Name ─────────────────────────────────────────
                  _buildFieldLabel("Property Name", isRequired: isEdit),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.nameController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 14),
                    decoration: textBoxDecoration(hint: "Enter name"),
                    validator: (text) {
                      if (text == null || text.trim().isEmpty) {
                        return 'Property name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Property Location ─────────────────────────────────────
                  _buildFieldLabel("Property Location", isRequired: isEdit),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.locationController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    minLines: 2,
                    style: const TextStyle(fontSize: 14),
                    decoration: textBoxDecoration(hint: "Enter location here..."),
                    validator: (text) {
                      if (text == null || text.trim().isEmpty) {
                        return 'Location is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Property Type Dropdown ────────────────────────────────
                  _buildFieldLabel("Property Type", isRequired: isEdit),
                  const SizedBox(height: 6),
                  Obx(() {
                    return DropdownButtonFormField2<String>(
                      isExpanded: true,
                      value: controller.propertyTypes.contains(controller.propertyType.value)
                          ? controller.propertyType.value
                          : (controller.propertyTypes.isNotEmpty ? controller.propertyTypes.first : "Plot"),
                      decoration: dropDownBoxDecoration(),
                      hint: Text(
                        'Select Property Type',
                        style: AppTextStyle.textHintText,
                      ),
                      items: controller.propertyTypes
                          .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: AppTextStyle.textFieldHeadingStyle,
                                ),
                              ))
                          .toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select Property Type';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value != null) {
                          controller.propertyType.value = value;
                        }
                      },
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // ── Amount ────────────────────────────────────────────────
                  _buildFieldLabel("Amount", isRequired: isEdit),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 14),
                    decoration: textBoxDecoration(hint: "Enter amount"),
                    onChanged: (val) {
                      controller.updateAmountInWords(val);
                    },
                    validator: (text) {
                      if (text == null || text.trim().isEmpty) {
                        return 'Amount is required';
                      }
                      if (double.tryParse(text.trim()) == null) {
                        return 'Amount must be a valid number';
                      }
                      return null;
                    },
                  ),

                  // Real-time Amount In Words (as requested by user)
                  Obx(() {
                    if (controller.amountInWords.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.spellcheck, size: 16, color: Color(0xFF16A34A)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              controller.amountInWords.value,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // ── Remarks ───────────────────────────────────────────────
                  _buildFieldLabel("Remarks", isRequired: isEdit),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.remarksController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    minLines: 2,
                    style: const TextStyle(fontSize: 14),
                    decoration: textBoxDecoration(hint: "Enter remarks here..."),
                    validator: (text) {
                      if (text == null || text.trim().isEmpty) {
                        return 'Remarks are required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Image Section ─────────────────────────────────────────
                  _buildFieldLabel("Image", isRequired: false),
                  const SizedBox(height: 6),

                  // In Edit mode: show Current Image thumbnail (Screenshot 4)
                  if (isEdit) ...[
                    Obx(() {
                      final existingUrl = controller.existingImageUrl.value;
                      if (existingUrl.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Current Image:",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                UrlHelper.getFullImageUrl(existingUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Icon(Icons.broken_image, size: 30, color: Colors.grey)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    }),
                  ],

                  // Choose File Row matching Screenshots 2, 3, 4
                  Obx(() {
                    final selectedName = controller.selectedFileName.value;
                    final hasFile = controller.propertyImage.value != null;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFD1D5DB)),
                          ),
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => controller.getImage(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  foregroundColor: const Color(0xFF1F2937),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                child: const Text(
                                  "Choose File",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: hasFile ? const Color(0xFF1E60D0) : const Color(0xFF6B7280),
                                    fontWeight: hasFile ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isEdit)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              "Leave empty to keep existing image",
                              style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                            ),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 28),

                  // ── Action Buttons ────────────────────────────────────────
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CommonLoader());
                    }

                    // ── In Edit Mode (Screenshot 4): Cancel + Update Property
                    if (isEdit) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1), // Indigo
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                controller.updateProperty();
                              }
                            },
                            icon: const Icon(Icons.save_outlined, size: 17, color: Colors.white),
                            label: const Text(
                              "Update Property",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E60D0),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      );
                    }

                    // ── In Add Mode (Screenshots 2 & 3): Share on Whatsapp Button
                    return Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            controller.savePropertyAndShareOnWhatsApp();
                          }
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                        label: const Text(
                          "Share on Whatsapp",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB), // Blue button
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        if (isRequired)
          const Text(
            " *",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEF4444),
            ),
          ),
      ],
    );
  }
}