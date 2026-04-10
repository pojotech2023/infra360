class MaterialResponse {
  final int ?responseCode;
  final bool ?status;
  final String ?message;
  final Map<String, MaterialItem> ?data;

  MaterialResponse({
     this.responseCode,
     this.status,
     this.message,
     this.data,
  });

  factory MaterialResponse.fromJson(Map<String, dynamic> json) {
    final materials = <String, MaterialItem>{};

    if (json['data'] is Map<String, dynamic>) {
      json['data'].forEach((key, value) {
        materials[key] = MaterialItem.fromJson(value);
      });
    }



    return MaterialResponse(
      responseCode: json['response code'],
      status: json['status'],
      message: json['message'],
      data: materials,
    );
  }

  Map<String, dynamic> toJson() {
    final dataMap = <String, dynamic>{};
    data==null?{}: data!.forEach((key, value) {
      dataMap[key] = value.toJson();
    });

    return {
      'response code': responseCode,
      'status': status,
      'message': message,
      'data': dataMap,
    };
  }
}
class MaterialItem {
  final int units;
  final int values;

  MaterialItem({required this.units, required this.values});

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      units: json['units'],
      values: json['values'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'units': units,
      'values': values,
    };
  }
}
