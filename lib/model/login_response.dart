class LoginResponse {
  Data? data;

  LoginResponse({this.data});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? responseCode;
  String? token;
  User? user;
  String? role;
  bool? status;
  String? message;
  int? totalSites;
  int? activeSites;
  int? remainingSites;
  int? siteLimit;

  Data(
      {this.responseCode,
        this.token,
        this.user,
        this.role,
        this.status,
        this.message,
        this.totalSites,
        this.activeSites,
        this.remainingSites,
        this.siteLimit});

  Data.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    token = json['token'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    role = json['role'];
    status = json['status'];
    message = json['message'];
    totalSites = json['total_sites'];
    activeSites = json['active_sites'];
    remainingSites = json['remaining_sites'];
    siteLimit = json['site_limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response code'] = this.responseCode;
    data['token'] = this.token;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['role'] = this.role;
    data['status'] = this.status;
    data['message'] = this.message;
    data['total_sites'] = this.totalSites;
    data['active_sites'] = this.activeSites;
    data['remaining_sites'] = this.remainingSites;
    data['site_limit'] = this.siteLimit;
    return data;
  }
}

class User {
  int? id;
  String? image;
  String? name;
  String? mobileNo;
  String? role;
  String? email;
  dynamic emailVerifiedAt;
  String? password;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  int? updatedBy;
  List<Roles>? roles;

  User(
      {this.id,
        this.name,
        this.image,
        this.mobileNo,
        this.email,
        this.role,
        this.emailVerifiedAt,
        this.password,
        this.createdAt,
        this.updatedAt,
        this.createdBy,
        this.updatedBy,
        this.roles});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    role = json['role'];
    emailVerifiedAt = json['email_verified_at'];
    password = json['password'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    if (json['roles'] != null) {
      roles = <Roles>[];
      json['roles'].forEach((v) {
        roles!.add(new Roles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['name'] = this.name;
    data['mobile_no'] = this.mobileNo;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['password'] = this.password;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    if (this.roles != null) {
      data['roles'] = this.roles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Roles {
  int? id;
  String? roleName;
  String? createdAt;
  String? updatedAt;
  Pivot? pivot;

  Roles({this.id, this.roleName, this.createdAt, this.updatedAt, this.pivot});

  Roles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roleName = json['role_name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? new Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role_name'] = this.roleName;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.pivot != null) {
      data['pivot'] = this.pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? userId;
  int? roleId;

  Pivot({this.userId, this.roleId});

  Pivot.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    roleId = json['role_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['role_id'] = this.roleId;
    return data;
  }
}