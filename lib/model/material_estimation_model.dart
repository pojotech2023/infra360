// Model for GET /api/material-estimation-form/{siteId} response
class MaterialEstimationFormModel {
  bool? status;
  String? message;
  MaterialEstimationFormData? data;

  MaterialEstimationFormModel({this.status, this.message, this.data});

  MaterialEstimationFormModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? MaterialEstimationFormData.fromJson(json['data']) : null;
  }
}

class MaterialEstimationFormData {
  List<UnitInfo>? units;
  List<RequestedMaterial>? requestedMaterials;

  MaterialEstimationFormData({this.units, this.requestedMaterials});

  MaterialEstimationFormData.fromJson(Map<String, dynamic> json) {
    if (json['units'] != null) {
      if (json['units'] is List) {
        units = (json['units'] as List).map((v) => UnitInfo.fromJson(v)).toList();
      }
    } else if (json['unit'] != null) {
      if (json['unit'] is List) {
        units = (json['unit'] as List).map((v) => UnitInfo.fromJson(v)).toList();
      }
    }

    if (json['requests'] != null) {
      if (json['requests'] is List) {
        requestedMaterials = (json['requests'] as List)
            .map((v) => RequestedMaterial.fromJson(v))
            .toList();
      }
    } else if (json['requested_materials'] != null) {
      if (json['requested_materials'] is List) {
        requestedMaterials = (json['requested_materials'] as List)
            .map((v) => RequestedMaterial.fromJson(v))
            .toList();
      }
    } else if (json['materials'] != null) {
      if (json['materials'] is List) {
        requestedMaterials = (json['materials'] as List)
            .map((v) => RequestedMaterial.fromJson(v))
            .toList();
      }
    }
  }
}

class UnitInfo {
  int? id;
  String? name;

  UnitInfo({this.id, this.name});

  UnitInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] ?? json['unit_name'];
  }
}

class RequestedMaterial {
  int? id;
  String? particular;
  String? unit;
  int? unitId;
  String? date;

  RequestedMaterial({this.id, this.particular, this.unit, this.unitId, this.date});

  RequestedMaterial.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    particular = json['particular'];
    unit = json['unit'];
    unitId = json['unit_id'];
    date = json['date'];
  }
}

// Model for GET /api/material-estimation/{id} response
class MaterialEstimationDetailModel {
  bool? status;
  String? message;
  RequestedMaterial? data;

  MaterialEstimationDetailModel({this.status, this.message, this.data});

  MaterialEstimationDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? RequestedMaterial.fromJson(json['data']) : null;
  }
}
