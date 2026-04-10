
class TicketDetailModel {
  bool? status;
  String? message;
  String? ticketName;
  List<TicketDetailData>? data;

  TicketDetailModel({this.status, this.message, this.ticketName, this.data});

  TicketDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    ticketName = json['ticket_name'];
    if (json['data'] != null) {
      data = <TicketDetailData>[];
      json['data'].forEach((v) {
        data!.add(new TicketDetailData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['ticket_name'] = this.ticketName;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TicketDetailData {
  int? id;
  int? ticketId;
  int? siteId;
  String? senderType;
  String? message;
  String? createdAt;
  String? updatedAt;
  String? attachment;

  TicketDetailData(
      {this.id,
        this.ticketId,
        this.siteId,
        this.senderType,
        this.message,
        this.createdAt,
        this.updatedAt,
        this.attachment});

  TicketDetailData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ticketId = json['ticket_id'];
    siteId = json['site_id'];
    senderType = json['sender_type'];
    message = json['message'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    attachment = json['attachment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ticket_id'] = this.ticketId;
    data['site_id'] = this.siteId;
    data['sender_type'] = this.senderType;
    data['message'] = this.message;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['attachment'] = this.attachment;
    return data;
  }
}
