import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/model/bricks_model.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/utils/file_picker_helper.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/sendWhatsAppMessage.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/custom_date_picker.dart';
import 'package:raptor_pro/view/widgets/toast.dart';
import 'all_materials/all_materials_orders_screen.dart';
import 'all_materials/all_materials_screen.dart';
import 'bricks_details_controller.dart';
import 'new_bricks/new_request_screen.dart';

class BricksDetailsScreen extends StatefulWidget {
  const BricksDetailsScreen({super.key});

  @override
  State<BricksDetailsScreen> createState() => _BricksDetailsScreenState();
}

class _BricksDetailsScreenState extends State<BricksDetailsScreen> {
  final MaterialDetailsArgs args = Get.arguments as MaterialDetailsArgs;
  late final BricksDetailsController controller;

  bool get isAllOverview =>
      args.itemKey.toLowerCase() == 'all' ||
      args.itemKey.toLowerCase() == 'all materials';

  @override
  void initState() {
    super.initState();
    controller = Get.put(BricksDetailsController(materialDetailsArgs: args));
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
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
    if (isAllOverview) {
      return AllMaterialsOrdersScreen(args: args);
    }

    final itemTitle = _capitalize(args.itemKey);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar.appBar(
        title: "$itemTitle Details",
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Breadcrumb Header (Screenshot 1) ──
              _buildBreadcrumbHeader(),
              const SizedBox(height: 12),

              // ── Site Info & Month Filter Card (Screenshot 1) ──
              _buildFilterCard(),
              const SizedBox(height: 16),

              // ── Overview Header with Action Buttons (Screenshot 1 & 2) ──
              _buildOverviewHeader(itemTitle),
              const SizedBox(height: 14),

              // ── List of Orders (Card View matching Screenshot 1 & 2) ──
              _buildOrdersList(itemTitle),
              const SizedBox(height: 16),

              // ── Total Summary Box (Screenshot 1 & 2 bottom) ──
              _buildTotalSummaryBox(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Breadcrumb Header ──
  Widget _buildBreadcrumbHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
              "Site  >  ${args.siteName}  >  ${_capitalize(args.itemKey)} Details",
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

  // ── Site Info & Filter Card (Screenshot 1) ──
  Widget _buildFilterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Site Name
          Row(
            children: [
              const Text(
                "Site Name: ",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Expanded(
                child: Text(
                  args.siteName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColor.buttonBlue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Month Picker Box (Screenshot 1: "October, 2026" with calendar icon)
          Obx(() {
            final monthText = controller.selectedMonthText.value.isNotEmpty
                ? DateFormat('MMMM, yyyy').format(
                    DateTime(controller.selectedYear.value, controller.selectedMonth.value),
                  )
                : "Select Month";

            return Row(
              children: [
                InkWell(
                  onTap: _pickMonth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          monthText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 14),

          // Filter Pills: Full Month, Week 1, Week 2, Week 3, Week 4 (Screenshot 1)
          Obx(() {
            final isFullMonth = controller.selectedWeek.value == null;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Full Month Pill
                  InkWell(
                    onTap: () {
                      controller.selectedWeek.value = null;
                      controller.fetchData();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isFullMonth
                            ? const Color(0xFF16A34A) // Green (Screenshot 1)
                            : const Color(0xFF0F172A), // Dark slate
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Full Month",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Week 1 to 4 Pills
                  ...List.generate(4, (index) {
                    final weekNum = index + 1;
                    final isSelected = controller.selectedWeek.value == weekNum;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => controller.onWeekSelected(weekNum),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColor.buttonBlue
                                : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "Week $weekNum",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Overview Header with Buttons (Screenshot 1) ──
  Widget _buildOverviewHeader(String itemTitle) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            Text(
              "$itemTitle Overview",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAllOverview) ...[
                  // Request Button (Blue)
                  ElevatedButton(
                    onPressed: () async {
                      await Get.to(() => const NewRequestScreen(type: 1), arguments: args);
                      controller.fetchData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: const Text(
                      'Request',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                // Inward Order Button (Blue, Screenshot 1)
                ElevatedButton(
                  onPressed: () async {
                    if (isAllOverview) {
                      await Get.to(() => const AllMaterialsManagementScreen(), arguments: args);
                    } else {
                      await Get.to(() => const NewRequestScreen(type: 2), arguments: args);
                    }
                    controller.fetchData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  child: const Text(
                    'Inward Order',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),

                // Export Button (Green, Screenshot 1)
                ElevatedButton(
                  onPressed: () => _showExportDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  child: const Text(
                    'Export',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  // ── Orders List ──
  Widget _buildOrdersList(String itemTitle) {
    return Obx(() {
      final list = controller.getBricksLists;
      if (list.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 42, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(
                "No $itemTitle records found for this period.",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return _buildOrderCard(item, index + 1);
        },
      );
    });
  }
 // ── Order Card (Card View matching Screenshot 1 & 2) ──
  Widget _buildOrderCard(BricksList item, int index) {
    String dateFormatted = item.date ?? '-';
    try {
      if (item.date != null && item.date!.isNotEmpty) {
        final dt = DateTime.parse(item.date!);
        dateFormatted = DateFormat('dd-MM-yyyy').format(dt);
      }
    } catch (_) {}

    final materialType = _capitalize(item.materialType ?? args.itemKey);
    final category = item.category ?? item.materialType ?? 'Standard';
    String spec = (item.specification != null && item.specification!.trim().isNotEmpty && item.specification != '-')
        ? item.specification!.trim()
        : '';
    if (spec.isEmpty && item.rawItems != null) {
      try {
        dynamic parsed = item.rawItems;
        if (parsed is String && parsed.trim().isNotEmpty) {
          try {
            parsed = jsonDecode(parsed);
          } catch (_) {}
        }
        if (parsed is List && parsed.isNotEmpty) {
          for (var itm in parsed) {
            if (itm is Map) {
              final s = itm['specification'] ?? itm['spec'] ?? itm['size'] ?? itm['size_specification'] ?? itm['description'] ?? itm['sub_type'];
              if (s != null && s.toString().trim().isNotEmpty) {
                spec = s.toString().trim();
                break;
              }
            }
          }
        }
      } catch (_) {}
    }
    if (spec.isEmpty) {
      for (var cand in [item.category, item.materialType]) {
        if (cand != null && cand.contains('(') && cand.contains(')')) {
          final reg = RegExp(r'\((.*?)\)');
          final match = reg.firstMatch(cand);
          if (match != null && match.group(1) != null && match.group(1)!.trim().isNotEmpty) {
            spec = match.group(1)!.trim();
            break;
          }
        }
      }
    }
    final quantityStr = "${item.quantity ?? '0'} ${item.unit ?? 'Nos'}";
    final pricePerItemStr = item.pricePerItem != null
        ? "₹ ${NumberFormat('#,##0.00').format(item.pricePerItem)}"
        : "₹ 1,000.00";
    final priceStr = item.price != null
        ? "₹ ${NumberFormat('#,##0.00').format(item.price)}"
        : "₹ 2,000.00";
    final gstStr = (item.gst != null && item.gst!.isNotEmpty && item.gst != '0') ? "${item.gst}%" : "-";
    final totalAmountStr = item.totalAmount != null
        ? "₹ ${NumberFormat('#,##0.00').format(item.totalAmount)}"
        : priceStr;
    final vendor = item.vendorName?.isNotEmpty == true ? item.vendorName! : 'Sai bricks';
    final vendorGstin = item.vendorGstin?.isNotEmpty == true ? item.vendorGstin! : '454548154518';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
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
          // Row 1: S.NO + Date + Actions (WhatsApp, Edit, Delete, PDF)
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
              // Action Icons: WhatsApp, Edit, Delete, PDF (Screenshot 2)
              Row(
                children: [
                  // WhatsApp
                  InkWell(
                    onTap: () {
                      String phone = item.vendorMobile?.toString().trim() ?? "7540060694";
                      phone = phone.replaceAll(RegExp(r'[ \-\(\)]'), '');
                      if (phone.length == 10 && !phone.startsWith('+')) {
                        phone = '+91$phone';
                      }
                      String message = '''
*Pojo infra 360*
Site Name: ${args.siteName} - ${_capitalize(args.itemKey)} Order
Location: ${args.siteLocation}
Vendor Name: $vendor
Vendor GSTIN: $vendorGstin
Material Type: $materialType
Category: $category
Specification: $spec
Quantity: $quantityStr
Price / Item: $pricePerItemStr
Total: $totalAmountStr
Date: $dateFormatted
''';
                      String whatsappUrl = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";
                      extractAndOpenWhatsApp(whatsappUrl);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Image.asset('assets/images/whatsapp.png', width: 16, height: 16),
                    ),
                  ),
                  // Concept: Web only shows Edit, Delete, PDF action buttons when showAction is true (e.g. Individual Orders).
                  // Combined / All-Materials orders (ALL-ORD-...) have showAction = false and actions are managed in All Materials.
                  if (item.showAction == true) ...[
                    const SizedBox(width: 6),

                    // Edit Icon (Screenshot 2 & 3)
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

                    // Delete Icon (red X style, Screenshot 2)
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

                    // PDF Icon (red pdf, Screenshot 2)
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
                ],
              ),
            ],
          ),
          const Divider(height: 16),

          // Row 2: Material Type & Category Pill (Screenshot 1: "Bricks" | "Fly Ash Bricks")
          Row(
            children: [
              Text(
                materialType,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          if (spec.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.straighten_outlined, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                const Text(
                  "Size / Specification: ",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
                Expanded(
                  child: Text(
                    spec,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),

          // Metrics Box (Screenshot 1 & 2 columns)
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

          // Row 4: Vendor & Vendor GSTIN (Screenshot 2)
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
              Row(
                children: [
                  const Text("GSTIN: ", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  Text(
                    vendorGstin,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                ],
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
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // ── Total Summary Box (Screenshot 1 & 2 bottom: TOTAL | 4 Units | ₹ 4,000.00) ──
  Widget _buildTotalSummaryBox() {
    return Obx(() {
      final bricks = controller.bricksModel?.value;
      final totalUnits = bricks?.totalUnits ?? 0;
      final totalAmount = bricks?.totalAmount ?? 0;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // TOTAL Row (Screenshot 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColor.totalBGColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  Text(
                    "$totalUnits Units",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  Text(
                    "₹ ${NumberFormat('#,##0.00').format(totalAmount)}",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                ],
              ),
            ),
            // Settled Amount
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Settled Amount", style: TextStyle(fontSize: 13, color: AppColor.buttonGreen, fontWeight: FontWeight.w600)),
                  Text("₹ ${NumberFormat('#,##0.00').format(bricks?.settledAmount ?? 0)}", style: TextStyle(fontSize: 13, color: AppColor.buttonGreen, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Pending Amount
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColor.pendingBGColorr,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Pending Amount", style: TextStyle(fontSize: 13, color: AppColor.red, fontWeight: FontWeight.w600)),
                  Text("₹ ${NumberFormat('#,##0.00').format(bricks?.pendingAmount ?? 0)}", style: TextStyle(fontSize: 13, color: AppColor.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── EDIT ORDER MODAL (Screenshot 3) ──
  // ══════════════════════════════════════════════════════════════════════════
  void _showEditOrderModal(BricksList orderItem) {
    List<Map<String, dynamic>> editableItems = [];

    if (orderItem.rawItems != null) {
      try {
        dynamic parsed = orderItem.rawItems;
        if (parsed is String) parsed = jsonDecode(parsed);
        if (parsed is List) {
          for (var itm in parsed) {
            if (itm is Map) {
              String itemSpec = '';
              final s = itm['specification'] ?? itm['spec'] ?? itm['size'] ?? itm['size_specification'] ?? itm['description'] ?? itm['sub_type'];
              if (s != null && s.toString().trim().isNotEmpty) {
                itemSpec = s.toString().trim();
              } else if (orderItem.specification != null && orderItem.specification!.isNotEmpty) {
                itemSpec = orderItem.specification!;
              } else {
                final nameCand = (itm['name'] ?? itm['item_name'] ?? '').toString();
                final match = RegExp(r'\((.*?)\)').firstMatch(nameCand);
                if (match != null && match.group(1) != null) {
                  itemSpec = match.group(1)!.trim();
                }
              }

              final double parsedGst = double.tryParse((itm['gst'] ?? '0').toString()) ?? 0.0;
              final double parsedPrice = double.tryParse((itm['price'] ?? itm['rate'] ?? '1000').toString()) ?? 1000.0;
              final String parsedQty = (itm['quantity'] ?? itm['qty'] ?? '1').toString();

              editableItems.add({
                if (itm['id'] != null) "id": itm['id'],
                "material": itm['material'] ?? itm['category'] ?? orderItem.materialType ?? args.itemKey,
                "name": itm['name'] ?? itm['item_name'] ?? orderItem.category ?? 'Item',
                "specCtrl": TextEditingController(text: itemSpec),
                "qty": TextEditingController(text: parsedQty),
                "unit": itm['unit'] ?? orderItem.unit ?? 'Nos',
                "price": TextEditingController(text: parsedPrice.toInt().toString()),
                "gst": parsedGst,
              });
            }
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
            final double rate = b.pricePerItem ??
                (b.price != null
                    ? (b.price! / (double.tryParse(b.quantity ?? '1') ?? 1.0))
                    : 1000.0);
            editableItems.add({
              "id": b.id,
              "material": _capitalize(b.materialType ?? args.itemKey),
              "name": b.category ?? b.materialType ?? 'Item',
              "specCtrl": TextEditingController(text: b.specification ?? ''),
              "qty": TextEditingController(text: b.quantity ?? '1'),
              "unit": b.unit ?? 'Nos',
              "price": TextEditingController(text: rate.toInt().toString()),
              "gst": double.tryParse((b.gst ?? '0').toString()) ?? 0.0,
            });
          }
        }
      }
    }

    if (editableItems.isEmpty) {
      editableItems.add({
        "id": orderItem.id,
        "material": _capitalize(orderItem.materialType ?? args.itemKey),
        "name": orderItem.category ?? orderItem.materialType ?? 'Item',
        "specCtrl": TextEditingController(text: orderItem.specification ?? ''),
        "qty": TextEditingController(text: orderItem.quantity ?? '1'),
        "unit": orderItem.unit ?? 'Nos',
        "price": TextEditingController(text: (orderItem.pricePerItem ?? 1000).toInt().toString()),
        "gst": double.tryParse((orderItem.gst ?? '0').toString()) ?? 0.0,
      });
    }

    final dateCtrl = TextEditingController(
      text: orderItem.date ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
    );
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
                    // Header (Screenshot 3: Edit Order [Badge] + X)
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
                          const Spacer(),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order Date, Vendor Name, Vendor GSTIN (Screenshot 3)
                            _buildModalDateField(dateCtrl, setModalState),
                            const SizedBox(height: 12),
                            _buildModalLockedField("Vendor Name", orderItem.vendorName ?? 'Sai bricks'),
                            const SizedBox(height: 12),
                            _buildModalLockedField("Vendor GSTIN", orderItem.vendorGstin ?? '454548154518'),
                            const SizedBox(height: 20),

                            // Order Items Section (Screenshot 3)
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

                            // Order Items Table (Screenshot 3)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                                  dataRowMaxHeight: 68,
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
                                    DataColumn(label: Text("SPECIFICATION")),
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
                                    final specCtrl = item['specCtrl'] as TextEditingController;
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
                                              const SizedBox(height: 2),
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
                                            width: 140,
                                            child: TextField(
                                              controller: specCtrl,
                                              style: const TextStyle(fontSize: 12),
                                              decoration: InputDecoration(
                                                hintText: "Enter spec",
                                                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                                isDense: true,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                              onChanged: (_) => setModalState(() {}),
                                            ),
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

                            // Subtotal & Total Row (Screenshot 3)
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

                            // Amount in words (Screenshot 3: Green Text)
                            Text(
                              "₹ $amountWords",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Invoice Attachment Section (Screenshot 3)
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
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                  ),
                                  const SizedBox(height: 10),

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
                                            style: TextStyle(fontSize: 13, color: Color(0xFF475569), decoration: TextDecoration.underline, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],

                                  // Choose File
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

                    // Modal Actions
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
                              List<String> summaryParts = [];
                              double totalOrderQty = 0.0;
                              for (var item in editableItems) {
                                final q = (item['qty'] as TextEditingController).text.trim();
                                final p = (item['price'] as TextEditingController).text.trim();
                                final specText = (item['specCtrl'] as TextEditingController).text.trim();
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
                                  "specification": specText,
                                  "spec": specText,
                                  "size": specText,
                                  "size_specification": specText,
                                  "quantity": q,
                                  "unit": u,
                                  "price": p,
                                  "rate": p,
                                  "gst": g.toString(),
                                  "gst_rate": g,
                                  "gst_amount": lineGst.toStringAsFixed(2),
                                  "total": lineTotal.toStringAsFixed(2),
                                });

                                final display = specText.isNotEmpty ? "$n ($specText)" : n;
                                summaryParts.add("$display [$q $u]");
                              }

                              final firstSpec = editableItems.isNotEmpty
                                  ? (editableItems.first['specCtrl'] as TextEditingController).text.trim()
                                  : '';

                              final Map<String, dynamic> updatePayload = {
                                "material_type": (orderItem.materialType != null && orderItem.materialType!.isNotEmpty)
                                    ? orderItem.materialType!
                                    : args.itemKey,
                                "date": dateCtrl.text.trim(),
                                "specification": firstSpec,
                                "spec": firstSpec,
                                "size": firstSpec,
                                "size_specification": firstSpec,
                                "size_spec": firstSpec,
                                "quantity": totalOrderQty.toString().replaceAll(RegExp(r'\.0$'), ''),
                                "unit": editableItems.isNotEmpty ? editableItems.first['unit'] : "Nos",
                                "price": subtotal.toStringAsFixed(2),
                                "unit_price": editableItems.isNotEmpty
                                    ? (editableItems.first['price'] as TextEditingController).text.trim()
                                    : "1000",
                                "gst": totalGst.toStringAsFixed(2),
                                "amount": grandTotal.toStringAsFixed(2),
                                "site_id": args.id.toString(),
                                "vendor_id": orderItem.vendorId?.toString() ?? '',
                                "items": jsonEncode(itemsPayload),
                                "items_summary": summaryParts.join(", "),
                              };

                              await controller.updateMaterial(
                                orderItem.id ?? 0,
                                updatePayload,
                                attachment: newInvoiceFile,
                              );
                            },
                            child: const Text("Update Order", style: TextStyle(fontWeight: FontWeight.bold)),
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
        const Row(
          children: [
            Text("Order Date", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
            Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            DateTime initial = DateTime.now();
            try {
              if (ctrl.text.isNotEmpty) initial = DateFormat('dd-MM-yyyy').parse(ctrl.text);
            } catch (_) {}
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setModalState(() {
                ctrl.text = DateFormat('dd-MM-yyyy').format(picked);
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ctrl.text, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
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
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  void _showImagePreviewDialog(String imageUrl, {File? localFile}) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.82,
            maxWidth: MediaQuery.of(ctx).size.width * 0.95,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Invoice Preview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                  child: InteractiveViewer(
                    clipBehavior: Clip.hardEdge,
                    child: localFile != null
                        ? Image.file(localFile, fit: BoxFit.contain)
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Padding(
                              padding: EdgeInsets.all(32),
                              child: Text("Could not load image"),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDeleteDialog(BricksList item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text("Confirm Delete", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this ${_capitalize(args.itemKey)} record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              if (item.id != null) controller.deleteMaterial(item.id!);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ── Export Dialog ──
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
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Export ${_capitalize(args.itemKey)} Report",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
                            onPressed: () => Navigator.pop(dialogCtx),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),

                    // Dates Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("From Date", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => pickDate(true, setModalState),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(6),
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
                          const Text("To Date", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => pickDate(false, setModalState),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(6),
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

                    // Actions
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B50A0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  // ── Indian number to words helper (Screenshot 3) ──
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
