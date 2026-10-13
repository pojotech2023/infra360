import 'dart:convert';
import 'package:raptor_pro/model/login_response.dart';
import 'package:raptor_pro/service/shared_preference_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/material_request_list_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/view/material_category/material_request/material_request_list_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/utils/res/sendWhatsAppMessage.dart';

class MaterialRequestListScreen extends StatefulWidget {
  const MaterialRequestListScreen({super.key});

  @override
  State<MaterialRequestListScreen> createState() => _MaterialRequestListScreenState();
}

class _MaterialRequestListScreenState extends State<MaterialRequestListScreen> {
  late int siteId;
  late String siteName;
  late MaterialRequestListController controller;
  String _role = '';

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    siteId = args?['siteId'] ?? 0;
    siteName = args?['siteName'] ?? 'Unknown';

    controller = Get.put(
      MaterialRequestListController(siteId: siteId, siteName: siteName),
      tag: 'req_$siteId',
    );
    
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    try {
      final data = jsonDecode(PreferenceUtils().getUserInfo());
      final userDetails = LoginResponse.fromJson(data);
      _role = userDetails.data?.role?.toLowerCase() ?? '';
      print("👤 [MaterialRequestListScreen] role=$_role");
      setState(() {});
    } catch (e) {
      print("❌ [MaterialRequestListScreen] Could not read role: $e");
    }
  }

  bool get _isAdmin => _role == 'admin';

  void _sendToWhatsApp(MaterialRequestItem item) {
    try {
      final data = jsonDecode(PreferenceUtils().getUserInfo());
      final userDetails = LoginResponse.fromJson(data);
      final supervisorName = userDetails.data?.user?.name ?? 'Unknown Supervisor';
      final supervisorMob = userDetails.data?.user?.mobileNo ?? 'Unknown Mobile';

      String message = """
*Pojo infra 360*
Site Name: $siteName - Material Request
Location: N/A
Material Type: ${item.materialItem}
Unit : ${item.unit}
Delivery Date: ${_formatDate(item.neededBy)}
Quantity: ${item.quantity}
Supervisor: $supervisorName ($supervisorMob)
Remarks: ${item.remarks ?? 'N/A'}
""";

      String rawPhone = (item.vendorMobile != null && item.vendorMobile!.isNotEmpty) 
          ? item.vendorMobile! 
          : "7540060694"; // Fallback only if vendor has no mobile number
          
      rawPhone = rawPhone.trim().replaceAll(RegExp(r'[ \-\(\)]'), '');
      if (rawPhone.length == 10 && !rawPhone.startsWith('+')) {
        rawPhone = '+91$rawPhone';
      }
      
      String whatsappUrl = "https://wa.me/$rawPhone?text=${Uri.encodeComponent(message)}";
      extractAndOpenWhatsApp(whatsappUrl);
    } catch (e) {
      print("❌ Error generating WhatsApp message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CommonAppBar.appBar(
        title: "Material Requests",
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "No material requests found",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Material Requests",
                      style: AppTextStyle.textMedium.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF252C58),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "All Requests — $siteName",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Table
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.fetchRequests,
                  child: Obx(() {
                    if (controller.requests.isEmpty) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text("No material requests found."),
                      ));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.requests.length,
                      itemBuilder: (context, index) {
                        return _buildCard(
                          context,
                          controller.requests[index],
                          index + 1,
                          controller,
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          _headerCell('S.NO', flex: 1),
          _headerCell('MATERIAL / ITEM', flex: 3),
          _headerCell('QUANTITY', flex: 2),
          _headerCell('UNIT', flex: 2),
          _headerCell('NEEDED BY', flex: 2),
          _headerCell('VENDOR', flex: 2),
          _headerCell('REMARKS', flex: 3),
          _headerCell('STATUS', flex: 2),
          const SizedBox(width: 16), // shift ACTION column right
          _headerCell('ACTION', flex: 4, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    MaterialRequestItem item,
    int index,
    MaterialRequestListController controller,
  ) {
    final bool isPending = (item.status ?? '').toLowerCase() == 'pending';
    final bool isApproved = (item.status ?? '').toLowerCase() == 'approved';
    final bool isRejected = (item.status ?? '').toLowerCase() == 'rejected';
    final bool isOdd = index % 2 == 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isOdd ? Colors.white : const Color(0xFFFAFAFF),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _dataCell(index.toString(), flex: 1, bold: true),
          _dataCell(item.materialItem ?? '', flex: 3),
          _dataCell(item.quantity ?? '', flex: 2),
          _dataCell(item.unit ?? '', flex: 2),
          _dataCell(_formatDate(item.neededBy), flex: 2),
          _dataCell(item.vendorName ?? '', flex: 2),
          
          // REMARKS column (with rejection reason)
          SizedBox(
            width: 135.0, // flex 3 * 45
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Builder(
                builder: (context) {
                  final hasRejectionReason = isRejected && item.adminRemark != null && item.adminRemark!.trim().isNotEmpty;
                  final hasActualRemarks = item.remarks != null && item.remarks!.trim().isNotEmpty && item.remarks!.trim().toUpperCase() != 'N/A';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!hasRejectionReason || hasActualRemarks)
                        Text(
                          item.remarks?.isNotEmpty == true ? item.remarks! : 'N/A',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (hasRejectionReason)
                        Padding(
                          padding: EdgeInsets.only(top: hasActualRemarks ? 4 : 0),
                          child: Text(
                            "Rejection reason: ${item.adminRemark}",
                            style: const TextStyle(fontSize: 11, color: Colors.redAccent),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          // STATUS badge
          SizedBox(
            width: 90.0, // flex 2 * 45
            child: Center(
              child: _buildStatusBadge(item.status ?? 'pending'),
            ),
          ),

          const SizedBox(width: 16), // shift ACTION column right

          // ACTION column
          SizedBox(
            width: 180.0, // flex 4 * 45
            child: isApproved || isRejected
                ? Center(
                    child: Text(
                      _timeAgo(item.reviewedAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  )
                : isPending
                    ? Obx(() => controller.isActioning.value
                        ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _actionButton(
                                label: "Approve",
                                icon: Icons.check,
                                color: Colors.green,
                                onTap: () => _confirmAction(
                                  context,
                                  title: "Approve Request",
                                  message: "Are you sure you want to approve this material request?",
                                  confirmLabel: "Approve",
                                  confirmColor: Colors.green,
                                  onConfirm: () => controller.approveRequest(item.id!),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _actionButton(
                                label: "Reject",
                                icon: Icons.close,
                                color: Colors.red,
                                onTap: () => _showRejectDialog(
                                  context,
                                  onConfirm: (String? remark) =>
                                      controller.rejectRequest(item.id!, adminRemark: remark),
                                ),
                              ),
                            ],
                          ))
                    : Text(
                        "—",
                        style: TextStyle(color: Colors.grey[400]),
                        textAlign: TextAlign.center,
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
    } catch (_) {
      return dateStr;
    }
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Reviewed';
    try {
      final DateTime date = DateTime.parse(dateStr).toLocal();
      final Duration diff = DateTime.now().difference(date);

      if (diff.inDays > 365) {
        return "Reviewed ${diff.inDays ~/ 365} years ago";
      } else if (diff.inDays >= 30) {
        return "Reviewed ${diff.inDays ~/ 30} months ago";
      } else if (diff.inDays > 0) {
        return "Reviewed ${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago";
      } else if (diff.inHours > 0) {
        return "Reviewed ${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago";
      } else if (diff.inMinutes > 0) {
        return "Reviewed ${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'} ago";
      } else {
        return "Reviewed ${diff.inSeconds < 0 ? 0 : diff.inSeconds} ${diff.inSeconds == 1 ? 'second' : 'seconds'} ago";
      }
    } catch (_) {
      return 'Reviewed';
    }
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String label;
    switch (status.toLowerCase()) {
      case 'approved':
        badgeColor = Colors.green;
        label = 'Approved';
        break;
      case 'rejected':
        badgeColor = Colors.red;
        label = 'Rejected';
        break;
      default:
        badgeColor = Colors.orange;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required dynamic icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon is IconData)
              Icon(icon, color: Colors.white, size: 12)
            else if (icon is String)
              Image.asset(icon, height: 12, width: 12),
            const SizedBox(width: 3),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// Simple confirm dialog (used for Approve)
  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: AppColor.buttonBlue, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  /// Reject dialog with optional admin_remark text field
  void _showRejectDialog(
    BuildContext context, {
    required void Function(String? adminRemark) onConfirm,
  }) {
    final TextEditingController remarkCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reject Request"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you sure you want to reject this material request?",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            const Text(
              "Remark (optional)",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: remarkCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Reason for rejection…",
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColor.buttonBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final String? remark = remarkCtrl.text.trim().isEmpty
                  ? null
                  : remarkCtrl.text.trim();
              Navigator.pop(ctx);
              onConfirm(remark);
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }


  Widget _headerCell(String title, {required int flex, TextAlign textAlign = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        textAlign: textAlign,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
      ),
    );
  }

  Widget _dataCell(String text, {required int flex, bool bold = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    MaterialRequestItem item,
    int index,
    MaterialRequestListController controller,
  ) {
    final bool isPending = (item.status ?? '').toLowerCase() == 'pending';
    final bool isApproved = (item.status ?? '').toLowerCase() == 'approved';
    final bool isRejected = (item.status ?? '').toLowerCase() == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'S.No: ',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF252C58), fontSize: 14),
              ),
              _buildStatusBadge(item.status ?? 'pending'),
            ],
          ),
          const SizedBox(height: 12),
          _buildCardRow('Material / Item', item.materialItem ?? ''),
          const SizedBox(height: 8),
          _buildCardRow('Quantity', item.quantity ?? ''),
          const SizedBox(height: 8),
          _buildCardRow('Unit', item.unit ?? ''),
          const SizedBox(height: 8),
          _buildCardRow('Needed By', _formatDate(item.neededBy)),
          const SizedBox(height: 8),
          _buildCardRow('Vendor', (item.vendorName?.isNotEmpty == true) ? item.vendorName! : 'N/A'),
          const SizedBox(height: 8),
          
          Builder(
            builder: (context) {
              final hasRejectionReason = isRejected && item.adminRemark != null && item.adminRemark!.trim().isNotEmpty;
              final hasActualRemarks = item.remarks != null && item.remarks!.trim().isNotEmpty && item.remarks!.trim().toUpperCase() != 'N/A';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasRejectionReason || hasActualRemarks) ...[
                    const Text('Remarks', style: TextStyle(color: Color(0xFF6E6B7B), fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(item.remarks?.isNotEmpty == true ? item.remarks! : 'N/A', style: const TextStyle(color: Color(0xFF252C58), fontSize: 14)),
                  ],
                  if (hasRejectionReason)
                    Padding(
                      padding: EdgeInsets.only(top: hasActualRemarks ? 8 : 0),
                      child: Text("Rejection reason: ${item.adminRemark}", style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          if (isApproved || isRejected)
            if (_isAdmin)
              Align(
                alignment: Alignment.centerRight,
                child: Text(_timeAgo(item.reviewedAt), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              )
            else
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Text(_timeAgo(item.reviewedAt), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    _actionButton(
                      label: "Send to WhatsApp",
                      icon: 'assets/images/whatsapp.png',
                      color: isApproved ? Colors.green : Colors.grey,
                    onTap: () {
                      if (isApproved) {
                        _sendToWhatsApp(item);
                      }
                    },
                  ),
                ],
              )
          else if (isPending)
            _isAdmin
                ? Obx(() => controller.isActioning.value
                    ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                    : Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _actionButton(
                            label: "Approve",
                            icon: Icons.check,
                            color: Colors.green,
                            onTap: () => _confirmAction(
                              context,
                              title: "Approve Request",
                              message: "Are you sure you want to approve this material request?",
                              confirmLabel: "Approve",
                              confirmColor: Colors.green,
                              onConfirm: () => controller.approveRequest(item.id!),
                            ),
                          ),
                          _actionButton(
                            label: "Reject",
                            icon: Icons.close,
                            color: Colors.red,
                            onTap: () => _showRejectDialog(
                              context,
                              onConfirm: (String? remark) =>
                                  controller.rejectRequest(item.id!, adminRemark: remark),
                            ),
                          ),
                        ],
                      ))
                : Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const Text("Pending Review", style: TextStyle(color: Colors.grey)),
                      _actionButton(
                        label: "Send to WhatsApp",
                        icon: 'assets/images/whatsapp.png',
                        color: Colors.grey,
                        onTap: () {},
                      ),
                    ],
                  )
          else
             const Align(
                alignment: Alignment.centerRight,
                child: Text("-", style: TextStyle(color: Colors.grey)),
              ),
        ],
      ),
    );
  }

  Widget _buildCardRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6E6B7B), fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF252C58), fontSize: 14)),
      ],
    );
  }
}