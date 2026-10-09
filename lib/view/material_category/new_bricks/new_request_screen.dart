import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/model/bricks_model.dart';
import 'package:raptor_pro/model/vendor_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/material_category/new_bricks/new_request_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

import '../../../utils/file_picker_helper.dart';
import '../../../utils/file_preview.dart';
import '../../../utils/res/colors.dart';

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key, required this.type, this.editItem});

  final int type;
  final BricksList? editItem;

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final NewRequestController controller = Get.put(NewRequestController());
  final TextEditingController searchEditingController = TextEditingController();
  File? attachment;
  String _attachmentName = '';
  bool _isSubmitting = false;

  late String role;
  late int type;
  late bool canShow;

  @override
  void initState() {
    super.initState();
    // Reset state to avoid cross-material contamination
    controller.selectedBrickType.value = null;
    controller.selectedCategory.value = null;
    controller.selectedVendorData = null;
    controller.specificationController.clear();
    controller.syncItemsField();

    controller.materialUnitsListApi();

    role = controller.userDetails.data?.role?.toLowerCase() ?? 'admin';
    type = widget.type;

    canShow = (role == 'admin' && (type == 1 || type == 2)) ||
        (role == 'supervisor' && (type == 1 || type == 2));

    // Default date to today
    if (controller.dateController.text.isEmpty) {
      controller.dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    }

    // Pre-fill form if editing
    if (widget.editItem != null) {
      final item = widget.editItem!;
      controller.quantityController.text = item.quantity ?? '';
      controller.amountController.text = item.price?.toString() ?? '';
      controller.gstController.text = item.gst?.toString() ?? '';
      if (item.specification != null && item.specification!.isNotEmpty) {
        controller.specificationController.text = item.specification!;
      }
      if (item.category != null && item.category!.isNotEmpty) {
        controller.selectedBrickType.value = item.category!;
        controller.selectedCategory.value = item.category!;
      }
      controller.syncItemsField();
      try {
        if (item.date != null && item.date!.isNotEmpty) {
          final dt = DateTime.parse(item.date!);
          controller.dateController.text = DateFormat('dd-MM-yyyy').format(dt);
        }
      } catch (_) {
        controller.dateController.text = item.date ?? '';
      }
      if (item.vendorId != null) {
        final vendor = controller.getBricksLists.firstWhereOrNull(
          (v) => v.id == item.vendorId,
        );
        if (vendor != null) {
          controller.selectedVendorData = vendor;
          controller.mobileNoController.text = vendor.mobileNo ?? '';
          controller.addressController.text = vendor.address ?? '';
          controller.vendorGstController.text = vendor.gst ?? '';
        }
      }
      if (item.unit != null && item.unit!.isNotEmpty) {
        controller.selectedUnit.value = item.unit!;
      }

      // Pre-fill Inward Order items with specification
      controller.inwardOrderItems.clear();
      if (item.rawItems != null) {
        try {
          dynamic parsed = item.rawItems;
          if (parsed is String) parsed = jsonDecode(parsed);
          if (parsed is List) {
            for (var itm in parsed) {
              if (itm is Map) {
                final s = (itm['specification'] ?? itm['spec'] ?? itm['size'] ?? itm['size_specification'] ?? item.specification ?? '').toString();
                final q = (itm['quantity'] ?? itm['qty'] ?? '1').toString();
                final p = (itm['price'] ?? itm['rate'] ?? '1000').toString();
                final u = (itm['unit'] ?? item.unit ?? 'Nos').toString();
                final g = double.tryParse((itm['gst'] ?? '0').toString()) ?? 18.0;
                controller.inwardOrderItems.add(InwardOrderItemModel(
                  spec: s,
                  qty: q,
                  price: p,
                  defaultUnit: u,
                  defaultGst: g,
                ));
              }
            }
          }
        } catch (_) {}
      }
      if (controller.inwardOrderItems.isEmpty) {
        final unitPrice = item.pricePerItem != null
            ? item.pricePerItem!.toStringAsFixed(2)
            : (item.price != null ? item.price!.toString() : '1000');
        controller.inwardOrderItems.add(InwardOrderItemModel(
          spec: item.specification ?? '',
          qty: item.quantity ?? '1',
          price: unitPrice,
          defaultUnit: item.unit ?? 'Nos',
          defaultGst: double.tryParse(item.gst ?? '0') ?? 18.0,
        ));
      }
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final isOrder = widget.type == 2;
    final itemTitle = _capitalize(controller.itemKey.value);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar.appBar(
        title: widget.editItem != null
            ? "Edit $itemTitle Order"
            : isOrder
                ? "Inward $itemTitle Order"
                : "Add $itemTitle Request",
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: isOrder ? _buildInwardOrderForm() : _buildRequestOrderForm(),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── INWARD ORDER FORM (Screenshots 4 & 5) ──
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildInwardOrderForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Vendor Name
          _buildVendorDropdown(),

          // 2. Vendor Mobile No (read-only)
          _buildMobileNumberField(),

          // 3. Vendor Address (read-only)
          _buildAddressField(),

          // 4. Vendor GST (read-only)
          _buildVendorGstField(),

          // 5. Date
          _buildDateField(label: "Date"),

          // 6. Brick / Block Type Dropdown
          _buildBrickTypeDropdown(),

          // 7. Dynamic Section for Selected Brick Type (Screenshot 5)
          _buildDynamicBrickItemsSection(),

          // 8. Supervisor Name
          _buildSupervisorNameField(),

          // 9. Supervisor Phone No
          _buildSupervisorMobField(label: "Supervisor Phone No"),

          // 10. Invoice No
          _buildInvoiceNoField(),

          // 11. Invoice Attachment
          _buildInvoicePickerField(),

          const SizedBox(height: 24),

          // 12. Submit Button: "Inward Order" (Screenshot 5)
          _buildInwardSubmitButton(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── REQUEST ORDER FORM (widget.type == 1: Screenshots 1 & 2) ──
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildRequestOrderForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Vendor Name
          _buildVendorDropdown(),

          // 2. Vendor Mobile No
          _buildMobileNumberField(),

          // 3. Vendor Address
          _buildAddressField(),

          // 4. Items (e.g. Bricks or Bricks - Solid Concrete Blocks (6))
          _buildRequestItemsField(),

          // 5. Quantity
          _buildQuantityField(),

          // 6. Brick / Block Type Dropdown (or Material Type)
          _buildRequestMaterialTypeDropdown(),

          // 7. Size / Specification (Normal TextFormField, NO dropdown!)
          _buildRequestSpecificationField(),

          // 8. Unit Dropdown
          _buildUnitDropdown(),

          // 9. Date of Delivery
          _buildDateField(label: "Date of Delivery"),

          // 10. Supervisor Name
          _buildSupervisorNameField(),

          // 11. Supervisor Phone No
          _buildSupervisorMobField(label: "Supervisor Phone No"),

          // 12. Price
          _buildAmountField(),

          // 13. Optional Attachment
          _buildAttachment(),

          const SizedBox(height: 20),

          // 14. Send Request to Vendor WhatsApp Button (Screenshot 2)
          _buildRequestSubmitButton(),
        ],
      ),
    );
  }

  // ── VENDOR DROPDOWN (Reactive, Only Vendor Name displayed, Searchable by Name or Mobile) ──
  Widget _buildVendorDropdown() {
    return Obx(() {
      final vendorList = controller.getBricksLists;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Vendor Name", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          DropdownButtonFormField2<VendorData>(
            isExpanded: true,
            decoration: dropDownBoxDecoration(hint: "Type or select vendor name..."),
            hint: const Text('Type or select vendor name...', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
            value: controller.selectedVendorData,
            items: vendorList
                .map(
                  (item) => DropdownMenuItem<VendorData>(
                    value: item,
                    child: Text(
                      item.name ?? "",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            validator: (value) => value == null ? 'Please select Vendor' : null,
            onChanged: (value) {
              if (value != null) {
                controller.selectedVendorData = value;
                controller.mobileNoController.text = value.mobileNo ?? '';
                controller.addressController.text = value.address ?? '';
                controller.vendorGstController.text = value.gst ?? '';
                setState(() {});
              }
            },
            dropdownSearchData: DropdownSearchData(
              searchController: searchEditingController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  controller: searchEditingController,
                  decoration: textBoxDecoration(hint: "Search Vendor by name or phone"),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                final v = item.value;
                if (v == null) return false;
                final name = (v.name ?? '').toLowerCase();
                final phone = (v.mobileNo ?? '').toLowerCase();
                final query = searchValue.toLowerCase();
                return name.contains(query) || phone.contains(query);
              },
            ),
          ),
          const SizedBox(height: 14),
        ],
      );
    });
  }

  Widget _buildMobileNumberField() => _textField(
        label: "Vendor Mobile No",
        controller: controller.mobileNoController,
        hint: "Auto-filled on selecting vendor",
        readOnly: true,
        fillColor: const Color(0xFFF1F5F9),
        validator: (text) => null,
      );

  Widget _buildAddressField() => _textField(
        label: "Vendor Address",
        controller: controller.addressController,
        hint: "Auto-filled on selecting vendor",
        readOnly: true,
        minLines: 2,
        fillColor: const Color(0xFFF1F5F9),
        validator: (text) => null,
      );

  Widget _buildVendorGstField() => _textField(
        label: "Vendor GST",
        controller: controller.vendorGstController,
        hint: "Auto-filled on selecting vendor",
        readOnly: true,
        fillColor: const Color(0xFFF1F5F9),
        validator: (text) => null,
      );

  Widget _buildDateField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.dateController,
          decoration: textBoxDecoration(
            hint: "dd-mm-yyyy",
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
          ),
          readOnly: true,
          onTap: () async {
            DateTime initial = DateTime.now();
            try {
              if (controller.dateController.text.isNotEmpty) {
                initial = DateFormat('dd-MM-yyyy').parse(controller.dateController.text);
              }
            } catch (_) {}

            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              controller.dateController.text = DateFormat('dd-MM-yyyy').format(picked);
              setState(() {});
            }
          },
          validator: (text) => (text == null || text.isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ── Brick / Block Type Dropdown (Screenshot 4) ──
  Widget _buildBrickTypeDropdown() {
    return Obx(() {
      final itemKey = controller.itemKey.value.toLowerCase();
      final label = itemKey.contains('brick')
          ? "Brick / Block Type"
          : "${_capitalize(controller.itemKey.value)} Type";

      List<String> items = controller.categories.isNotEmpty
          ? controller.categories
          : NewRequestController.getSubItemsForMaterial(controller.itemKey.value);
      items = items.toSet().toList();

      final effectiveVal = items.contains(controller.selectedBrickType.value)
          ? controller.selectedBrickType.value
          : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: dropDownBoxDecoration(hint: "Select $label"),
            hint: Text("Select $label", style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
            value: effectiveVal,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                    ))
                .toList(),
            validator: (value) => value == null ? 'Please select $label' : null,
            onChanged: (value) {
              if (value != null) {
                controller.selectedBrickType.value = value;
                controller.selectedCategory.value = value;
                controller.syncItemsField();
                if (controller.inwardOrderItems.isEmpty) {
                  controller.addInwardOrderItem();
                }
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 14),
        ],
      );
    });
  }

  // ── Dynamic Brick Items Section (Screenshot 5: Red Clay Brick -> Size, Qty, Unit, Price, GST, Total) ──
  Widget _buildDynamicBrickItemsSection() {
    return Obx(() {
      final selectedType = controller.selectedBrickType.value;
      if (selectedType == null || selectedType.isEmpty) {
        return const SizedBox.shrink();
      }

      final items = controller.inwardOrderItems;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 24, thickness: 1),
          // Heading: e.g. "Red Clay Brick" (Screenshot 5)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedType,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${items.length} item(s)",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildInwardItemRow(items[index], index);
            },
          ),

          const SizedBox(height: 10),

          // "+ add more" button (Screenshot 5)
          OutlinedButton.icon(
            onPressed: () {
              controller.addInwardOrderItem();
              setState(() {});
            },
            icon: const Icon(Icons.add, size: 16, color: Color(0xFF2563EB)),
            label: const Text(
              "+ add more",
              style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2563EB), width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
          const Divider(height: 28, thickness: 1),
        ],
      );
    });
  }

  // ── Single Specification Row (Screenshot 5) ──
  Widget _buildInwardItemRow(InwardOrderItemModel item, int index) {
    List<String> unitsList = controller.units;
    if (unitsList.isEmpty) {
      unitsList = ['Nos', 'Units', 'Bags', 'Ton', 'Kg', 'Sq.Ft', 'Cft', 'Cum'];
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Size / Specification + Delete button (if > 1)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Size / Specification",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: item.specCtrl,
                      decoration: InputDecoration(
                        hintText: "Select or enter Size / Specification",
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.inwardOrderItems.length > 1) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: InkWell(
                    onTap: () {
                      controller.removeInwardOrderItem(index);
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Quantity, Unit, Price per item
          Row(
            children: [
              // Quantity
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Quantity", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: item.qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: "Qty",
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (t) => (t == null || t.isEmpty) ? 'Req' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Unit Dropdown
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Unit", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    DropdownButtonFormField2<String>(
                      isExpanded: true,
                      value: unitsList.contains(item.unit.value) ? item.unit.value : unitsList.first,
                      items: unitsList
                          .map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          item.unit.value = val;
                          setState(() {});
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Price per item
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Price per item", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: item.priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: "Price per item",
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (t) => (t == null || t.isEmpty) ? 'Req' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: GST Dropdown + Total incl. GST (Auto calculated)
          Row(
            children: [
              // GST
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("GST", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    DropdownButtonFormField2<double>(
                      isExpanded: true,
                      value: item.gst.value,
                      items: const [0.0, 5.0, 12.0, 18.0, 28.0]
                          .map((g) => DropdownMenuItem(value: g, child: Text("${g.toInt()}%", style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          item.gst.value = val;
                          setState(() {});
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Total incl. GST (Auto-calculated, Screenshot 5)
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total incl. GST", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        item.totalInclGst > 0 ? "₹ ${item.totalInclGst.toStringAsFixed(2)}" : "Auto",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: item.totalInclGst > 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupervisorNameField() => _textField(
        label: "Supervisor Name",
        controller: controller.supervisorNameController,
        hint: "Supervisor Name",
      );

  Widget _buildSupervisorMobField({required String label}) => _textField(
        label: label,
        controller: controller.supervisorMobController,
        hint: label,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
      );

  Widget _buildInvoiceNoField() => _textField(
        label: "Invoice No",
        controller: controller.invoiceNoController,
        hint: "Vendor's invoice number",
        validator: (_) => null,
      );

  // ── Invoice Attachment with "Choose File" & "No file chosen" (Screenshot 4 & 5) ──
  Widget _buildInvoicePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Invoice", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showAttachmentOptions(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Text("Choose File", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    attachment != null ? _attachmentName : "No file chosen",
                    style: TextStyle(
                      fontSize: 12,
                      color: attachment != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (attachment != null)
                  InkWell(
                    onTap: () {
                      setState(() {
                        attachment = null;
                        _attachmentName = '';
                      });
                    },
                    child: const Icon(Icons.cancel, size: 18, color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ── Inward Order Submit Button (Screenshot 5: Full width blue button) ──
  Widget _buildInwardSubmitButton() {
    return _isSubmitting
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() => _isSubmitting = true);
                  try {
                    await controller.submitInwardOrder(attachment);
                  } finally {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.buttonBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text(
                "Inward Order",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── Helpers for Request Order Form (Screenshots 1 & 2) ──
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildRequestItemsField() {
    return Obx(() {
      controller.itemKey.value; // reactive trigger
      return _textField(
        label: "Items",
        controller: controller.itemsController,
        hint: "Items",
        readOnly: true,
        fillColor: const Color(0xFFF1F5F9),
        validator: (_) => null,
      );
    });
  }

  Widget _buildQuantityField() => _textField(
        label: "Quantity",
        controller: controller.quantityController,
        hint: "Enter quantity",
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      );

  Widget _buildAmountField() => _textField(
        label: "Price",
        controller: controller.amountController,
        hint: "Enter Price",
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      );



  Widget _buildRequestMaterialTypeDropdown() {
    return Obx(() {
      final itemKey = controller.itemKey.value.toLowerCase();
      final label = itemKey.contains('brick')
          ? "Brick / Block Type"
          : "${_capitalize(controller.itemKey.value)} Type";

      List<String> items = controller.categories.isNotEmpty
          ? controller.categories
          : NewRequestController.getSubItemsForMaterial(controller.itemKey.value);
      items = items.toSet().toList();

      final effectiveVal = items.contains(controller.selectedBrickType.value)
          ? controller.selectedBrickType.value
          : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: dropDownBoxDecoration(hint: "Select $label"),
            hint: Text("Select $label", style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
            value: effectiveVal,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                    ))
                .toList(),
            validator: (value) => value == null ? 'Please select $label' : null,
            onChanged: (value) {
              if (value != null) {
                controller.selectedBrickType.value = value;
                controller.selectedCategory.value = value;
                controller.syncItemsField();
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 14),
        ],
      );
    });
  }

  Widget _buildRequestSpecificationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Size / Specification", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.specificationController,
          decoration: textBoxDecoration(hint: "Select or enter Size / Specification"),
          onChanged: (value) {
            controller.syncItemsField();
            setState(() {});
          },
          validator: (_) => null,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildUnitDropdown() {
    return Obx(() {
      List<String> unitsList = controller.units.isNotEmpty
          ? controller.units
          : ['Nos', 'Units', 'Bags', 'Ton', 'Kg', 'Sq.Ft', 'Cft', 'Cum', 'Coil', 'Litre'];
      unitsList = unitsList.toSet().toList();

      final effectiveVal = unitsList.contains(controller.selectedUnit.value)
          ? controller.selectedUnit.value
          : (unitsList.isNotEmpty ? unitsList.first : null);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Unit", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: dropDownBoxDecoration(),
            hint: const Text("Select Unit", style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
            value: effectiveVal,
            items: unitsList.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            validator: (value) => value == null ? 'Required' : null,
            onChanged: (value) {
              if (value != null) {
                controller.selectedUnit.value = value;
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 14),
        ],
      );
    });
  }

  Widget _buildAttachment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (attachment != null)
          FilePreview(
            file: attachment!,
            isImage: true,
            onRemove: () {
              setState(() {
                attachment = null;
              });
            },
          ),
        VerticalSpacing.d5px(),
        OutlinedButton(
          onPressed: () => _showAttachmentOptions(context),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColor.textFieldBorder,
            side: BorderSide(color: AppColor.textFieldBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, color: AppColor.black, size: 20),
              HorizontalSpacing.d5px(),
              Text(
                'Upload Image (Optional)',
                style: AppTextStyle.textRegular15.copyWith(color: AppColor.black),
              ),
            ],
          ),
        ),
        VerticalSpacing.d15px(),
      ],
    );
  }

  // ── Send Request to Vendor WhatsApp Button (Screenshot 2) ──
  Widget _buildRequestSubmitButton() {
    return _isSubmitting
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (controller.selectedVendorData == null) {
                    showToastMessage("Please select Vendor");
                    return;
                  }
                  setState(() => _isSubmitting = true);
                  try {
                    await controller.addMaterialApi(attachment, 1);
                  } finally {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.buttonBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Send Request to Vendor WhatsApp",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/images/whatsapp.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) => const Icon(Icons.chat, size: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    int? minLines,
    Color? fillColor,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        TextFormField(
          readOnly: readOnly,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          minLines: minLines,
          maxLines: minLines != null ? null : 1,
          decoration: textBoxDecoration(hint: hint).copyWith(
            filled: fillColor != null,
            fillColor: fillColor,
          ),
          validator: validator ?? (text) => (text == null || text.isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 14),
      ],
    );
  }



  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Pick Image'),
              onTap: () async {
                Navigator.pop(context);
                final file = await FilePickerHelper.pickImage();
                if (file != null) {
                  setState(() {
                    attachment = file;
                    _attachmentName = file.path.split(Platform.pathSeparator).last;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Capture Photo'),
              onTap: () async {
                Navigator.pop(context);
                final file = await FilePickerHelper.pickImage(fromCamera: true);
                if (file != null) {
                  setState(() {
                    attachment = file;
                    _attachmentName = file.path.split(Platform.pathSeparator).last;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
