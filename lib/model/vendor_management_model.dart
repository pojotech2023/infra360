class VendorManagementModel {
  int? responseCode;
  List<VendorManagementData>? data;
  bool? status;
  String? message;

  VendorManagementModel(
      {this.responseCode, this.data, this.status, this.message});

  VendorManagementModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    if (json['data'] != null) {
      data = <VendorManagementData>[];
      json['data'].forEach((v) {
        data!.add( VendorManagementData.fromJson(v));
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

class VendorManagementData {
  int? id;
  String? name;
  String? siteUtilities;
  String? mobileNo;
  String? email;
  String? address;
  String? gst;
  String? createdAt;
  String? updatedAt;

  VendorManagementData(
      {this.id,
        this.name,
        this.siteUtilities,
        this.mobileNo,
        this.email,
        this.address,
        this.gst,
        this.createdAt,
        this.updatedAt
      });

  VendorManagementData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    siteUtilities = json['site_utilities'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    address = json['address'];
    gst = json['gst'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['site_utilities'] = this.siteUtilities;
    data['mobile_no'] = this.mobileNo;
    data['email'] = this.email;
    data['address'] = this.address;
    data['gst'] = this.gst;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}