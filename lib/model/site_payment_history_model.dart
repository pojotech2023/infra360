class SitePaymentHistoryModel {
  bool? status;
  String? message;
  List<PaymentHistory>? data;

  SitePaymentHistoryModel({this.status, this.message, this.data});

  SitePaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PaymentHistory>[];
      json['data'].forEach((v) {
        data!.add(PaymentHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentHistory {
  int? id;
  int? siteId;
  String? payment;
  String? date;
  String? paymentMode;
  String? remarks;
  String? createdAt;
  String? updatedAt;

  PaymentHistory(
      {this.id,
        this.siteId,
        this.payment,
        this.date,
        this.paymentMode,
        this.remarks,
        this.createdAt,
        this.updatedAt});

  PaymentHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteId = json['site_id'];
    payment = json['payment']?.toString();
    date = json['date'];
    paymentMode = json['payment_mode'];
    remarks = json['remarks'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['site_id'] = siteId;
    data['payment'] = payment;
    data['date'] = date;
    data['payment_mode'] = paymentMode;
    data['remarks'] = remarks;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
