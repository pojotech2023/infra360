class EmployeeListModel {
  int? responseCode;
  List<EmployeeListData>? data;
  bool? status;
  String? message;

  EmployeeListModel({this.responseCode, this.data, this.status, this.message});

  EmployeeListModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    if (json['data'] != null) {
      data = <EmployeeListData>[];
      json['data'].forEach((v) {
        data!.add(new EmployeeListData.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response code'] = this.responseCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class EmployeeListData {
  int? id;
  String? name;
  String? mobileNo;
  String? email;
  Null? emailVerifiedAt;
  String? password;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  int? updatedBy;
  String? role;

  EmployeeListData(
      {this.id,
      this.name,
      this.mobileNo,
      this.email,
      this.emailVerifiedAt,
      this.password,
      this.image,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.updatedBy,
      this.role});

  EmployeeListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    password = json['password'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['mobile_no'] = this.mobileNo;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['password'] = this.password;
    data['image'] = this.image;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    data['role'] = this.role;
    return data;
  }
}
