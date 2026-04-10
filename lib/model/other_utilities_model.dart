class OtherUtilitiesModel {
  int? responseCode;
  List<OtherUtilitiesData>? data;
  bool? status;
  String? message;

  OtherUtilitiesModel(
      {this.responseCode, this.data, this.status, this.message});

  OtherUtilitiesModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    if (json['data'] != null) {
      data = <OtherUtilitiesData>[];
      json['data'].forEach((v) {
        data!.add( OtherUtilitiesData.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['response code'] = responseCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class OtherUtilitiesData {
  int? id;
  int? siteId;
  String? siteName;
  String? amount;
  String? remarks;
  String? image;
  String? createdAt;
  String? updatedAt;

  OtherUtilitiesData(
      {this.id,
        this.siteId,
        this.siteName,
        this.amount,
        this.remarks,
        this.image,
        this.createdAt,
        this.updatedAt});

  OtherUtilitiesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteId = json['site_id'];
    siteName = json['site_name'];
    amount = json['amount'];
    remarks = json['remarks'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['id'] = this.id;
    data['site_id'] = this.siteId;
    data['site_name'] = this.siteName;
    data['amount'] = this.amount;
    data['remarks'] = this.remarks;
    data['image'] = this.image;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}