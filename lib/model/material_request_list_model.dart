class MaterialRequestListModel {
  bool? status;
  String? message;
  List<MaterialRequestItem>? data;

  MaterialRequestListModel({this.status, this.message, this.data});

  factory MaterialRequestListModel.fromJson(Map<String, dynamic> json) {
    return MaterialRequestListModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => MaterialRequestItem.fromJson(e))
              .toList()
          : [],
    );
  }
}

class MaterialRequestItem {
  int? id;
  int? siteId;
  int? supervisorId;
  String? materialItem;
  String? quantity;
  String? unit;
  String? neededBy;
  String? vendorName;
  String? remarks;
  String? status; // pending, approved, rejected
  String? actionRemarks;
  String? adminRemark;
  String? reviewedAt;
  String? createdAt;
  String? updatedAt;

  MaterialRequestItem({
    this.id,
    this.siteId,
    this.supervisorId,
    this.materialItem,
    this.quantity,
    this.unit,
    this.neededBy,
    this.vendorName,
    this.remarks,
    this.status,
    this.actionRemarks,
    this.adminRemark,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory MaterialRequestItem.fromJson(Map<String, dynamic> json) {
    return MaterialRequestItem(
      id: json['id'],
      siteId: json['site_id'],
      supervisorId: json['supervisor_id'],
      materialItem: (json['material_item'] ?? json['material_type'] ?? json['item_name'])?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      neededBy: (json['needed_by'] ?? json['date_of_delivery'] ?? json['date'])?.toString() ?? '',
      vendorName: json['vendor_name']?.toString() ?? 
                  (json['vendor'] is Map ? json['vendor']['name']?.toString() ?? '' : json['vendor']?.toString() ?? ''),
      remarks: json['remarks']?.toString() ?? '',
      status: _parseStatus(json['status']),
      actionRemarks: json['action_remarks']?.toString() ?? '',
      adminRemark: json['admin_remark']?.toString() ?? '',
      reviewedAt: json['reviewed_at']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  static String _parseStatus(dynamic status) {
    if (status == null) return 'pending';
    if (status is int) {
      if (status == 1) return 'approved';
      if (status == 2) return 'rejected';
      return 'pending';
    }
    return status.toString().toLowerCase();
  }
}
