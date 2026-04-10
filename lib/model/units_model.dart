

class UnitsModel {
  String? status;
  List<UnitsData>? data;

  UnitsModel({this.status, this.data});

  UnitsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <UnitsData>[];
      json['data'].forEach((v) {
        data!.add(new UnitsData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class UnitsData {
  String? materialType;
  bool? attachment;
  List<String>? unit;
  List<String>? categoryName;

  UnitsData({
    this.materialType,
    this.attachment,
    this.unit,
    this.categoryName,
  });

  factory UnitsData.fromJson(Map<String, dynamic> json) {
    return UnitsData(
      materialType: json['material_type']?.toString(),
      attachment: json['attachment'] == true || json['attachment'] == 1,
      unit: (json['unit'] as List?)
          ?.map((e) => e.toString())
          .toList(), // ✅ Converts int or string to String safely
      categoryName: (json['category_name'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialType': materialType,
      'attachment': attachment,
      'unit': unit,
      'categoryName': categoryName,
    };
  }
}
