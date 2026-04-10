
class TicketModel {
  bool? status;
  String? message;
  List<TicketData>? data;

  TicketModel({this.status, this.message, this.data});

  TicketModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <TicketData>[];
      json['data'].forEach((v) {
        data!.add(new TicketData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TicketData {
  int? id;
  int? siteId;
  int? customerId;
  String? ticket;
  String? createdAt;
  String? updatedAt;
  String? filePath;

  TicketData(
      {this.id,
        this.siteId,
        this.customerId,
        this.ticket,
        this.createdAt,
        this.updatedAt,
        this.filePath});

  TicketData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteId = json['site_id'];
    customerId = json['customer_id'];
    ticket = json['ticket'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    filePath = json['file_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['site_id'] = this.siteId;
    data['customer_id'] = this.customerId;
    data['ticket'] = this.ticket;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['file_path'] = this.filePath;
    return data;
  }
}
