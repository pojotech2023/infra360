class VendorPaymentDetailsModel {
  int? responseCode;
  VendorPaymentDetailsData? data;
  bool? status;
  String? message;

  VendorPaymentDetailsModel(
      {this.responseCode, this.data, this.status, this.message});

  VendorPaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    data = json['data'] != null ? new VendorPaymentDetailsData.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response code'] = this.responseCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class VendorPaymentDetailsData {
  int? totalUnits;
  int? totalAmount;
  PayDetail? payDetail;
  Vendor? vendor;

  VendorPaymentDetailsData({this.totalUnits, this.totalAmount, this.payDetail, this.vendor});

  VendorPaymentDetailsData.fromJson(Map<String, dynamic> json) {
    totalUnits = json['total_units'];
    totalAmount = json['total_amount'];
    payDetail = json['pay_detail'] != null
        ? new PayDetail.fromJson(json['pay_detail'])
        : null;
    vendor =
    json['vendor'] != null ? new Vendor.fromJson(json['vendor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_units'] = this.totalUnits;
    data['total_amount'] = this.totalAmount;
    if (this.payDetail != null) {
      data['pay_detail'] = this.payDetail!.toJson();
    }
    if (this.vendor != null) {
      data['vendor'] = this.vendor!.toJson();
    }
    return data;
  }
}

class PayDetail {
  int? id;
  int? vendorId;
  String? openingBalance;
  String? totalUnits;
  String? totalUnitPrice;
  String? balanceAmount;
  String? paidAmount;
  String? createdAt;
  String? updatedAt;
  dynamic createdBy;
  dynamic updatedBy;

  PayDetail(
      {this.id,
        this.vendorId,
        this.openingBalance,
        this.totalUnits,
        this.totalUnitPrice,
        this.balanceAmount,
        this.paidAmount,
        this.createdAt,
        this.updatedAt,
        this.createdBy,
        this.updatedBy});

  PayDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorId = json['vendor_id'];
    openingBalance = json['opening_balance'];
    totalUnits = json['total_units'];
    totalUnitPrice = json['total_unit_price'];
    balanceAmount = json['balance_amount'];
    paidAmount = json['paid_amount'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['vendor_id'] = this.vendorId;
    data['opening_balance'] = this.openingBalance;
    data['total_units'] = this.totalUnits;
    data['total_unit_price'] = this.totalUnitPrice;
    data['balance_amount'] = this.balanceAmount;
    data['paid_amount'] = this.paidAmount;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}

class Vendor {
  int? id;
  String? name;
  String? siteUtilities;
  String? mobileNo;
  String? email;
  String? address;
  String? gst;
  String? createdAt;
  String? updatedAt;

  Vendor(
      {this.id,
        this.name,
        this.siteUtilities,
        this.mobileNo,
        this.email,
        this.address,
        this.gst,
        this.createdAt,
        this.updatedAt,
      });

  Vendor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    siteUtilities = json['site_utilities'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    address = json['address'];
    gst = json['gst'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['site_utilities'] = this.siteUtilities;
    data['mobile_no'] = this.mobileNo;
    data['email'] = this.email;
    data['address'] = this.address;
    data['gst'] = this.gst;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}