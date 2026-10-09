import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/model/bricks_model.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/utils/file_picker_helper.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/view/material_category/bricks_details_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/custom_date_picker.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

import 'all_materials_screen.dart';

class AllMaterialsOrdersScreen extends StatefulWidget {
  final MaterialDetailsArgs args;

  const AllMaterialsOrdersScreen({super.key, required this.args});

  @override
  State<AllMaterialsOrdersScreen> createState() => _AllMaterialsOrdersScreenState();
}

class _AllMaterialsOrdersScreenState extends State<AllMaterialsOrdersScreen> {
  late final BricksDetailsController controller;
  bool isCardView = true; // Card View by default on mobile!

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<BricksDetailsController>()) {
      controller = Get.find<BricksDetailsController>();
    } else {
      controller = Get.put(
        BricksDetailsController(
          materialDetailsArgs: MaterialDetailsArgs(
            id: widget.args.id,
            siteName: widget.args.siteName,
            siteLocation: widget.args.siteLocation,
            itemKey: 'all',
            itemData: widget.args.itemData,
            supervisorId: widget.args.supervisorId,
            supervisorName: widget.args.supervisorName,
            supervisorMob: widget.args.supervisorMob,
          ),
        ),
      );
    }
  }

  void _pickMonth() async {
    final result = await showCustomMonthPicker(
      context,
      controller.selectedYear.value,
      initialMonth: controller.selectedMonth.value,
    );
    if (result != null) {
      final parts = result.split("-");
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      controller.onMonthSelected(year, month);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: CommonAppBar.appBar(
        title: "All Details",
        centerTitle: false,
        onTap: () => Get.back(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.buttonBlue,
                side: BorderSide(color: AppColor.buttonBlue, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => Get.back(),
              child: const Text("Back", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Breadcrumbs Bar (Screenshot 2) ──
              _buildBreadcrumbHeader(),
              const SizedBox(height: 14),

              // ── Main Card Container ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Site Name & Filters Header
                    _buildSiteHeaderAndFilters(),
                    const SizedBox(height: 20),

                    // "All Overview" Title + Action Buttons & View Toggle
                    _buildOverviewActionHeader(),
                    const SizedBox(height: 14),

                    // Main Orders Content (Card View / Table View + Bottom TOTAL Bar)
                    _buildOrdersContent(),
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
        color: const Color(0xFFE8F2FD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD0E3FB), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.home_outlined, color: Color(0xFF1976D2), size: 18),
          const SizedBox(width: 8),
          const Text("Site", style: TextStyle(fontSize: 13, color: Color(0xFF1976D2), fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF1976D2)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              widget.args.siteName,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1976D2), fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF1976D2)),
          const SizedBox(width: 6),
          const Text("All Details", style: TextStyle(fontSize: 13, color: Color(0xFF0D47A1), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── Site Header & Date Filters (Screenshot 2) ──
  Widget _buildSiteHeaderAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Site Name: ${widget.args.siteName}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Month Picker Button
            InkWell(
              onTap: _pickMonth,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() {
                      final monthStr = DateFormat('MMMM, yyyy').format(
                        DateTime(controller.selectedYear.value, controller.selectedMonth.value),
                      );
                      return Text(
                        monthStr,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      );
                    }),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today_outlined, size: 15, color: Colors.black54),
                  ],
                ),
              ),
            ),

            // Week / Month Filters
            Obx(() {
              final activeWeek = controller.selectedWeek.value;
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  // Full Month Pill
                  _buildFilterChip(
                    label: "Full Month",
                    isSelected: activeWeek == null || activeWeek == 0,
                    activeColor: const Color(0xFF0F766E), // Dark Teal / Green
                    onTap: () => controller.onWeekSelected(0),
                  ),
                  _buildFilterChip(
                    label: "Week 1",
                    isSelected: activeWeek == 1,
                    onTap: () => controller.onWeekSelected(1),
                  ),
                  _buildFilterChip(
                    label: "Week 2",
                    isSelected: activeWeek == 2,
                    onTap: () => controller.onWeekSelected(2),
                  ),
                  _buildFilterChip(
                    label: "Week 3",
                    isSelected: activeWeek == 3,
                    onTap: () => controller.onWeekSelected(3),
                  ),
                  _buildFilterChip(
                    label: "Week 4",
                    isSelected: activeWeek == 4,
                    onTap: () => controller.onWeekSelected(4),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected ? (activeColor ?? const Color(0xFF2563EB)) : const Color(0xFF0F172A);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // ── Overview Action Header + View Switcher ──
  Widget _buildOverviewActionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "All Overview",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            Row(
              children: [
                // Inward Order Button (Blue)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    await Get.to(
                      () => const AllMaterialsManagementScreen(),
                      arguments: widget.args,
                    );
                    controller.fetchData();
                  },
                  child: const Text(
                    "Inward Order",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                // Export Button (Green)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                  ),
                  onPressed: () => _showExportDialog(context),
                  child: const Text(
                    "Export",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        // View Toggle Switch: Card View vs Table View
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => isCardView = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isCardView ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isCardView
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.view_agenda_outlined, size: 14, color: isCardView ? const Color(0xFF2563EB) : Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            "Cards",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isCardView ? FontWeight.bold : FontWeight.normal,
                              color: isCardView ? const Color(0xFF2563EB) : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => isCardView = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: !isCardView ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: !isCardView
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.table_chart_outlined, size: 14, color: !isCardView ? const Color(0xFF2563EB) : Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            "Table",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: !isCardView ? FontWeight.bold : FontWeight.normal,
                              color: !isCardView ? const Color(0xFF2563EB) : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Main Orders Content with Card View / Table View + Bottom TOTAL Bar ──
  Widget _buildOrdersContent() {
    return Obx(() {
      final list = controller.getBricksLists;

      if (list.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                "No materials found for this month.",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content Display (Card View or Table View)
          if (isCardView)
            _buildOrdersCardsList(list)
          else
            _buildOrdersDataTable(list),

          // ── Bottom TOTAL Summary Bar (Screenshot 5) ──
          _buildTotalSummaryBar(list),
        ],
      );
    });
  }

  // ── Helper to check if an item is the primary/last row of its order group (Screenshot 4) ──
  bool _isLastItemInOrderGroup(List<BricksList> list, int index) {
    if (index < 0 || index >= list.length) return false;
    if (index == list.length - 1) return true;

    final current = list[index];
    final next = list[index + 1];

    if (current.orderNo != null && current.orderNo!.isNotEmpty && next.orderNo != null && next.orderNo!.isNotEmpty) {
      return current.orderNo != next.orderNo;
    }

    final sameVendor = current.vendorId != null && next.vendorId != null && current.vendorId == next.vendorId;
    final sameDate = current.date != null && next.date != null && current.date == next.date;
    final sameTimestamp = current.createdAt != null && next.createdAt != null && current.createdAt == next.createdAt;

    if (sameVendor && (sameDate || sameTimestamp)) {
      return false;
    }

    return true;
  }

  // ── Card View List (Native Mobile Friendly) ──
  Widget _buildOrdersCardsList(List<BricksList> list) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final showActions = _isLastItemInOrderGroup(list, index);
        return _buildOrderCard(list[index], index + 1, showActions);
      },
    );
  }

  Widget _buildOrderCard(BricksList item, int index, bool showActions) {
    String dateFormatted = item.date ?? '-';
    try {
      if (item.date != null && item.date!.isNotEmpty) {
        final dt = DateTime.parse(item.date!);
        dateFormatted = DateFormat('dd-MM-yyyy').format(dt);
      }
    } catch (_) {}

    final materialType = _formatCapitalize(item.materialType ?? 'Materials');
    final category = item.category ?? item.materialType ?? '-';
    final spec = (item.specification != null && item.specification!.isNotEmpty) ? item.specification! : '-';
    final quantityStr = "${item.quantity ?? '0'} ${item.unit ?? 'Nos'}";
    final pricePerItemStr = item.pricePerItem != null ? "₹ ${NumberFormat('#,##0.00').format(item.pricePerItem)}" : "₹ 1,000.00";
    final priceStr = item.price != null ? "₹ ${NumberFormat('#,##0.00').format(item.price)}" : "₹ 2,000.00";
    final gstStr = (item.gst != null && item.gst!.isNotEmpty && item.gst != '0') ? "${item.gst}%" : "-";
    final totalAmountStr = item.totalAmount != null ? "₹ ${NumberFormat('#,##0.00').format(item.totalAmount)}" : priceStr;
    final vendor = item.vendorName ?? 'Sai bricks';
    final vendorGstin = item.vendorGstin ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: S.No + Date + Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "S.NO #$index",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormatted,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              if (showActions)
                // Action Icons: Edit, Delete, PDF
                Row(
                  children: [
                    InkWell(
                      onTap: () => _showEditOrderModal(item),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF2563EB)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _showConfirmDeleteDialog(item),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        if (item.id != null) {
                          controller.materialPdfDownload(context, item.id!);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: Color(0xFFDC2626)),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Multi-Item Order",
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
          const Divider(height: 16),

          // Row 2: Material Type & Category Pill
          Row(
            children: [
              Text(
                materialType,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (spec != '-') ...[
            const SizedBox(height: 4),
            Text(
              "Spec: $spec",
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
          const SizedBox(height: 10),

          // Metrics Grid Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricCell("Quantity", quantityStr, isBold: true),
                    _buildMetricCell("Price / Item", pricePerItemStr),
                    _buildMetricCell("Price", priceStr),
                  ],
                ),
                const Divider(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricCell("GST", gstStr),
                    _buildMetricCell("Total Amount", totalAmountStr, isBold: true, color: const Color(0xFF2563EB)),
                    if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                      InkWell(
                        onTap: () => _showImagePreviewDialog(item.imageUrl!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long, size: 13, color: Color(0xFF2563EB)),
                              SizedBox(width: 4),
                              Text("Invoice", style: TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    else
                      _buildMetricCell("Invoice", "-"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Row 4: Vendor & GSTIN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    const Icon(Icons.storefront_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        vendor,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "GSTIN: $vendorGstin",
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCell(String label, String value, {bool isBold = false, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // ── Table View ──
  Widget _buildOrdersDataTable(List<BricksList> list) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          horizontalMargin: 12,
          columnSpacing: 18,
          headingTextStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
          dataRowMaxHeight: 54,
          dataRowMinHeight: 48,
          columns: const [
            DataColumn(label: Text("S.NO")),
            DataColumn(label: Text("DATE")),
            DataColumn(label: Text("MATERIAL TYPE")),
            DataColumn(label: Text("CATEGORY")),
            DataColumn(label: Text("SPECIFICATION")),
            DataColumn(label: Text("QUANTITY")),
            DataColumn(label: Text("PRICE / ITEM")),
            DataColumn(label: Text("PRICE")),
            DataColumn(label: Text("GST")),
            DataColumn(label: Text("TOTAL AMOUNT")),
            DataColumn(label: Text("VENDOR")),
            DataColumn(label: Text("VENDOR GSTIN")),
            DataColumn(label: Text("INVOICE")),
            DataColumn(label: Text("ACTION")),
          ],
          rows: list.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            final showActions = _isLastItemInOrderGroup(list, entry.key);

            String dateFormatted = item.date ?? '-';
            try {
              if (item.date != null && item.date!.isNotEmpty) {
                final dt = DateTime.parse(item.date!);
                dateFormatted = DateFormat('dd-MM-yyyy').format(dt);
              }
            } catch (_) {}

            final materialType = _formatCapitalize(item.materialType ?? 'Materials');
            final category = item.category ?? item.materialType ?? '-';
            final spec = (item.specification != null && item.specification!.isNotEmpty)
                ? item.specification!
                : '-';
            final quantityStr = "${item.quantity ?? '0'} ${item.unit ?? 'Nos'}";
            final pricePerItemStr = item.pricePerItem != null
                ? "₹ ${NumberFormat('#,##0.00').format(item.pricePerItem)}"
                : "₹ 1,000.00";
            final priceStr = item.price != null
                ? "₹ ${NumberFormat('#,##0.00').format(item.price)}"
                : "₹ 2,000.00";
            final gstStr = (item.gst != null && item.gst!.isNotEmpty && item.gst != '0')
                ? "${item.gst}%"
                : "-";
            final totalAmountStr = item.totalAmount != null
                ? "₹ ${NumberFormat('#,##0.00').format(item.totalAmount)}"
                : priceStr;
            final vendor = item.vendorName ?? 'Sai bricks';
            final vendorGstin = item.vendorGstin ?? '-';

            return DataRow(
              cells: [
                DataCell(Text("$index", style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
                DataCell(Text(dateFormatted, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
                DataCell(Text(materialType, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(spec, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),
                DataCell(Text(quantityStr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                DataCell(Text(pricePerItemStr, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
                DataCell(Text(priceStr, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
                DataCell(Text(gstStr, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
                DataCell(Text(totalAmountStr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                DataCell(Text(vendor, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
                DataCell(Text(vendorGstin, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
                DataCell(
                  item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? InkWell(
                          onTap: () => _showImagePreviewDialog(item.imageUrl!),
                          child: const Icon(Icons.receipt_long, color: Color(0xFF2563EB), size: 20),
                        )
                      : const Text("-", style: TextStyle(color: Colors.grey)),
                ),
                DataCell(
                  showActions
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _showEditOrderModal(item),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF2563EB)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => _showConfirmDeleteDialog(item),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                if (item.id != null) {
                                  controller.materialPdfDownload(context, item.id!);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: Color(0xFFDC2626)),
                              ),
                            ),
                          ],
                        )
                      : const Center(
                          child: Text("-", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Bottom TOTAL Summary Bar (Screenshot 5) ──
  Widget _buildTotalSummaryBar(List<BricksList> list) {
    double totalUnits = 0.0;
    double totalSumAmount = 0.0;

    for (var item in list) {
      totalUnits += double.tryParse(item.quantity ?? '0') ?? 0.0;
      if (item.totalAmount != null) {
        totalSumAmount += item.totalAmount!;
      } else if (item.price != null) {
        totalSumAmount += item.price!;
      }
    }

    // Fallback to controller model totals if available
    final modelUnits = controller.bricksModel?.value?.totalUnits;
    final modelAmount = controller.bricksModel?.value?.totalAmount;

    final displayUnits = (modelUnits != null && modelUnits > 0)
        ? "$modelUnits Units"
        : "${totalUnits.toString().replaceAll(RegExp(r'\.0$'), '')} Units";

    final displayAmount = (modelAmount != null && modelAmount > 0)
        ? "₹ ${NumberFormat('#,##0.00').format(modelAmount)}"
        : "₹ ${NumberFormat('#,##0.00').format(totalSumAmount)}";

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "TOTAL",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1D4ED8)),
          ),
          Text(
            displayUnits,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1D4ED8)),
          ),
          Text(
            displayAmount,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1D4ED8)),
          ),
        ],
      ),
    );
  }

  // ── Export Modal (Matching Screenshot) ──
  void _showExportDialog(BuildContext context) {
    DateTime? fromDate;
    DateTime? toDate;
    final fromDateCtrl = TextEditingController();
    final toDateCtrl = TextEditingController();

    Future<void> pickDate(bool isFrom, StateSetter setModalState) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isFrom
            ? (fromDate ?? DateTime.now())
            : (toDate ?? fromDate ?? DateTime.now()),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setModalState(() {
          if (isFrom) {
            fromDate = picked;
            fromDateCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
          } else {
            toDate = picked;
            toDateCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
          }
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 480,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header: "Export All" + Close Button ──
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 12, top: 12, bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Export All",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
                            onPressed: () => Navigator.pop(dialogCtx),
                            splashRadius: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),

                    // ── Form Content ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // From Date
                          const Text(
                            "From Date",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => pickDate(true, setModalState),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    fromDateCtrl.text.isNotEmpty ? fromDateCtrl.text : "dd-mm-yyyy",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: fromDateCtrl.text.isNotEmpty ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // To Date
                          const Text(
                            "To Date",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => pickDate(false, setModalState),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    toDateCtrl.text.isNotEmpty ? toDateCtrl.text : "dd-mm-yyyy",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: toDateCtrl.text.isNotEmpty ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Actions: [ Cancel ] [ Download ] ──
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B50A0), // Purple matching screenshot
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB), // Blue matching screenshot
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              elevation: 0,
                            ),
                            onPressed: () {
                              if (fromDateCtrl.text.isEmpty || toDateCtrl.text.isEmpty) {
                                showToastMessage("Please select both From Date and To Date");
                                return;
                              }
                              Navigator.pop(dialogCtx);
                              final apiFrom = fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : fromDateCtrl.text;
                              final apiTo = toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : toDateCtrl.text;
                              controller.materialExcelDownload(context, fromDate: apiFrom, toDate: apiTo);
                            },
                            child: const Text("Download", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Edit Order Modal (Screenshot 4) ──
  void _showEditOrderModal(BricksList orderItem) {
    List<Map<String, dynamic>> editableItems = [];

    if (orderItem.rawItems != null) {
      try {
        dynamic parsed = orderItem.rawItems;
        if (parsed is String) parsed = jsonDecode(parsed);
        if (parsed is List) {
          for (var itm in parsed) {
            editableItems.add({
              "material": itm['material'] ?? itm['category'] ?? orderItem.materialType ?? 'Materials',
              "name": itm['name'] ?? itm['item_name'] ?? orderItem.category ?? 'Material Item',
              "qty": TextEditingController(text: (itm['quantity'] ?? itm['qty'] ?? '1').toString()),
              "unit": itm['unit'] ?? orderItem.unit ?? 'Nos',
              "price": TextEditingController(text: (itm['price'] ?? itm['rate'] ?? '1000').toString()),
              "gst": (itm['gst'] ?? 0.0).toDouble(),
            });
          }
        }
      } catch (_) {}
    }

    if (editableItems.isEmpty) {
      if (orderItem.orderNo != null && orderItem.orderNo!.isNotEmpty) {
        final group = controller.getBricksLists
            .where((b) => b.orderNo == orderItem.orderNo)
            .toList();
        if (group.isNotEmpty) {
          for (var b in group) {
            final double rate = b.pricePerItem ?? (b.price != null ? (b.price! / (double.tryParse(b.quantity ?? '1') ?? 1.0)) : 1000.0);
            editableItems.add({
              "id": b.id,
              "material": _formatCapitalize(b.materialType ?? 'Materials'),
              "name": b.category ?? b.materialType ?? 'Material Item',
              "qty": TextEditingController(text: b.quantity ?? '1'),
              "unit": b.unit ?? 'Nos',
              "price": TextEditingController(text: rate.toInt().toString()),
              "gst": double.tryParse(b.gst ?? '0') ?? 0.0,
            });
          }
        }
      } else {
        // Fallback: group by vendor and date
        final group = controller.getBricksLists
            .where((b) => b.vendorId == orderItem.vendorId && b.date == orderItem.date)
            .toList();
        if (group.length > 1) {
          for (var b in group) {
            final double rate = b.pricePerItem ?? (b.price != null ? (b.price! / (double.tryParse(b.quantity ?? '1') ?? 1.0)) : 1000.0);
            editableItems.add({
              "id": b.id,
              "material": _formatCapitalize(b.materialType ?? 'Materials'),
              "name": b.category ?? b.materialType ?? 'Material Item',
              "qty": TextEditingController(text: b.quantity ?? '1'),
              "unit": b.unit ?? 'Nos',
              "price": TextEditingController(text: rate.toInt().toString()),
              "gst": double.tryParse(b.gst ?? '0') ?? 0.0,
            });
          }
        }
      }
    }

    if (editableItems.isEmpty) {
      editableItems.add({
        "id": orderItem.id,
        "material": _formatCapitalize(orderItem.materialType ?? 'Materials'),
        "name": orderItem.category ?? orderItem.materialType ?? 'Material Item',
        "qty": TextEditingController(text: orderItem.quantity ?? '1'),
        "unit": orderItem.unit ?? 'Nos',
        "price": TextEditingController(text: (orderItem.pricePerItem ?? 1000).toInt().toString()),
        "gst": double.tryParse(orderItem.gst ?? '0') ?? 0.0,
      });
    }

    final dateCtrl = TextEditingController(text: orderItem.date ?? DateFormat('dd-MM-yyyy').format(DateTime.now()));
    try {
      if (orderItem.date != null && orderItem.date!.isNotEmpty) {
        final dt = DateTime.parse(orderItem.date!);
        dateCtrl.text = DateFormat('dd-MM-yyyy').format(dt);
      }
    } catch (_) {}

    File? newInvoiceFile;
    String newInvoiceName = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double subtotal = 0.0;
            double totalGst = 0.0;

            for (var item in editableItems) {
              final q = double.tryParse((item['qty'] as TextEditingController).text) ?? 0.0;
              final p = double.tryParse((item['price'] as TextEditingController).text) ?? 0.0;
              final g = item['gst'] as double;
              final lineBase = q * p;
              final lineGst = lineBase * (g / 100.0);
              subtotal += lineBase;
              totalGst += lineGst;
            }

            final grandTotal = subtotal + totalGst;
            final amountWords = _numberToWordsIndian(grandTotal.round());
            final orderBadge = orderItem.orderNo ?? "ORD-${orderItem.id ?? 'CCFB'}";

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Container(
                width: 780,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header (Screenshot 4) ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_note, color: Color(0xFF2563EB), size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            "Edit Order",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                orderBadge,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                    ),

                    // ── Body Scrollable ──
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order Date, Vendor Name, Vendor GSTIN
                            Column(
                              children: [
                                _buildModalDateField(dateCtrl, setModalState),
                                const SizedBox(height: 12),
                                _buildModalLockedField("Vendor Name", orderItem.vendorName ?? 'Sai bricks'),
                                const SizedBox(height: 12),
                                _buildModalLockedField("Vendor GSTIN", orderItem.vendorGstin ?? '454548154518'),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Order Items Section
                            Row(
                              children: [
                                const Icon(Icons.shopping_bag_outlined, color: Color(0xFF6366F1), size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  "Order Items",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Order Items Table
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                                  dataRowMaxHeight: 64,
                                  dataRowMinHeight: 56,
                                  horizontalMargin: 12,
                                  columnSpacing: 16,
                                  headingTextStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                  columns: const [
                                    DataColumn(label: Text("MATERIAL & ITEM")),
                                    DataColumn(label: Text("QUANTITY")),
                                    DataColumn(label: Text("UNIT")),
                                    DataColumn(label: Text("PRICE / ITEM (₹)")),
                                    DataColumn(label: Text("PRICE (₹)")),
                                    DataColumn(label: Text("GST")),
                                    DataColumn(label: Text("TOTAL INCL. GST (₹)")),
                                  ],
                                  rows: editableItems.map((item) {
                                    final qtyCtrl = item['qty'] as TextEditingController;
                                    final priceCtrl = item['price'] as TextEditingController;
                                    final q = double.tryParse(qtyCtrl.text) ?? 0.0;
                                    final p = double.tryParse(priceCtrl.text) ?? 0.0;
                                    final g = item['gst'] as double;
                                    final lineBase = q * p;
                                    final lineTotal = lineBase + (lineBase * (g / 100.0));

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item['name'],
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item['material'],
                                                  style: const TextStyle(fontSize: 10, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 60,
                                            child: TextField(
                                              controller: qtyCtrl,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                              onChanged: (_) => setModalState(() {}),
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(item['unit'], style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                                        DataCell(
                                          SizedBox(
                                            width: 80,
                                            child: TextField(
                                              controller: priceCtrl,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                              onChanged: (_) => setModalState(() {}),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            lineBase.toStringAsFixed(0),
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                                          ),
                                        ),
                                        DataCell(
                                          DropdownButton<double>(
                                            value: g,
                                            isDense: true,
                                            underline: const SizedBox(),
                                            items: const [0.0, 5.0, 12.0, 18.0, 28.0]
                                                .map((rate) => DropdownMenuItem(
                                                      value: rate,
                                                      child: Text("${rate.toInt()}%", style: const TextStyle(fontSize: 12)),
                                                    ))
                                                .toList(),
                                            onChanged: (newRate) {
                                              if (newRate != null) {
                                                item['gst'] = newRate;
                                                setModalState(() {});
                                              }
                                            },
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            lineTotal.toStringAsFixed(0),
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Subtotal & Total Row (Responsive Wrap to prevent 61px overflow)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 14,
                                runSpacing: 6,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text("Subtotal: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                      Text("₹ ${NumberFormat('#,##0.00').format(subtotal)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text("GST: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                      Text("₹ ${NumberFormat('#,##0.00').format(totalGst)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    ],
                                  ),
                                  Text(
                                    "₹ ${NumberFormat('#,##0.00').format(grandTotal)}",
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Amount in words (Screenshot 4: Green Text)
                            Text(
                              "₹ $amountWords",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Invoice Attachment Section (Screenshot 1) ──
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Invoice Attachment",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Existing or selected image preview row (Screenshot 1)
                                  if ((orderItem.imageUrl != null && orderItem.imageUrl!.isNotEmpty) || newInvoiceFile != null) ...[
                                    InkWell(
                                      onTap: () {
                                        if (newInvoiceFile != null) {
                                          _showImagePreviewDialog('', localFile: newInvoiceFile);
                                        } else if (orderItem.imageUrl != null && orderItem.imageUrl!.isNotEmpty) {
                                          _showImagePreviewDialog(orderItem.imageUrl!);
                                        }
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: const Color(0xFFCBD5E1)),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: newInvoiceFile != null
                                                ? Image.file(newInvoiceFile!, fit: BoxFit.cover)
                                                : Image.network(
                                                    orderItem.imageUrl!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => const Icon(Icons.receipt_long, color: Color(0xFF64748B), size: 24),
                                                  ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            "Click to view full image",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF475569),
                                              decoration: TextDecoration.underline,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],

                                  // Choose file button & filename
                                  InkWell(
                                    onTap: () async {
                                      final file = await FilePickerHelper.pickImage();
                                      if (file != null) {
                                        setModalState(() {
                                          newInvoiceFile = file;
                                          newInvoiceName = file.path.split(Platform.pathSeparator).last;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFCBD5E1)),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: const Color(0xFFE2E8F0)),
                                            ),
                                            child: const Text("Choose File", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              newInvoiceName.isNotEmpty
                                                  ? newInvoiceName
                                                  : (orderItem.imageUrl != null && orderItem.imageUrl!.isNotEmpty
                                                      ? orderItem.imageUrl!.split('/').last
                                                      : "No file chosen"),
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "Upload a new file (Image or PDF) to update the invoice for this order.",
                                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Modal Actions ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF475569),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            onPressed: () => Navigator.pop(modalCtx),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () async {
                              Navigator.pop(modalCtx);

                              List<Map<String, dynamic>> itemsPayload = [];
                              double totalOrderQty = 0.0;
                              for (var item in editableItems) {
                                final q = (item['qty'] as TextEditingController).text.trim();
                                final p = (item['price'] as TextEditingController).text.trim();
                                final g = (item['gst'] as double);
                                final u = item['unit'] as String;
                                final n = item['name'] as String;
                                final m = item['material'] as String;
                                final qVal = double.tryParse(q) ?? 0.0;
                                final pVal = double.tryParse(p) ?? 0.0;
                                final lineBase = qVal * pVal;
                                final lineGst = lineBase * (g / 100.0);
                                final lineTotal = lineBase + lineGst;
                                totalOrderQty += qVal;

                                itemsPayload.add({
                                  if (item['id'] != null) "id": item['id'],
                                  "name": n,
                                  "item_name": n,
                                  "material": m,
                                  "category": m,
                                  "quantity": q,
                                  "unit": u,
                                  "price": p,
                                  "rate": p,
                                  "gst": g.toString(),
                                  "gst_rate": g,
                                  "gst_amount": lineGst.toStringAsFixed(2),
                                  "total": lineTotal.toStringAsFixed(2),
                                });
                              }

                              final Map<String, dynamic> updatePayload = {
                                "material_type": (orderItem.materialType != null && orderItem.materialType!.isNotEmpty)
                                    ? orderItem.materialType!
                                    : (editableItems.isNotEmpty && editableItems.first['material'] != null && editableItems.first['material'].toString().isNotEmpty)
                                        ? editableItems.first['material'].toString()
                                        : "all",
                                "date": dateCtrl.text.trim(),
                                "quantity": totalOrderQty > 0 ? totalOrderQty.toString().replaceAll(RegExp(r'\.0$'), '') : "1",
                                "unit": editableItems.isNotEmpty ? editableItems.first['unit'] : 'Units',
                                "price": subtotal.toStringAsFixed(2),
                                "unit_price": totalOrderQty > 0 ? (subtotal / totalOrderQty).toStringAsFixed(2) : subtotal.toStringAsFixed(2),
                                "gst": totalGst.toStringAsFixed(2),
                                "amount": grandTotal.toStringAsFixed(2),
                                "site_id": widget.args.id.toString(),
                                "vendor_id": orderItem.vendorId?.toString() ?? '',
                                "items": jsonEncode(itemsPayload),
                                "items_summary": itemsPayload.map((e) => "${e['name']} [${e['quantity']} ${e['unit']}]").join(", "),
                              };

                              if (orderItem.orderNo != null && orderItem.orderNo!.isNotEmpty) {
                                updatePayload["order_no"] = orderItem.orderNo;
                              }

                              final int? targetId = orderItem.id ?? (editableItems.isNotEmpty && editableItems.first['id'] != null ? editableItems.first['id'] as int : null);
                              if (targetId != null) {
                                Navigator.pop(modalCtx);
                                await controller.updateMaterial(
                                  targetId,
                                  updatePayload,
                                  attachment: newInvoiceFile,
                                );
                              } else {
                                showToastMessage("Unable to find order ID to update.");
                              }
                            },
                            child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalDateField(TextEditingController ctrl, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Order Date *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
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
              ctrl.text = DateFormat('dd-MM-yyyy').format(picked);
              setModalState(() {});
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ctrl.text, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModalLockedField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Confirm Delete Dialog (Screenshot 5) ──
  void _showConfirmDeleteDialog(BricksList item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Confirm Delete",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, size: 18, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Are you sure you want to delete this order?",
                style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B50A0), // Indigo from Screenshot 5
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444), // Red from Screenshot 5
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (item.id != null) {
                        controller.deleteMaterial(item.id!);
                      }
                    },
                    child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePreviewDialog(String imageUrl, {File? localFile}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (localFile != null)
                Image.file(
                  localFile,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                )
              else
                Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatCapitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String _numberToWordsIndian(int number) {
    if (number == 0) return "Zero Rupees Only";
    final units = [
      "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
      "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
      "Seventeen", "Eighteen", "Nineteen"
    ];
    final tens = [
      "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
    ];

    String convertUnderThousand(int n) {
      String str = "";
      if (n >= 100) {
        str += "${units[n ~/ 100]} Hundred ";
        n %= 100;
      }
      if (n >= 20) {
        str += "${tens[n ~/ 10]} ";
        n %= 10;
      }
      if (n > 0) {
        str += "${units[n]} ";
      }
      return str.trim();
    }

    int n = number;
    String res = "";
    if (n >= 10000000) {
      res += "${convertUnderThousand(n ~/ 10000000)} Crore ";
      n %= 10000000;
    }
    if (n >= 100000) {
      res += "${convertUnderThousand(n ~/ 100000)} Lakh ";
      n %= 100000;
    }
    if (n >= 1000) {
      res += "${convertUnderThousand(n ~/ 1000)} Thousand ";
      n %= 1000;
    }
    if (n > 0) {
      res += convertUnderThousand(n);
    }
    return "${res.trim()} Rupees Only";
  }
}
