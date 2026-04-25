class SitePaymentSummaryModel {
  bool? status;
  String? message;
  SitePaymentSummaryData? data;

  SitePaymentSummaryModel({this.status, this.message, this.data});

  SitePaymentSummaryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? SitePaymentSummaryData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class SitePaymentSummaryData {
  int? siteId;
  String? budgetAmount;
  String? paidAmount;
  String? balanceAmount;

  SitePaymentSummaryData(
      {this.siteId, this.budgetAmount, this.paidAmount, this.balanceAmount});

  SitePaymentSummaryData.fromJson(Map<String, dynamic> json) {
    siteId = json['site_id'];
    budgetAmount = json['budget_amount']?.toString();
    paidAmount = json['paid_amount']?.toString();
    balanceAmount = json['balance_amount']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['site_id'] = siteId;
    data['budget_amount'] = budgetAmount;
    data['paid_amount'] = paidAmount;
    data['balance_amount'] = balanceAmount;
    return data;
  }
}
