class VendorDashboardModel {
  int? responseCode;
  List<VendorData>? data;
  bool? status;
  String? message;

  VendorDashboardModel(
      {this.responseCode, this.data, this.status, this.message});

  VendorDashboardModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    if (json['data'] != null) {
      data = <VendorData>[];
      json['data'].forEach((v) {
        data!.add( VendorData.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
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
  int? totalAmount;
  String? paidAmount;
  String? pendingAmount;

  VendorData(
      {this.vendorName,
        this.vendorId,
        this.totalAmount,
        this.paidAmount,
        this.pendingAmount});

  VendorData.fromJson(Map<String, dynamic> json) {
    vendorName = json['vendor_name'];
    vendorId = json['vendor_id'];
    totalAmount = json['total_amount'];
    paidAmount = json['paid_amount'];
    pendingAmount = json['pending_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['vendor_name'] = this.vendorName;
    data['vendor_id'] = this.vendorId;
    data['total_amount'] = this.totalAmount;
    data['paid_amount'] = this.paidAmount;
    data['pending_amount'] = this.pendingAmount;
    return data;
  }
}