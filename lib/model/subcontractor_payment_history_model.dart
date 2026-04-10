class SubContractorPaymentHistoryModel {
  int? responseCode;
  bool? status;
  SubContractorPaymentHistory? data;
  String? message;

  SubContractorPaymentHistoryModel({
    this.responseCode,
    this.status,
    this.data,
    this.message,
  });

  SubContractorPaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    status = json['status'];
    data = json['data'] != null
        ? SubContractorPaymentHistory.fromJson(json['data'])
        : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    return {
      'response code': responseCode,
      'status': status,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

class SubContractorPaymentHistory {
  List<PaymentHistoryList>? paymentHistoryList;
  int? totalPaidAmount;

  SubContractorPaymentHistory({
    this.paymentHistoryList,
    this.totalPaidAmount,
  });

  SubContractorPaymentHistory.fromJson(Map<String, dynamic> json) {
    if (json['payment_historyList'] != null) {
      paymentHistoryList = (json['payment_historyList'] as List)
          .map((e) => PaymentHistoryList.fromJson(e))
          .toList();
    }
    totalPaidAmount = json['total_paidAmount'];
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_historyList':
      paymentHistoryList?.map((e) => e.toJson()).toList(),
      'total_paidAmount': totalPaidAmount,
    };
  }
}
class PaymentHistoryList {
  int? id;
  int? subcontractorId;
  String? payment;
  String? date;
  String? paymentMode;
  String? createdAt;
  String? updatedAt;
  SubContractor? subcontractor;

  PaymentHistoryList({
    this.id,
    this.subcontractorId,
    this.payment,
    this.date,
    this.paymentMode,
    this.createdAt,
    this.updatedAt,
    this.subcontractor,
  });

  PaymentHistoryList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subcontractorId = json['subcontractor_id'];
    payment = json['payment'];
    date = json['date'];
    paymentMode = json['payment_mode'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    subcontractor = json['subcontractor'] != null
        ? SubContractor.fromJson(json['subcontractor'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subcontractor_id': subcontractorId,
      'payment': payment,
      'date': date,
      'payment_mode': paymentMode,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'subcontractor': subcontractor?.toJson(),
    };
  }
}
class SubContractor {
  int? id;
  String? name;
  String? subcontractors;
  String? mobileNo;
  String? email;
  String? address;
  String? gst;
  String? createdAt;
  String? updatedAt;

  SubContractor({
    this.id,
    this.name,
    this.subcontractors,
    this.mobileNo,
    this.email,
    this.address,
    this.gst,
    this.createdAt,
    this.updatedAt,
  });

  SubContractor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    subcontractors = json['subcontractors'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    address = json['address'];
    gst = json['gst'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subcontractors': subcontractors,
      'mobile_no': mobileNo,
      'email': email,
      'address': address,
      'gst': gst,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

