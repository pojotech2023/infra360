class QuotationHistoryModel {
  bool? status;
  String? message;
  List<QuotationHistoryData>? data;

  QuotationHistoryModel({this.status, this.message, this.data});

  QuotationHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <QuotationHistoryData>[];
      json['data'].forEach((v) {
        data!.add(QuotationHistoryData.fromJson(v));
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

class QuotationHistoryData {
  int? id;
  String? name;
  String? date;
  String? mobileNo;
  String? subject;
  String? location;
  String? contractor;
  String? totalAmount;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  int? updatedBy;
  List<QuotationHistoryDetail>? details;

  QuotationHistoryData({
    this.id,
    this.name,
    this.date,
    this.mobileNo,
    this.subject,
    this.location,
    this.contractor,
    this.totalAmount,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.details,
  });

  QuotationHistoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    date = json['date'];
    mobileNo = json['mobile_no'];
    subject = json['subject'];
    location = json['location'];
    contractor = json['contractor'];
    totalAmount = json['total_amount']?.toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    if (json['details'] != null) {
      details = <QuotationHistoryDetail>[];
      json['details'].forEach((v) {
        details!.add(QuotationHistoryDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['date'] = date;
    data['mobile_no'] = mobileNo;
    data['subject'] = subject;
    data['location'] = location;
    data['contractor'] = contractor;
    data['total_amount'] = totalAmount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    if (details != null) {
      data['details'] = details!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class QuotationHistoryDetail {
  int? id;
  int? quotationId;
  String? particular;
  String? rate;
  String? sqFt;
  String? unit;
  String? totalCost;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  int? updatedBy;
  int? isDefault;

  QuotationHistoryDetail({
    this.id,
    this.quotationId,
    this.particular,
    this.rate,
    this.sqFt,
    this.unit,
    this.totalCost,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.isDefault,
  });

  QuotationHistoryDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    quotationId = json['quotation_id'];
    particular = json['particular'];
    rate = json['rate']?.toString();
    sqFt = json['sqFt']?.toString();
    unit = json['unit'];
    totalCost = json['total_cost']?.toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    isDefault = json['is_default'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['quotation_id'] = quotationId;
    data['particular'] = particular;
    data['rate'] = rate;
    data['sqFt'] = sqFt;
    data['unit'] = unit;
    data['total_cost'] = totalCost;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    data['is_default'] = isDefault;
    return data;
  }
}
