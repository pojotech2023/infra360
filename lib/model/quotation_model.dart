import 'package:flutter/cupertino.dart';

class QuotationModel {
  bool? status;
  List<QuotationData>? data;

  QuotationModel({this.status, this.data});

  QuotationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <QuotationData>[];
      json['data'].forEach((v) {
        data!.add(new QuotationData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class QuotationData {
  int? id;
  TextEditingController? particular = TextEditingController();
  TextEditingController? rate = TextEditingController();
  TextEditingController? sqFt = TextEditingController();
  TextEditingController? total = TextEditingController();
  String? unit;
  String? createdAt;
  String? updatedAt;

  QuotationData(
      {this.id,
        this.particular,
        this.rate,
        this.sqFt,
        this.unit,
        this.total,
        this.createdAt,
        this.updatedAt});

  QuotationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    unit = json['unit'];


    particular = TextEditingController(text: json['particular'] ?? '');
    rate = TextEditingController(text: json['rate'] ?? '');
    sqFt = TextEditingController(text: json['sqFt'] ?? '');

    // Safely calculate total
    final sqFtVal = double.tryParse(json['sqFt'] ?? '0') ?? 0;
    final rateVal = double.tryParse(json['rate'] ?? '0') ?? 0;
    total = TextEditingController(text: '${sqFtVal * rateVal}');
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['particular'] = this.particular;
    data['rate'] = this.rate;
    data['sqFt'] = this.sqFt;
    data['unit'] = this.unit;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
