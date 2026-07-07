// Model for GET /sales-bill-form/:siteId response
class SalesBillFormModel {
  bool? status;
  String? message;
  SalesBillFormData? data;

  SalesBillFormModel({this.status, this.message, this.data});

  SalesBillFormModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? SalesBillFormData.fromJson(json['data']) : null;
  }
}

class SalesBillFormData {
  SiteInfo? site;
  List<CustomerInfo>? customers;

  SalesBillFormData({this.site, this.customers});

  SalesBillFormData.fromJson(Map<String, dynamic> json) {
    site = json['site'] != null ? SiteInfo.fromJson(json['site']) : null;
    
    if (json['customer'] != null) {
      if (json['customer'] is List) {
        customers = (json['customer'] as List).map((v) => CustomerInfo.fromJson(v)).toList();
      } else {
        customers = [CustomerInfo.fromJson(json['customer'])];
      }
    } else if (json['customers'] != null) {
      if (json['customers'] is List) {
        customers = (json['customers'] as List).map((v) => CustomerInfo.fromJson(v)).toList();
      } else {
        customers = [CustomerInfo.fromJson(json['customers'])];
      }
    }
  }
}

class SiteInfo {
  int? id;
  String? name;
  String? location;

  SiteInfo({this.id, this.name, this.location});

  SiteInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    location = json['location'];
  }
}

class CustomerInfo {
  int? id;
  String? name;
  String? email;
  String? mobileNo;
  String? address;

  CustomerInfo({this.id, this.name, this.email, this.mobileNo, this.address});

  CustomerInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    mobileNo = json['mobile_no'] ?? json['mobile'];
    address = json['address'] ?? json['location'];
  }
}

// Model for POST /sales-bill-add response
class SalesBillStoredModel {
  bool? status;
  String? message;
  int? salesBillId;
  String? pdfUrl;
  String? whatsappUrl;
  int? totalAmount;
  bool? mailSent;

  SalesBillStoredModel({
    this.status,
    this.message,
    this.salesBillId,
    this.pdfUrl,
    this.whatsappUrl,
    this.totalAmount,
    this.mailSent,
  });

  SalesBillStoredModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    final data = json['data'];
    if (data != null) {
      salesBillId = data['sales_bill_id'];
      pdfUrl = data['pdf_url'];
      whatsappUrl = data['whatsapp_url'];
      totalAmount = data['total_amount'];
      mailSent = data['mail_sent'];
    }
  }
}
