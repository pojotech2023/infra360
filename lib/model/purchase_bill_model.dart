// Model for GET /api/purchase-bill-form/{siteId} response
class PurchaseBillFormModel {
  bool? status;
  String? message;
  PurchaseBillFormData? data;

  PurchaseBillFormModel({this.status, this.message, this.data});

  PurchaseBillFormModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? PurchaseBillFormData.fromJson(json['data']) : null;
  }
}

class PurchaseBillFormData {
  SiteInfo? site;
  List<VendorInfo>? vendors;

  PurchaseBillFormData({this.site, this.vendors});

  PurchaseBillFormData.fromJson(Map<String, dynamic> json) {
    site = json['site'] != null ? SiteInfo.fromJson(json['site']) : null;
    
    if (json['vendors'] != null) {
      if (json['vendors'] is List) {
        vendors = (json['vendors'] as List).map((v) => VendorInfo.fromJson(v)).toList();
      }
    } else if (json['vendor'] != null) {
      if (json['vendor'] is List) {
        vendors = (json['vendor'] as List).map((v) => VendorInfo.fromJson(v)).toList();
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

class VendorInfo {
  int? id;
  String? name;
  String? email;
  String? mobileNo;
  String? address;

  VendorInfo({this.id, this.name, this.email, this.mobileNo, this.address});

  VendorInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    mobileNo = json['mobile_no'] ?? json['mobile'];
    address = json['address'] ?? json['location'];
  }
}

// Model for POST /api/purchase-bill-add response
class PurchaseBillStoredModel {
  bool? status;
  String? message;
  int? purchaseBillId;
  String? pdfUrl;
  String? whatsappUrl;
  num? totalAmount;
  bool? mailSent;

  PurchaseBillStoredModel({
    this.status,
    this.message,
    this.purchaseBillId,
    this.pdfUrl,
    this.whatsappUrl,
    this.totalAmount,
    this.mailSent,
  });

  PurchaseBillStoredModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    final data = json['data'];
    if (data != null) {
      purchaseBillId = data['purchase_bill_id'] ?? data['id'];
      pdfUrl = data['pdf_url'];
      whatsappUrl = data['whatsapp_url'];
      totalAmount = data['total_amount'];
      mailSent = data['mail_sent'];
    }
  }
}

class PurchaseBillListModel {
  bool? status;
  String? message;
  List<PurchaseBillItemModel>? data;

  PurchaseBillListModel({this.status, this.message, this.data});

  PurchaseBillListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(PurchaseBillItemModel.fromJson(v));
      });
    }
  }
}

class PurchaseBillItemModel {
  int? id;
  String? vendorName;
  String? date;
  String? subject;
  dynamic totalAmount;
  String? pdfUrl;
  String? whatsappUrl;

  PurchaseBillItemModel({this.id, this.vendorName, this.date, this.subject, this.totalAmount, this.pdfUrl, this.whatsappUrl});

  PurchaseBillItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorName = json['vendor_name'] ?? json['name'];
    date = json['date'];
    subject = json['subject'];
    totalAmount = json['total_amount'];
    pdfUrl = json['pdf_url'];
    whatsappUrl = json['whatsapp_url'];
  }
}

class PurchaseBillDetailModel {
  bool? status;
  String? message;
  PurchaseBillDetailData? data;

  PurchaseBillDetailModel({this.status, this.message, this.data});

  PurchaseBillDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? PurchaseBillDetailData.fromJson(json['data']) : null;
  }
}

class PurchaseBillDetailData {
  int? id;
  int? siteId;
  String? name;
  String? mobileNo;
  String? email;
  String? date;
  String? subject;
  String? location;
  String? termsConditions;
  List<PurchaseBillParticular>? particulars;

  PurchaseBillDetailData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteId = json['site_id'];
    name = json['name'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    date = json['date'];
    subject = json['subject'];
    location = json['location'];
    termsConditions = json['terms_conditions'] ?? json['terms_and_conditions'];
    
    if (json['particulars'] != null) {
      particulars = [];
      json['particulars'].forEach((v) {
        particulars!.add(PurchaseBillParticular.fromJson(v));
      });
    }
  }
}

class PurchaseBillParticular {
  int? id;
  String? particular;
  String? count;
  String? amount;

  PurchaseBillParticular.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    particular = json['particular'];
    count = json['count'].toString();
    amount = json['amount'].toString();
  }
}
