class SubcontractorAmountModel {
  List<Subcontractors>? subcontractors;
  String? siteName;
  int? totalAmount;

  SubcontractorAmountModel(
      {this.subcontractors, this.siteName, this.totalAmount});

  SubcontractorAmountModel.fromJson(Map<String, dynamic> json) {
    if (json['subcontractors'] != null) {
      subcontractors = <Subcontractors>[];
      json['subcontractors'].forEach((v) {
        subcontractors!.add(new Subcontractors.fromJson(v));
      });
    }
    siteName = json['siteName'];
    totalAmount = json['totalAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.subcontractors != null) {
      data['subcontractors'] =
          this.subcontractors!.map((v) => v.toJson()).toList();
    }
    data['siteName'] = this.siteName;
    data['totalAmount'] = this.totalAmount;
    return data;
  }
}

class Subcontractors {
  int? id;
  int? siteId;
  int? subcontractorId;
  String? subcontractorType;
  String? date;
  String? amount;
  Null? remarks;
  int? status;
  String? noCounts;
  int? createdBy;
  Null? updatedBy;
  String? createdAt;
  String? updatedAt;
  Subcontractor? subcontractor;

  Subcontractors(
      {this.id,
        this.siteId,
        this.subcontractorId,
        this.subcontractorType,
        this.date,
        this.amount,
        this.remarks,
        this.status,
        this.noCounts,
        this.createdBy,
        this.updatedBy,
        this.createdAt,
        this.updatedAt,
        this.subcontractor});

  Subcontractors.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteId = json['site_id'];
    subcontractorId = json['subcontractor_id'];
    subcontractorType = json['subcontractor_type'];
    date = json['date'];
    amount = json['amount'];
    remarks = json['remarks'];
    status = json['status'];
    noCounts = json['no_counts'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    subcontractor = json['subcontractor'] != null
        ? new Subcontractor.fromJson(json['subcontractor'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['site_id'] = this.siteId;
    data['subcontractor_id'] = this.subcontractorId;
    data['subcontractor_type'] = this.subcontractorType;
    data['date'] = this.date;
    data['amount'] = this.amount;
    data['remarks'] = this.remarks;
    data['status'] = this.status;
    data['no_counts'] = this.noCounts;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.subcontractor != null) {
      data['subcontractor'] = this.subcontractor!.toJson();
    }
    return data;
  }
}

class Subcontractor {
  int? id;
  String? name;
  String? subcontractors;
  String? mobileNo;
  String? email;
  String? address;
  String? gst;
  int? createdBy;
  int? updatedBy;
  String? createdAt;
  String? updatedAt;

  Subcontractor(
      {this.id,
        this.name,
        this.subcontractors,
        this.mobileNo,
        this.email,
        this.address,
        this.gst,
        this.createdBy,
        this.updatedBy,
        this.createdAt,
        this.updatedAt});

  Subcontractor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    subcontractors = json['subcontractors'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    address = json['address'];
    gst = json['gst'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['subcontractors'] = this.subcontractors;
    data['mobile_no'] = this.mobileNo;
    data['email'] = this.email;
    data['address'] = this.address;
    data['gst'] = this.gst;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
