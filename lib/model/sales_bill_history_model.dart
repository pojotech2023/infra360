class SalesBillHistoryModel {
  bool? status;
  String? message;
  List<SalesBillHistoryData>? data;

  SalesBillHistoryModel({this.status, this.message, this.data});

  SalesBillHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SalesBillHistoryData>[];
      if (json['data'] is List) {
        json['data'].forEach((v) {
          data!.add(SalesBillHistoryData.fromJson(v));
        });
      }
    }
  }
}

class SalesBillHistoryData {
  int? id;
  String? date;
  String? name;
  String? subject;
  dynamic totalAmount;
  String? pdfUrl;
  String? whatsappUrl;

  SalesBillHistoryData({
    this.id,
    this.date,
    this.name,
    this.subject,
    this.totalAmount,
    this.pdfUrl,
    this.whatsappUrl,
  });

  SalesBillHistoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    name = json['name'] ?? json['customer_name'];
    subject = json['subject'];
    totalAmount = json['total_amount'] ?? json['total'];
    pdfUrl = json['pdf'] ?? json['pdf_url'];
    whatsappUrl = json['whatsapp_url'];
  }
}
