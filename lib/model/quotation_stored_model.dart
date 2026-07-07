class QuotationStoredModel {
  bool? status;
  String? message;
  int? quotationId;
  String? pdfUrl;
  String? whatsappUrl;
  int? totalAmount;
  bool? mailSent;

  QuotationStoredModel(
      {this.status,
        this.message,
        this.quotationId,
        this.pdfUrl,
        this.whatsappUrl,
        this.totalAmount,
        this.mailSent});

  QuotationStoredModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    quotationId = json['quotation_id'];
    pdfUrl = json['pdf_url'];
    whatsappUrl = json['whatsapp_url'];
    totalAmount = json['total_amount'];
    mailSent = json['mail_sent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['quotation_id'] = this.quotationId;
    data['pdf_url'] = this.pdfUrl;
    data['whatsapp_url'] = this.whatsappUrl;
    data['total_amount'] = this.totalAmount;
    data['mail_sent'] = this.mailSent;
    return data;
  }
}
