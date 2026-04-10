class CustomerModel {
  int? responseCode;
  Data? data;
  bool? status;
  String? message;

  CustomerModel({this.responseCode, this.data, this.status, this.message});

  CustomerModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['response code'] = responseCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  List<Customers>? customers;
  List<dynamic>? reminders; // ✅ FIXED: Was List<Null> (invalid)

  Data({this.customers, this.reminders});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['customers'] != null) {
      customers = <Customers>[];
      json['customers'].forEach((v) {
        customers!.add(Customers.fromJson(v));
      });
    }
    reminders = json['reminders']; // ✅ No need to create objects
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (customers != null) {
      data['customers'] = customers!.map((v) => v.toJson()).toList();
    }
    data['reminders'] = reminders;
    return data;
  }
}

class Customers {
  int? id;
  int? siteId;
  String? name;
  String? mobileNo;
  String? email;
  String? dob;
  String? address;
  String? marriageDate;
  int? isInactive;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  int? updatedBy;
  Site? site;

  Customers({
    this.id,
    this.siteId,
    this.name,
    this.mobileNo,
    this.email,
    this.marriageDate,
    this.dob,
    this.address,
    this.isInactive,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.site,
  });

  Customers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteId = json['site_id'];
    name = json['name'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    dob = json['dob'];
    address = json['address'];
    isInactive = json['is_inactive'];
    marriageDate = json['marriage_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    site = json['site'] != null ? Site.fromJson(json['site']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['site_id'] = siteId;
    data['name'] = name;
    data['mobile_no'] = mobileNo;
    data['email'] = email;
    data['dob'] = dob;
    data['address'] = address;
    data['is_inactive'] = isInactive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    if (site != null) {
      data['site'] = site!.toJson();
    }
    return data;
  }
}

class Site {
  int? id;
  String? siteName;
  String? siteImg;
  String? location;
  String? flatArea;
  String? builtUpArea;
  int? supervisorId;
  String? duration;
  String? status;
  int? isInactive;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  int? updatedBy;

  Site({
    this.id,
    this.siteName,
    this.siteImg,
    this.location,
    this.flatArea,
    this.builtUpArea,
    this.supervisorId,
    this.duration,
    this.status,
    this.isInactive,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  Site.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteName = json['site_name'];
    siteImg = json['site_img'];
    location = json['location'];
    flatArea = json['flat_area'];
    builtUpArea = json['built_up_area'];
    supervisorId = json['supervisor_id'];
    duration = json['duration'];
    status = json['status'];
    isInactive = json['is_inactive'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['site_name'] = siteName;
    data['site_img'] = siteImg;
    data['location'] = location;
    data['flat_area'] = flatArea;
    data['built_up_area'] = builtUpArea;
    data['supervisor_id'] = supervisorId;
    data['duration'] = duration;
    data['status'] = status;
    data['is_inactive'] = isInactive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    return data;
  }
}
