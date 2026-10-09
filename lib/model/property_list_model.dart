class PropertyListModel {
  int? respnseCode;
  List<PropertyListData>? data;
  bool? status;
  String? message;

  PropertyListModel({this.respnseCode, this.data, this.status, this.message});

  PropertyListModel.fromJson(Map<String, dynamic> json) {
    respnseCode = json['respnse code'];
    if (json['data'] != null) {
      data = <PropertyListData>[];
      json['data'].forEach((v) {
        data!.add( PropertyListData.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['respnse code'] = this.respnseCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class PropertyListData {
  int? id;
  String? name;
  String? location;
  String? type;
  String? amount;
  String? remarks;
  String? image;
  String? imageUrl;
  int? isInactive;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  int? updatedBy;

  PropertyListData(
      {this.id,
        this.name,
        this.location,
        this.type,
        this.amount,
        this.remarks,
        this.image,
        this.imageUrl,
        this.isInactive,
        this.createdAt,
        this.updatedAt,
        this.createdBy,
        this.updatedBy});

  PropertyListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    location = json['location'];
    type = json['type'];
    amount = json['amount']?.toString();
    remarks = json['remarks'];
    image = json['image'];
    imageUrl = json['image_url'];
    isInactive = json['is_inactive'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['location'] = this.location;
    data['type'] = this.type;
    data['amount'] = this.amount;
    data['remarks'] = this.remarks;
    data['image'] = this.image;
    data['image_url'] = this.imageUrl;
    data['is_inactive'] = this.isInactive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}


