class UnitMasterListResponse {
  bool? status;
  String? message;
  List<UnitMasterData>? data;

  UnitMasterListResponse({this.status, this.message, this.data});

  UnitMasterListResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <UnitMasterData>[];
      if (json['data'] is List) {
        json['data'].forEach((v) {
          data!.add(UnitMasterData.fromJson(v));
        });
      } else if (json['data']['units'] != null) {
        json['data']['units'].forEach((v) {
          data!.add(UnitMasterData.fromJson(v));
        });
      }
    }
  }
}

class UnitMasterData {
  int? id;
  String? unitName;

  UnitMasterData({this.id, this.unitName});

  UnitMasterData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    unitName = json['unit_name'] ?? json['name'];
  }
}
