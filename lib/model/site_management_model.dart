class SiteManagementModel {
  int? responseCode;
  List<SiteManagementList>? data;
  bool? status;
  String? message;

  SiteManagementModel(
      {this.responseCode, this.data, this.status, this.message});

  SiteManagementModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    if (json['data'] != null) {
      data = <SiteManagementList>[];
      json['data'].forEach((v) {
        data!.add( SiteManagementList.fromJson(v));
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

class SiteManagementList {
  int? id;
  String? siteName;
  String? siteImg;
  String? location;
  String? value;
  String? duration;
  String? flatArea;
  String? builtupArea;
  String? settledAmnt;
  String? pendingAmnt;
  String? expense;
  String? status;
  int? isInactive;
  String? createdAt;
  String? updatedAt;
  List<Customer>? customer;
  Supervisor? supervisor;

  SiteManagementList(
      {this.id,
        this.siteName,
        this.siteImg,
        this.location,
        this.flatArea,
        this.builtupArea,
        this.value,
        this.duration,
        this.settledAmnt,
        this.pendingAmnt,
        this.expense,
        this.status,
        this.isInactive,
        this.createdAt,
        this.updatedAt,
        this.customer, this.supervisor});

  SiteManagementList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteName = json['site_name'];
    siteImg = json['site_img'];
    location = json['location'];
    value = json['value'];
    flatArea = json['flat_area'];
    builtupArea = json['built_up_area'];
    duration = json['duration'];
    settledAmnt = json['settled_amnt'];
    pendingAmnt = json['pending_amnt'];
    expense = json['expense'];
    status = json['status'];
    isInactive = json['is_inactive'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['customer'] != null) {
      customer = <Customer>[];
      json['customer'].forEach((v) {
        customer!.add(new Customer.fromJson(v));
      });
    }
    supervisor = json['supervisor'] != null
        ? new Supervisor.fromJson(json['supervisor'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['site_name'] = this.siteName;
    data['site_img'] = this.siteImg;
    data['location'] = this.location;
    data['value'] = this.value;
    data['duration'] = this.duration;
    data['settled_amnt'] = this.settledAmnt;
    data['pending_amnt'] = this.pendingAmnt;
    data['expense'] = this.expense;
    data['status'] = this.status;
    data['is_inactive'] = this.isInactive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.customer != null) {
      data['customer'] = this.customer!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Customer {
  int? id;
  int? siteId;
  String? name;
  String? mobileNo;
  String? email;
  String? dob;
  String? marriageDate;
  String? address;
  int? isInactive;
  String? createdAt;
  String? updatedAt;

  Customer(
      {this.id,
        this.siteId,
        this.name,
        this.mobileNo,
        this.email,
        this.dob,
        this.marriageDate,
        this.address,
        this.isInactive,
        this.createdAt,
        this.updatedAt});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteId = json['site_id'];
    name = json['name'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    dob = json['dob'];
    marriageDate = json['marriage_date'];
    address = json['address'];
    isInactive = json['is_inactive'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['site_id'] = this.siteId;
    data['name'] = this.name;
    data['mobile_no'] = this.mobileNo;
    data['email'] = this.email;
    data['dob'] = this.dob;
    data['marriage_date'] = this.marriageDate;
    data['address'] = this.address;
    data['is_inactive'] = this.isInactive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Supervisor {
  int? id;
  String? name;
  String? mobileNo;
  String? email;
  String? emailVerifiedAt;
  String? password;
  String? image;
  String? createdAt;
  String? updatedAt;
  dynamic createdBy;
  dynamic updatedBy;
  String? role;

  Supervisor(
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

  Supervisor.fromJson(Map<String, dynamic> json) {
    id = json['id'] ??'';
    name = json['name']??'';
    mobileNo = json['mobile_no']??'';
    email = json['email']??'';
    emailVerifiedAt = json['email_verified_at']??'';
    password = json['password']??'';
    image = json['image']??'';
    createdAt = json['created_at']??'';
    updatedAt = json['updated_at']??'';
    createdBy = json['created_by']??'';
    updatedBy = json['updated_by']??'';
    role = json['role']??'';
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