class AgentListModel {
  int? respnseCode;
  List<AgentListData>? data;
  bool? status;
  String? message;

  AgentListModel({this.respnseCode, this.data, this.status, this.message});

  AgentListModel.fromJson(Map<String, dynamic> json) {
    respnseCode = json['respnse code'];
    if (json['data'] != null) {
      data = <AgentListData>[];
      json['data'].forEach((v) {
        data!.add(new AgentListData.fromJson(v));
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

class AgentListData {
  int? id;
  String? name;
  String? companyName;
  String? mobileNo;
  int? isInactive;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  int? updatedBy;

  AgentListData(
      {this.id,
        this.name,
        this.companyName,
        this.mobileNo,
        this.isInactive,
        this.createdAt,
        this.updatedAt,
        this.createdBy,
        this.updatedBy});

  AgentListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    companyName = json['company_name'];
    mobileNo = json['mobile_no'];
    isInactive = json['is_inactive'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['company_name'] = this.companyName;
    data['mobile_no'] = this.mobileNo;
    data['is_inactive'] = this.isInactive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}