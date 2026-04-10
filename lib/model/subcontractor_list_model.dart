class SubcontractorModel {
  final int responseCode;
  final List<Subcontractor> data;
  final bool status;
  final String message;

  SubcontractorModel({
    required this.responseCode,
    required this.data,
    required this.status,
    required this.message,
  });

  factory SubcontractorModel.fromJson(Map<String, dynamic> json) {
    return SubcontractorModel(
      responseCode: json['response code'] ?? 0,
      data: (json['data'] as List<dynamic>)
          .map((item) => Subcontractor.fromJson(item))
          .toList(),
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response code': responseCode,
      'data': data.map((item) => item.toJson()).toList(),
      'status': status,
      'message': message,
    };
  }
}

class Subcontractor {
  final int id;
  final String name;
  final String subcontractors;
  final String mobileNo;
  final String email;
  final String address;
  final String gst;
  final int createdBy;
  final int? updatedBy;
  final String createdAt;
  final String updatedAt;

  Subcontractor({
    required this.id,
    required this.name,
    required this.subcontractors,
    required this.mobileNo,
    required this.email,
    required this.address,
    required this.gst,
    required this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subcontractor.fromJson(Map<String, dynamic> json) {
    return Subcontractor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      subcontractors: json['subcontractors'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      gst: json['gst'] ?? '',
      createdBy: json['created_by'] ?? 0,
      updatedBy: json['updated_by'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subcontractors': subcontractors,
      'mobile_no': mobileNo,
      'email': email,
      'address': address,
      'gst': gst,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
