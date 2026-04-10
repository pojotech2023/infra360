class VendorModel {
  int? responseCode;
  List<VendorData>? data;
  bool? status;
  String? message;

  VendorModel({this.responseCode, this.data, this.status, this.message});

  VendorModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    if (json['data'] != null) {
      data = <VendorData>[];
      json['data'].forEach((v) {
        data!.add( VendorData.fromJson(v));
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

class VendorData {
  int? id;
  String? name;
  String? mobileNo;
  String? address;

  VendorData({this.id, this.name, this.mobileNo, this.address});

  VendorData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobileNo = json['mobile_no'];
    address = json['address'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['mobile_no'] = this.mobileNo;
    data['address'] = this.address;
    return data;
  }
}