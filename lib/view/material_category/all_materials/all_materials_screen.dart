import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/model/all_materials_data_model.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';

import 'all_materials_controller.dart';
import 'all_materials_orders_screen.dart';

class AllMaterialsManagementScreen extends StatefulWidget {
  const AllMaterialsManagementScreen({super.key});

  @override
  State<AllMaterialsManagementScreen> createState() =>
      _AllMaterialsManagementScreenState();
}

class _AllMaterialsManagementScreenState
    extends State<AllMaterialsManagementScreen> {
  late final AllMaterialsController controller;
  late final MaterialDetailsArgs args;

  @override
  void initState() {
    super.initState();
    args = Get.arguments as MaterialDetailsArgs;
    controller = Get.put(AllMaterialsController(args: args));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar.appBar(
        title: "All Materials Management",
        centerTitle: false,
        onTap: () => Get.back(),
        actions: [
          // "View All Orders" button
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.buttonBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Get.to(
                  () => AllMaterialsOrdersScreen(
                    args: MaterialDetailsArgs(
                      id: args.id,
                      siteName: args.siteName,
                      siteLocation: args.siteLocation,
                      itemKey: 'all',
                      itemData: args.itemData,
                      supervisorId: args.supervisorId,
                      supervisorName: args.supervisorName,
                      supervisorMob: args.supervisorMob,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.list_alt, size: 14, color: Colors.white),
              label: const Text(
                "View All Orders",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // "Back to Materials" button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.buttonBlue,
                side: BorderSide(color: AppColor.buttonBlue, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => Get.back(),
              child: const Text(
                "Back",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Breadcrumb & Site Info Header ──
              _buildBreadcrumbHeader(),
              const SizedBox(height: 14),

              // ── Tabs: Inward Order vs Material Request ──
              _buildTabs(),
              const SizedBox(height: 16),

              // ── Main Card Form ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Step 1: Vendor Selection ──
                    _buildVendorSection(),
                    const Divider(height: 32, thickness: 1),

                    // ── Step 2: Multi-Select Material Category (Tier 2) ──
                    _buildMaterialCategoryMultiSelect(),
                    const SizedBox(height: 20),

                    // ── Step 3: Cascading Dynamic Subtype Dropdowns & Items Grid (Tier 3 & 4) ──
                    _buildDynamicCategorySections(),

                    const Divider(height: 32, thickness: 1),

                    // ── Step 4: Overall Summary & Dispatch Form (Screenshot 5) ──
                    _buildSummaryDispatchSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Breadcrumb Header ──
  Widget _buildBreadcrumbHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200, width: 0.8),
      ),
      child: Row(
        children: [
          Icon(Icons.home_work_outlined, size: 16, color: AppColor.buttonBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Site  >  ${args.siteName}  >  Material Details  >  All Materials",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tabs: Inward Order / Material Request ──
  Widget _buildTabs() {
    return Obx(() {
      final tabIndex = controller.selectedTabIndex.value;
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedTabIndex.value = 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: tabIndex == 0 ? AppColor.buttonBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: tabIndex == 0
                        ? [
                            BoxShadow(
                              color: AppColor.buttonBlue.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Inward Order\n(Purchase)",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tabIndex == 0 ? Colors.white : Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedTabIndex.value = 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: tabIndex == 1 ? AppColor.buttonBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: tabIndex == 1
                        ? [
                            BoxShadow(
                              color: AppColor.buttonBlue.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Material Request\n(Requisition)",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tabIndex == 1 ? Colors.white : Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Step 1: Vendor Section ──
  Widget _buildVendorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vendor Name *",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 6),

        // Searchable Vendor Dropdown Trigger
        Obx(() {
          final vendor = controller.selectedVendor.value;
          return InkWell(
            onTap: () => _showVendorSearchDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: vendor != null ? AppColor.buttonBlue : Colors.grey.shade300,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      vendor != null
                          ? (vendor.name ?? '')
                          : "Select Vendor...",
                      style: TextStyle(
                        fontSize: 14,
                        color: vendor != null ? Colors.black87 : Colors.grey.shade500,
                        fontWeight: vendor != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (vendor != null)
                    GestureDetector(
                      onTap: () => controller.clearVendor(),
                      child: const Icon(Icons.close, size: 18, color: Colors.grey),
                    ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: Colors.black54),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 14),

        // Vendor Mobile No
        const Text(
          "Vendor Mobile No",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
        ),
        const SizedBox(height: 6),
        Obx(() {
          final vendor = controller.selectedVendor.value;
          return _buildLockedField(
            vendor?.mobileNo ?? controller.vendorMobileController.text,
            hint: "Auto-filled on selecting vendor",
          );
        }),

        const SizedBox(height: 14),

        // Vendor Address
        const Text(
          "Vendor Address",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
        ),
        const SizedBox(height: 6),
        Obx(() {
          final vendor = controller.selectedVendor.value;
          return _buildLockedField(
            vendor?.address ?? controller.vendorAddressController.text,
            hint: "Auto-filled on selecting vendor",
            maxLines: 2,
          );
        }),

        const SizedBox(height: 14),

        // Vendor GST
        const Text(
          "Vendor GST",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
        ),
        const SizedBox(height: 6),
        Obx(() {
          final vendor = controller.selectedVendor.value;
          return _buildLockedField(
            vendor?.gst ?? controller.vendorGstController.text,
            hint: "Auto-filled on selecting vendor",
          );
        }),
      ],
    );
  }

  // ── Read-only Locked Field Widget ──
  Widget _buildLockedField(String value, {required String hint, int maxLines = 1}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Text(
        value.isNotEmpty ? value : hint,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: value.isNotEmpty ? Colors.black87 : Colors.grey.shade500,
          fontStyle: value.isNotEmpty ? FontStyle.normal : FontStyle.italic,
        ),
      ),
    );
  }

  // ── Vendor Search Dialog ──
  void _showVendorSearchDialog() {
    final searchCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 480,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Vendor",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: "Search vendor name or mobile...",
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (val) {
                      controller.fetchVendors(val);
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadingVendors.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.vendorsList.isEmpty) {
                        return const Center(
                          child: Text(
                            "No vendors found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: controller.vendorsList.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final v = controller.vendorsList[index];
                          return ListTile(
                            title: Text(
                              v.name ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              "Mob: ${v.mobileNo ?? 'N/A'} • GST: ${v.gst ?? 'N/A'}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            onTap: () {
                              controller.selectVendor(v);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Step 2: Multi-Select Material Category (Tier 2) ──
  Widget _buildMaterialCategoryMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Material *",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showMaterialCategoryCheckboxDialog(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.buttonBlue, width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => Text(
                        controller.selectedCategoriesDisplay,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: controller.selectedCategorySlugs.isNotEmpty
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: controller.selectedCategorySlugs.isNotEmpty
                              ? Colors.black87
                              : Colors.grey.shade500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Material Category Multi-Select Checkbox Dialog (Screenshot 3) ──
  void _showMaterialCategoryCheckboxDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Choose Material Categories",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: AllMaterialsCatalog.categories.length,
                  itemBuilder: (context, index) {
                    final cat = AllMaterialsCatalog.categories[index];
                    return Obx(() {
                      final isChecked = controller.isCategorySelected(cat.slug);
                      return CheckboxListTile(
                        title: Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                            color: isChecked ? AppColor.buttonBlue : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          "Sub-types: ${cat.subItems.length} items",
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        value: isChecked,
                        activeColor: AppColor.buttonBlue,
                        onChanged: (_) {
                          controller.toggleCategory(cat.slug);
                        },
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.buttonBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Done", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 3: Cascading Dynamic Subtype Dropdowns & Dynamic Grid (Screenshot 4) ──
  Widget _buildDynamicCategorySections() {
    return Obx(() {
      final selectedSlugs = controller.selectedCategorySlugs.toList();
      if (selectedSlugs.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Select one or more materials above to add items to your order.",
                  style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: selectedSlugs.map((slug) {
          final meta = AllMaterialsCatalog.getCategoryBySlug(slug);
          if (meta == null) return const SizedBox.shrink();
          return _buildCategoryItemBlock(meta);
        }).toList(),
      );
    });
  }

  // ── Block for a Single Selected Category (Subtype dropdown + Item Table) ──
  Widget _buildCategoryItemBlock(MaterialCategoryMeta meta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtype Dropdown Label
          Text(
            meta.label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
          ),
          const SizedBox(height: 6),

          // Subtype Dropdown (Adds item upon selection)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text("Select ${meta.label}", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                items: meta.subItems.map((subItem) {
                  return DropdownMenuItem<String>(
                    value: subItem,
                    child: Text(subItem, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (selectedSubItem) {
                  if (selectedSubItem != null) {
                    controller.addSubtypeItem(meta.slug, selectedSubItem);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Table Header Banner
          Obx(() {
            final items = controller.getItemsForCategory(meta.slug);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.format_list_bulleted, size: 16, color: AppColor.buttonBlue),
                    const SizedBox(width: 6),
                    Text(
                      "${meta.label} Items (${items.length})",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColor.buttonBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "No items selected yet. Choose a subtype from dropdown above.",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                  )
                else ...[
                  // Responsive Items Table
                  _buildItemsTable(meta, items),
                  const SizedBox(height: 12),

                  // Subtotal row
                  _buildCategorySubtotalRow(meta),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Category Items Table ──
  Widget _buildItemsTable(MaterialCategoryMeta meta, List<AllMaterialOrderItem> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
          headingTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          dataRowMinHeight: 64,
          dataRowMaxHeight: 64,
          headingRowHeight: 40,
          horizontalMargin: 12,
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('ITEM / MATERIAL')),
            DataColumn(label: Text('QUANTITY *')),
            DataColumn(label: Text('UNIT')),
            DataColumn(label: Text('PRICE / ITEM (₹)')),
            DataColumn(label: Text('TOTAL (₹)')),
            DataColumn(label: Text('GST')),
            DataColumn(label: Text('TOTAL INCL. GST')),
            DataColumn(label: Text('ACTION')),
          ],
          rows: items.map((item) {
            return DataRow(
              cells: [
                // 1. Item Name Badge
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200, width: 0.8),
                    ),
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ),

                // 2. Quantity Input
                DataCell(
                  SizedBox(
                    width: 75,
                    child: TextField(
                      controller: item.quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        hintText: "Qty *",
                      ),
                    ),
                  ),
                ),

                // 3. Unit Dropdown
                DataCell(
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: item.unit.value,
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                            items: AllMaterialsCatalog.standardUnits.map((u) {
                              return DropdownMenuItem<String>(
                                value: u,
                                child: Text(u),
                              );
                            }).toList(),
                            onChanged: (newUnit) {
                              if (newUnit != null) {
                                item.unit.value = newUnit;
                                controller.calculationTrigger.value++;
                              }
                            },
                          ),
                        ),
                      )),
                ),

                // 4. Price / Item (Rate) Input
                DataCell(
                  SizedBox(
                    width: 85,
                    child: TextField(
                      controller: item.priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        hintText: "₹ / unit",
                      ),
                    ),
                  ),
                ),

                // 5. Total (Base Total)
                DataCell(
                  Obx(() {
                    item.changeNotifier.value;
                    final val = item.baseTotal;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        val > 0 ? "₹ ${val.toStringAsFixed(2)}" : "Total ₹",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: val > 0 ? Colors.black87 : Colors.grey.shade500,
                        ),
                      ),
                    );
                  }),
                ),

                // 6. GST Dropdown
                DataCell(
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<double>(
                            value: item.gstRate.value,
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                            items: AllMaterialsCatalog.gstRates.map((r) {
                              return DropdownMenuItem<double>(
                                value: r,
                                child: Text("${r.toInt()}%"),
                              );
                            }).toList(),
                            onChanged: (newGst) {
                              if (newGst != null) {
                                item.gstRate.value = newGst;
                                controller.calculationTrigger.value++;
                              }
                            },
                          ),
                        ),
                      )),
                ),

                // 7. Total Incl. GST
                DataCell(
                  Obx(() {
                    item.changeNotifier.value;
                    final val = item.totalInclGst;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        val > 0 ? "₹ ${val.toStringAsFixed(2)}" : "Auto",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: val > 0 ? const Color(0xFF0B9F08) : Colors.grey.shade500,
                        ),
                      ),
                    );
                  }),
                ),

                // 8. Delete Button (Red [X])
                DataCell(
                  InkWell(
                    onTap: () => controller.removeOrderItem(item),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: const Icon(Icons.close, color: Colors.red, size: 16),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Category Subtotal Row ──
  Widget _buildCategorySubtotalRow(MaterialCategoryMeta meta) {
    return Obx(() {
      final subQty = controller.getCategorySubtotalQty(meta.slug);
      final subBase = controller.getCategorySubtotalBase(meta.slug);
      final subIncl = controller.getCategorySubtotalInclGst(meta.slug);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Subtotal (${meta.label}):",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                  "Qty: ${subQty.toString().replaceAll(RegExp(r'\.0$'), '')}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  "Base: ₹${subBase.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  "Total: ₹${subIncl.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0B9F08)),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ── Step 4: Summary & Order Dispatch Section (Screenshot 5) ──
  Widget _buildSummaryDispatchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Field
        const Text(
          "Date *",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              controller.dateController.text = DateFormat('dd-MM-yyyy').format(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.dateController.text,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Total Quantity (Auto-calculated from selected items or manual entry)
        const Text(
          "Quantity",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 6),
        Obx(() {
          final hasItems = controller.orderItems.isNotEmpty;
          if (!hasItems) {
            return TextField(
              controller: controller.manualQuantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                isDense: true,
                hintText: "Enter quantity",
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
          final totalQty = controller.overallTotalQuantity;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLockedField(
                totalQty > 0 ? totalQty.toString().replaceAll(RegExp(r'\.0$'), '') : "0",
                hint: "Enter quantity",
              ),
              const SizedBox(height: 4),
              const Text(
                "✓ Auto-calculated from selected items",
                style: TextStyle(fontSize: 11, color: Color(0xFF0B9F08), fontWeight: FontWeight.w500),
              ),
            ],
          );
        }),

        const SizedBox(height: 14),

        // Supervisor Name
        const Text(
          "Supervisor Name",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller.supervisorNameController,
          decoration: InputDecoration(
            isDense: true,
            hintText: "Enter supervisor name",
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        const SizedBox(height: 14),

        // Supervisor Phone No
        const Text(
          "Supervisor Phone No",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller.supervisorMobController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            isDense: true,
            hintText: "Enter supervisor phone number",
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        const SizedBox(height: 14),

        // Total Price (₹) (Auto-calculated from selected items or manual entry)
        const Text(
          "Total Price (₹)",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 6),
        Obx(() {
          final hasItems = controller.orderItems.isNotEmpty;
          if (!hasItems) {
            return TextField(
              controller: controller.manualPriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                isDense: true,
                hintText: "Enter total price",
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
          final totalPrice = controller.overallTotalBasePrice;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLockedField(
                totalPrice > 0 ? totalPrice.toStringAsFixed(2) : "0.00",
                hint: "Enter total price",
              ),
              const SizedBox(height: 4),
              const Text(
                "✓ Auto-calculated from selected items",
                style: TextStyle(fontSize: 11, color: Color(0xFF0B9F08), fontWeight: FontWeight.w500),
              ),
            ],
          );
        }),

        const SizedBox(height: 14),

        // GST Amount (₹)
        const Text(
          "GST Amount (₹)",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 6),
        Obx(() {
          final gstAmount = controller.overallTotalGstAmount;
          return _buildLockedField(
            gstAmount > 0 ? gstAmount.toStringAsFixed(2) : "",
            hint: "Auto calculated",
          );
        }),

        const SizedBox(height: 14),

        // Total Amount (₹) (Total incl. GST)
        const Text(
          "Total Amount (₹)",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 6),
        Obx(() {
          final grandTotal = controller.overallGrandTotal;
          return _buildLockedField(
            grandTotal > 0 ? grandTotal.toStringAsFixed(2) : "",
            hint: "Total incl. GST",
          );
        }),

        const SizedBox(height: 14),

        // Additional fields for Material Request Tab
        Obx(() {
          if (controller.selectedTabIndex.value == 1) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delivery Needed By",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.deliveryNeededByController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "e.g. Immediate, Within 2 days, etc.",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Remarks / Notes",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.remarksController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Urgent requirements, special instructions, etc.",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            );
          }
          return const SizedBox.shrink();
        }),

        // Invoice Attachment
        const Text(
          "Invoice / Attachment",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 6),
        Obx(() {
          final fileName = controller.invoiceFileName.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => _showAttachmentSourceDialog(),
                  child: const Text("Choose File", style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName.isNotEmpty ? fileName : "No file chosen",
                    style: TextStyle(
                      fontSize: 12,
                      color: fileName.isNotEmpty ? Colors.black87 : Colors.grey.shade500,
                      fontWeight: fileName.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (fileName.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () => controller.removeInvoice(),
                  ),
              ],
            ),
          );
        }),

        const SizedBox(height: 28),

        // Submit Button: "Inward Order" / "Submit Request"
        Obx(() {
          final isSubmitting = controller.isSubmitting.value;
          final isOrder = controller.selectedTabIndex.value == 0;
          return SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isOrder ? AppColor.buttonBlue : const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 2,
              ),
              onPressed: isSubmitting ? null : () => controller.submit(),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      isOrder ? "Inward Order" : "Submit Material Request",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          );
        }),
      ],
    );
  }

  // ── Attachment Source Dialog ──
  void _showAttachmentSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Capture with Camera'),
              onTap: () {
                Navigator.pop(ctx);
                controller.pickInvoiceImage(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Pick Image from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                controller.pickInvoiceImage(fromCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Upload Document (PDF / DOC)'),
              onTap: () {
                Navigator.pop(ctx);
                controller.pickInvoiceDocument();
              },
            ),
          ],
        ),
      ),
    );
  }
}
