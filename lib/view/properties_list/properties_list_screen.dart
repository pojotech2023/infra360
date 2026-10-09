import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/model/property_list_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/url_helper.dart';
import 'package:raptor_pro/view/agents/agent_screen.dart';
import 'package:raptor_pro/view/properties_list/add_property/add_property_screen.dart';
import 'package:raptor_pro/view/properties_list/properties_list_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

class PropertiesListScreen extends StatefulWidget {
  const PropertiesListScreen({super.key});

  @override
  State<PropertiesListScreen> createState() => _PropertiesListScreenState();
}

class _PropertiesListScreenState extends State<PropertiesListScreen> {
  late PropertiesController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<PropertiesController>()) {
      controller = Get.find<PropertiesController>();
      controller.init();
    } else {
      controller = Get.put(PropertiesController());
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat("MMM, dd yyyy hh:mm a").format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatCurrency(String? amountStr) {
    if (amountStr == null || amountStr.isEmpty) return "₹ 0.00";
    final clean = amountStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final val = double.tryParse(clean) ?? 0.0;
    try {
      final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2);
      return formatter.format(val);
    } catch (_) {
      return "₹ ${val.toStringAsFixed(2)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: CommonAppBar.appBar(
        title: "Property List",
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CommonLoader());
          }

          return RefreshIndicator(
            onRefresh: () => controller.init(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Breadcrumb Navigation ────────────────────────────────
                  Row(
                    children: [
                      const Icon(Icons.home_outlined, size: 16, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 16, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text("Property", style: AppTextStyle.textRegularSmall.copyWith(color: const Color(0xFF6B7280))),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 16, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(
                        "Property List",
                        style: AppTextStyle.textRegularSmall.copyWith(
                          color: const Color(0xFF1E60D0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Title & Top Action Buttons ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Property",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // View Agents Button
                          ElevatedButton.icon(
                            onPressed: () {
                              Get.to(() => AgentManagementScreen());
                            },
                            icon: const Icon(Icons.group, size: 14, color: Colors.white),
                            label: const Text(
                              "View Agents",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E60D0),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Add Property Button
                          ElevatedButton.icon(
                            onPressed: () {
                              Get.to(() => const AddPropertyScreen());
                            },
                            icon: const Icon(Icons.add, size: 14, color: Colors.white),
                            label: const Text(
                              "Add Property",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E60D0),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Properties Cards List ────────────────────────────────
                  if (controller.propertiesList.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "No properties found",
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.propertiesList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final property = controller.propertiesList[index];
                        return _buildPropertyCard(context, property);
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Screenshot 1: Property Card ────────────────────────────────────────────
  Widget _buildPropertyCard(BuildContext context, PropertyListData property) {
    final imageUrl = (property.imageUrl != null && property.imageUrl!.isNotEmpty)
        ? property.imageUrl!
        : UrlHelper.getFullImageUrl(property.image);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header: ID, Badge, Date, and Action Icons ────────────────
/*
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Property ID
                    Text(
                      "Property ID: #${property.id ?? ''}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Type Badge (Plot / Land)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        property.type ?? "Plot",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // View Details Icon (Eye)
                    InkWell(
                      onTap: () => _showPropertyDetailDialog(context, property),
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.visibility_outlined, size: 20, color: Color(0xFF0284C7)),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Edit Icon
                    InkWell(
                      onTap: () {
                        Get.to(() => AddPropertyScreen(property: property));
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.edit_outlined, size: 20, color: Color(0xFF1E60D0)),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Delete Icon
                    InkWell(
                      onTap: () => _showConfirmDeleteDialog(context, property),
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Created Date Row
                Text(
                  _formatDate(property.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
*/

          // ── Centered Image ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CommonLoader());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 6),
                        Text(
                          "Property Image",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Bottom 2-Column Info Section ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoItem("Property Name", property.name ?? "-"),
                const SizedBox(height: 10),
                _infoItem("Property Location", property.location ?? "-"),
                const SizedBox(height: 10),
                _infoItem(
                  "Property Amount",
                  _formatCurrency(property.amount),
                  isAmount: true,
                ),
/*
                // Row 1: Name (left) & Type (right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _infoItem("Property Name", property.name ?? "-"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: _infoItem("Property Type", property.type ?? "-"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Row 2: Location (left) & Remarks (right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _infoItem("Property Location", property.location ?? "-"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: _infoItem("Remarks", property.remarks ?? "-"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Row 3: Amount (left)
                Row(
                  children: [
                    Expanded(
                      child: _infoItem(
                        "Property Amount",
                        _formatCurrency(property.amount),
                        isAmount: true,
                      ),
                    ),
                  ],
                ),
*/
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Row Helper ────────────────────────────────────────────────────────
  Widget _infoItem(String label, String value, {bool isAmount = false}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
        children: [
          TextSpan(
            text: "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: isAmount ? FontWeight.w700 : FontWeight.w400,
              color: isAmount ? const Color(0xFF1E60D0) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  // ── Property Detail Dialog (Matching Screenshot 1) ────────────────────────
  void _showPropertyDetailDialog(BuildContext context, PropertyListData property) {
    final imageUrl = (property.imageUrl != null && property.imageUrl!.isNotEmpty)
        ? property.imageUrl!
        : UrlHelper.getFullImageUrl(property.image);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: Title + Close 'X' ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Property Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(dialogContext),
                        child: const Icon(Icons.close, size: 20, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Image Preview & "View Full Image" Button ──────────────
                  Center(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            height: 180,
                            color: const Color(0xFFF1F5F9),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // View Full Image Button with Zoom
                        OutlinedButton.icon(
                          onPressed: () {
                            _showZoomableImage(context, imageUrl);
                          },
                          icon: const Icon(Icons.search, size: 16, color: Color(0xFF1E60D0)),
                          label: const Text(
                            "View Full Image",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E60D0),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF93C5FD)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Property Name & Type Badge ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.name ?? "-",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          property.type ?? "Plot",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Amount (Bold Green matching Screenshot 1)
                  const Text(
                    "Amount:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(property.amount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF16A34A), // Vibrant Green
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Location
                  const Text(
                    "Location:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.location ?? "-",
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),

                  // Remarks
                  const Text(
                    "Remarks:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.remarks ?? "-",
                    style: const TextStyle(fontSize: 14, color: Color(0xFF2563EB), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),

                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 10),

                  // Created On
                  const Text(
                    "Created On:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(property.createdAt),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                  ),
                  const SizedBox(height: 20),

                  // ── Bottom Action Buttons: Edit Property + Close ──────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Get.to(() => AddPropertyScreen(property: property));
                        },
                        icon: const Icon(Icons.edit_note, size: 18, color: Colors.white),
                        label: const Text(
                          "Edit Property",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E60D0),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1), // Indigo
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text(
                          "Close",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Full-Screen Zoomable Image Viewer (Pinch to Zoom, Pan) ─────────────────
  void _showZoomableImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (zoomContext) {
        return Dialog(
          backgroundColor: Colors.black87,
          insetPadding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 5.0,
                  boundaryMargin: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (c, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CommonLoader());
                      },
                      errorBuilder: (c, e, s) => Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Unable to load full image"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 18,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(zoomContext).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Confirm Delete Dialog (Matching Screenshot 5) ──────────────────────────
  void _showConfirmDeleteDialog(BuildContext context, PropertyListData property) {
    final propertyName = property.name ?? "this property";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Confirm Delete + Close 'X'
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Confirm Delete",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(dialogContext),
                      child: const Icon(Icons.close, size: 20, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Question Body with property name matching Screenshot 5
                Text(
                  "Are you sure you want to delete $propertyName?",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons (Yes, Delete / Cancel)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(() {
                      return ElevatedButton(
                        onPressed: controller.isDeleteLoading.value
                            ? null
                            : () async {
                                final success = await controller.deleteProperty(property.id!);
                                if (success) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isDeleteLoading.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                "Yes, Delete",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                      );
                    }),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E60D0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
