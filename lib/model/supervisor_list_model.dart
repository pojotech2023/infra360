class SuperVisorModel {
  int? responseCode;
  List<SuperVisorData>? data;
  bool? status;
  String? message;

  SuperVisorModel({this.responseCode, this.data, this.status, this.message});

  SuperVisorModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    if (json['data'] != null) {
      data = <SuperVisorData>[];
      json['data'].forEach((v) {
        data!.add( SuperVisorData.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['response code'] = this.responseCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class SuperVisorData {
  int? id;
  String? name;
  String? mobileNo;
  String? email;
  String? image;
  String? password;
  String? createdAt;
  String? updatedAt;
  int? updatedBy;

  SuperVisorData(
      {this.id,
        this.name,
        this.mobileNo,
        this.email,
        this.password,
        this.image,
        this.createdAt,
        this.updatedAt,
        this.updatedBy});

  SuperVisorData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    image = json['image'];
    password = json['password'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['mobile_no'] = this.mobileNo;
    data['email'] = this.email;
    data['image'] = this.image;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}