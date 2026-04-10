class VendorPaymentHistoryModel {
  int? responseCode;
  bool? status;
  VendorPaymentHistoryData? data;
  String? message;

  VendorPaymentHistoryModel(
      {this.responseCode, this.status, this.data, this.message});

  VendorPaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    status = json['status'];
    data = json['data'] != null ? new VendorPaymentHistoryData.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['response code'] = this.responseCode;
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class VendorPaymentHistoryData {
  List<PaymentHistoryList>? paymentHistoryList;
  int? totalPaidAmount;

  VendorPaymentHistoryData({this.paymentHistoryList, this.totalPaidAmount});

  VendorPaymentHistoryData.fromJson(Map<String, dynamic> json) {
    if (json['payment_historyList'] != null) {
      paymentHistoryList = <PaymentHistoryList>[];
      json['payment_historyList'].forEach((v) {
        paymentHistoryList!.add(new PaymentHistoryList.fromJson(v));
      });
    }
    totalPaidAmount = json['total_paidAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.paymentHistoryList != null) {
      data['payment_historyList'] =
          this.paymentHistoryList!.map((v) => v.toJson()).toList();
    }
    data['total_paidAmount'] = this.totalPaidAmount;
    return data;
  }
}

class PaymentHistoryList {
  int? id;
  int? vendorId;
  String? payment;
  String? date;
  String? paymentMode;
  String? createdAt;
  String? updatedAt;
  Vendor? vendor;

  PaymentHistoryList(
      {this.id,
        this.vendorId,
        this.payment,
        this.date,
        this.paymentMode,
        this.createdAt,
        this.updatedAt,
        this.vendor});

  PaymentHistoryList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorId = json['vendor_id'];
    payment = json['payment'];
    date = json['date'];
    paymentMode = json['payment_mode'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    vendor =
    json['vendor'] != null ? new Vendor.fromJson(json['vendor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['vendor_id'] = this.vendorId;
    data['payment'] = this.payment;
    data['date'] = this.date;
    data['payment_mode'] = this.paymentMode;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.vendor != null) {
      data['vendor'] = this.vendor!.toJson();
    }
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