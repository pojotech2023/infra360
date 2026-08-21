class TermsConditionModel {
  int? responseCode;
  List<TermsConditionData>? data;
  bool? status;
  String? message;

  TermsConditionModel({this.responseCode, this.data, this.status, this.message});

  TermsConditionModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    if (json['data'] != null) {
      data = <TermsConditionData>[];
      json['data'].forEach((v) {
        data!.add(TermsConditionData.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['response code'] = responseCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class TermsConditionData {
  int? id;
  String? title;
  String? description;
  String? createdAt;
  String? updatedAt;

  TermsConditionData({
    this.id,
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  TermsConditionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
