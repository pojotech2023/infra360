class VendorDashboardModel {
  int? responseCode;
  List<VendorData>? data;
  bool? status;
  String? message;

  VendorDashboardModel(
      {this.responseCode, this.data, this.status, this.message});

  VendorDashboardModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'] != null
        ? int.tryParse(json['response code'].toString())
        : null;
    if (json['data'] != null && json['data'] is List) {
      data = <VendorData>[];
      json['data'].forEach((v) {
        if (v is Map<String, dynamic>) {
          data!.add(VendorData.fromJson(v));
        } else if (v is Map) {
          data!.add(VendorData.fromJson(Map<String, dynamic>.from(v)));
        }
      });
    }
    status = json['status'] == true || json['status'] == 1 || json['status']?.toString() == 'true';
    message = json['message']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response code'] = this.responseCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class VendorData {
  String? vendorName;
  int? vendorId;
  dynamic totalAmount;
  String? paidAmount;
  String? pendingAmount;

  VendorData(
      {this.vendorName,
        this.vendorId,
        this.totalAmount,
        this.paidAmount,
        this.pendingAmount});

  VendorData.fromJson(Map<String, dynamic> json) {
    vendorName = json['vendor_name']?.toString();
    vendorId = json['vendor_id'] != null
        ? int.tryParse(json['vendor_id'].toString())
        : null;
    totalAmount = json['total_amount'];
    paidAmount = json['paid_amount']?.toString();
    pendingAmount = json['pending_amount']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vendor_name'] = this.vendorName;
    data['vendor_id'] = this.vendorId;
    data['total_amount'] = this.totalAmount;
    data['paid_amount'] = this.paidAmount;
    data['pending_amount'] = this.pendingAmount;
    return data;
  }
}