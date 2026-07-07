class SubcontractorPaymentDetailsModel {
  int? responseCode;
  bool? status;
  SubcontractorPaymentDetailsData? data;
  String? message;

  SubcontractorPaymentDetailsModel(
      {this.responseCode, this.status, this.data, this.message});

  SubcontractorPaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    data = json['data'] != null ? new SubcontractorPaymentDetailsData.fromJson(json['data']) : null;
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

class SubcontractorPaymentDetailsData {
  String? totalUnits;
  String? totalAmount;
  SubcontractorPayDetail? payDetail;
  Subcontractor? subcontractor;
  String? siteName;

  SubcontractorPaymentDetailsData({this.totalUnits, this.totalAmount, this.payDetail, this.subcontractor, this.siteName});

  SubcontractorPaymentDetailsData.fromJson(Map<String, dynamic> json) {
    totalUnits = json['total_counts']?.toString() ?? json['no_counts']?.toString() ?? json['total_units']?.toString() ?? json['totalUnits']?.toString();
    totalAmount = json['total_amount']?.toString() ?? json['totalAmount']?.toString();
    payDetail = json['pay_detail'] != null
        ? new SubcontractorPayDetail.fromJson(json['pay_detail'])
        : null;
    subcontractor =
    json['subcontractor'] != null ? new Subcontractor.fromJson(json['subcontractor']) : null;
    siteName = json['site_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_units'] = this.totalUnits;
    data['total_amount'] = this.totalAmount;
    if (this.payDetail != null) {
      data['pay_detail'] = this.payDetail!.toJson();
    }
    if (this.subcontractor != null) {
      data['subcontractor'] = this.subcontractor!.toJson();
    }
    data['site_name'] = this.siteName;
    return data;
  }
}

class SubcontractorPayDetail {
  int? id;
  int? subcontractorId;
  String? openingBalance;
  String? totalUnits;
  String? totalUnitPrice;
  String? balanceAmount;
  String? paidAmount;
  String? createdAt;
  String? updatedAt;
  dynamic createdBy;
  dynamic updatedBy;

  SubcontractorPayDetail(
      {this.id,
        this.subcontractorId,
        this.openingBalance,
        this.totalUnits,
        this.totalUnitPrice,
        this.balanceAmount,
        this.paidAmount,
        this.createdAt,
        this.updatedAt,
        this.createdBy,
        this.updatedBy});

  SubcontractorPayDetail.fromJson(Map<String, dynamic> json) {
    print("SubcontractorPayDetail.fromJson keys: ${json.keys.toList()}");
    id = json['id'];
    subcontractorId = json['subcontractor_id'];
    openingBalance = json['opening_balance'];
    totalUnits = json['total_counts']?.toString() ?? json['no_counts']?.toString() ?? json['total_units']?.toString() ?? json['totalUnits']?.toString();
    totalUnitPrice = json['total_amount']?.toString() ?? json['total_unit_price']?.toString() ?? json['totalUnitPrice']?.toString();
    balanceAmount = json['balance_amount']?.toString() ?? json['balanceAmount']?.toString();
    paidAmount = json['paid_amount']?.toString() ?? json['paidAmount']?.toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['subcontractor_id'] = this.subcontractorId;
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

class Subcontractor {
  int? id;
  String? name;
  String? siteUtilities;
  String? mobileNo;
  String? email;
  String? address;
  String? gst;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  int? updatedBy;

  Subcontractor(
      {this.id,
        this.name,
        this.siteUtilities,
        this.mobileNo,
        this.email,
        this.address,
        this.gst,
        this.createdAt,
        this.updatedAt,
        this.createdBy,
        this.updatedBy});

  Subcontractor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    siteUtilities = json['site_utilities'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    address = json['address'];
    gst = json['gst'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
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
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
