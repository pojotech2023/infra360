class PurchaseBillHistoryModel {
  bool? status;
  String? message;
  List<PurchaseBillHistoryData>? data;

  PurchaseBillHistoryModel({this.status, this.message, this.data});

  PurchaseBillHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PurchaseBillHistoryData>[];
      if (json['data'] is List) {
        json['data'].forEach((v) {
          data!.add(PurchaseBillHistoryData.fromJson(v));
        });
      }
    }
  }
}

class PurchaseBillHistoryData {
  int? id;
  String? date;
  String? name;
  String? subject;
  dynamic totalAmount;
  String? pdfUrl;

  PurchaseBillHistoryData({
    this.id,
    this.date,
    this.name,
    this.subject,
    this.totalAmount,
    this.pdfUrl,
  });

  PurchaseBillHistoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    name = json['name'] ?? json['vendor_name'];
    subject = json['subject'];
    totalAmount = json['total_amount'] ?? json['total'];
    pdfUrl = json['pdf'] ?? json['pdf_url'];
  }
}
