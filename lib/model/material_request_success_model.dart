class MaterialRequestSuccessModel {
  int? responseCode;
  bool? status;
  String? message;
  MaterialData? data;

  MaterialRequestSuccessModel(
      {this.responseCode, this.status, this.message, this.data});

  factory MaterialRequestSuccessModel.fromJson(Map<String, dynamic> json) {
    return MaterialRequestSuccessModel(
      responseCode: json['response_code'],
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? MaterialData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['response_code'] = responseCode;
    json['status'] = status;
    json['message'] = message;
    if (data != null) json['data'] = data!.toJson();
    return json;
  }
}
class MaterialData {
  MaterialRequest? materialRequest;
  MaterialOrder? materialOrder;
  SiteDetails? siteDetails;
  VendorDetails? vendorDetails;

  MaterialData({this.materialRequest, this.materialOrder, this.siteDetails, this.vendorDetails});

  factory MaterialData.fromJson(Map<String, dynamic> json) {
    return MaterialData(
      materialRequest: json['material_request'] != null
          ? MaterialRequest.fromJson(json['material_request'])
          : null,
      materialOrder: json['material_order'] != null
          ? MaterialOrder.fromJson(json['material_order'])
          : null,
      siteDetails: json['site_details'] != null
          ? SiteDetails.fromJson(json['site_details'])
          : null,
      vendorDetails: json['vendor_details'] != null
          ? VendorDetails.fromJson(json['vendor_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (materialRequest != null) json['material_request'] = materialRequest!.toJson();
    if (materialOrder != null) json['material_order'] = materialOrder!.toJson();
    if (siteDetails != null) json['site_details'] = siteDetails!.toJson();
    if (vendorDetails != null) json['vendor_details'] = vendorDetails!.toJson();
    return json;
  }
}
class MaterialRequest {
  String? siteId;
  String? vendorId;
  String? materialType;
  String? quantity;
  String? unit;
  String? deliveryNeededBy;
  String? remarks;
  String? imageUrl;
  int? createdBy;
  String? updatedAt;
  String? createdAt;
  int? id;

  MaterialRequest({
    this.siteId,
    this.vendorId,
    this.materialType,
    this.quantity,
    this.unit,
    this.deliveryNeededBy,
    this.remarks,
    this.imageUrl,
    this.createdBy,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory MaterialRequest.fromJson(Map<String, dynamic> json) {
    return MaterialRequest(
      siteId: json['site_id'],
      vendorId: json['vendor_id'],
      materialType: json['material_type'],
      quantity: json['quantity'],
      unit: json['unit'],
      deliveryNeededBy: json['delivery_needed_by'],
      remarks: json['remarks'],
      imageUrl: json['image_url'],
      createdBy: json['created_by'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'site_id': siteId,
      'vendor_id': vendorId,
      'material_type': materialType,
      'quantity': quantity,
      'unit': unit,
      'delivery_needed_by': deliveryNeededBy,
      'remarks': remarks,
      'image_url': imageUrl,
      'created_by': createdBy,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }
}
class MaterialOrder {
  String? siteId;
  String? vendorId;
  String? materialType;
  String? date;
  String? quantity;
  String? unit;
  String? price;
  String? imageUrl;
  int? createdBy;
  String? updatedAt;
  String? createdAt;
  int? id;

  MaterialOrder({
    this.siteId,
    this.vendorId,
    this.materialType,
    this.date,
    this.quantity,
    this.unit,
    this.price,
    this.imageUrl,
    this.createdBy,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory MaterialOrder.fromJson(Map<String, dynamic> json) {
    return MaterialOrder(
      siteId: json['site_id'],
      vendorId: json['vendor_id'],
      materialType: json['material_type'],
      date: json['date'],
      quantity: json['quantity'],
      unit: json['unit'],
      price: json['price'],
      imageUrl: json['image_url'],
      createdBy: json['created_by'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'site_id': siteId,
      'vendor_id': vendorId,
      'material_type': materialType,
      'date': date,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'image_url': imageUrl,
      'created_by': createdBy,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }
}
class SiteDetails {
  int? siteId;
  String? siteName;
  String? categoryName;
  String? location;
  dynamic supervisor;

  SiteDetails({
    this.siteId,
    this.siteName,
    this.categoryName,
    this.location,
    this.supervisor,
  });

  factory SiteDetails.fromJson(Map<String, dynamic> json) {
    return SiteDetails(
      siteId: json['site_id'],
      siteName: json['site_name'],
      categoryName: json['category_name'],
      location: json['location'],
      supervisor: json['supervisor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'site_id': siteId,
      'site_name': siteName,
      'category_name': categoryName,
      'location': location,
      'supervisor': supervisor,
    };
  }
}
class VendorDetails {
  int? id;
  String? name;
  String? mobileNo;
  String? address;
  String? email;

  VendorDetails({this.id, this.name, this.mobileNo, this.address, this.email});

  factory VendorDetails.fromJson(Map<String, dynamic> json) {
    return VendorDetails(
      id: json['id'],
      name: json['name'],
      mobileNo: json['mobile_no'],
      address: json['address'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile_no': mobileNo,
      'address': address,
      'email': email,
    };
  }
}
