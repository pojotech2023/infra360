class SubContractorDashboardModel {
  int? responseCode;
  List<SubContractorData>? data;
  bool? status;
  String? message;

  SubContractorDashboardModel(
      {this.responseCode, this.data, this.status, this.message});

  SubContractorDashboardModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    if (json['data'] != null) {
      data = <SubContractorData>[];
      json['data'].forEach((v) {
        data!.add(new SubContractorData.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response code'] = this.responseCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class SubContractorData {
  int? subcontractorId;
  String? subcontractorName;
  String? type;
  int? totalAmount;
  String? paidAmount;
  String? pendingAmount;

  SubContractorData({this.subcontractorId,this.subcontractorName,this.type, this.totalAmount, this.paidAmount, this.pendingAmount});

  SubContractorData.fromJson(Map<String, dynamic> json) {
    subcontractorId = json['subcontractor_id'];
    subcontractorName = json['subcontractor_name'];
    type = json['type'];
    totalAmount = json['total_amount'];
    paidAmount = json['paid_amount'];
    pendingAmount = json['pending_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['subcontractor_id'] = this.subcontractorId;
    data['subcontractor_name'] = this.subcontractorName;
    data['type'] = this.type;
    data['total_amount'] = this.totalAmount;
    data['paid_amount'] = this.paidAmount;
    data['pending_amount'] = this.pendingAmount;
    return data;
  }
}