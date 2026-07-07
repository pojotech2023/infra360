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
    message = json['message'];

    print("SubContractorPaymentHistoryModel raw keys: ${json.keys.toList()}");

    // Try nested under 'data' first, then fall back to root-level
    if (json['data'] != null && json['data'] is Map) {
      data = SubContractorPaymentHistory.fromJson(
          json['data'] as Map<String, dynamic>);
    } else {
      // Backend might return fields directly at root (no 'data' wrapper)
      data = SubContractorPaymentHistory.fromJson(json);
    }
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
  int? subcontractorId;
  int? siteId;
  String? siteName;
  List<PaymentHistoryList>? paymentHistoryList;
  int? totalPaidAmount;

  SubContractorPaymentHistory({
    this.subcontractorId,
    this.siteId,
    this.siteName,
    this.paymentHistoryList,
    this.totalPaidAmount,
  });

  SubContractorPaymentHistory.fromJson(Map<String, dynamic> json) {
    subcontractorId = json['subcontractor_id'];
    siteId = json['site_id'];
    siteName = json['site_name'];

    // Backend returns 'payment_historyList' — fall back to 'payment_history' for safety
    final rawList = json['payment_historyList'] ?? json['payment_history'];
    if (rawList != null && rawList is List) {
      paymentHistoryList = rawList
          .map((e) => PaymentHistoryList.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Handle total_paid_amount as int or String
    final rawTotal = json['total_paid_amount'];
    if (rawTotal is int) {
      totalPaidAmount = rawTotal;
    } else if (rawTotal != null) {
      totalPaidAmount = int.tryParse(rawTotal.toString()) ?? 0;
    }

    print("SubContractorPaymentHistory parsed — subcontractorId: $subcontractorId, records: ${paymentHistoryList?.length}, total: $totalPaidAmount");
  }

  Map<String, dynamic> toJson() {
    return {
      'subcontractor_id': subcontractorId,
      'site_id': siteId,
      'site_name': siteName,
      'payment_history':
      paymentHistoryList?.map((e) => e.toJson()).toList(),
      'total_paid_amount': totalPaidAmount,
    };
  }
}
class PaymentHistoryList {
  int? id;
  int? subcontractorId;
  String? payment;
  String? date;
  String? paymentMode;
  String? remarks;
  String? createdAt;
  String? updatedAt;
  SubContractor? subcontractor;

  PaymentHistoryList({
    this.id,
    this.subcontractorId,
    this.payment,
    this.date,
    this.paymentMode,
    this.remarks,
    this.createdAt,
    this.updatedAt,
    this.subcontractor,
  });

  PaymentHistoryList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subcontractorId = json['subcontractor_id'];
    payment = json['payment']?.toString();
    date = json['date'];
    paymentMode = json['payment_mode'];
    remarks = json['remarks']?.toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    subcontractor = json['subcontractor'] != null
        ? SubContractor.fromJson(json['subcontractor'])
        : null;
    print("PaymentHistoryList.fromJson - id: $id, payment: $payment, remarks: $remarks, mode: $paymentMode");
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subcontractor_id': subcontractorId,
      'payment': payment,
      'date': date,
      'payment_mode': paymentMode,
      'remarks': remarks,
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

