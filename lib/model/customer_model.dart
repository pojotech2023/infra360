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
  String? siteName;

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
    this.siteName,
  });

  Customers.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    siteId = json['site_id'] is int ? json['site_id'] : int.tryParse(json['site_id']?.toString() ?? '');
    name = json['name']?.toString();
    mobileNo = json['mobile_no']?.toString();
    email = json['email']?.toString();
    dob = json['dob']?.toString();
    address = json['address']?.toString();
    isInactive = json['is_inactive'] is int ? json['is_inactive'] : int.tryParse(json['is_inactive']?.toString() ?? '');
    marriageDate = json['marriage_date']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    createdBy = json['created_by'] is int ? json['created_by'] : int.tryParse(json['created_by']?.toString() ?? '');
    updatedBy = json['updated_by'] is int ? json['updated_by'] : int.tryParse(json['updated_by']?.toString() ?? '');
    if (json['site'] != null && json['site'] is Map) {
      site = Site.fromJson(Map<String, dynamic>.from(json['site']));
    }
    siteName = json['site_name']?.toString() ??
        site?.siteName ??
        (json['site'] is Map
            ? (json['site']['site_name']?.toString() ?? json['site']['name']?.toString())
            : (json['site'] is String ? json['site'].toString() : null));
  }

  String get displaySiteName {
    if (siteName != null && siteName!.trim().isNotEmpty) {
      return siteName!.trim();
    }
    if (site?.siteName != null && site!.siteName!.trim().isNotEmpty) {
      return site!.siteName!.trim();
    }
    return '';
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
    data['site_name'] = siteName;
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
