class VendorMaterialOrdersModel {
  bool? status;
  VendorMaterialOrdersData? data;

  VendorMaterialOrdersModel({this.status, this.data});

  VendorMaterialOrdersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? VendorMaterialOrdersData.fromJson(json['data']) : null;
  }
}

class VendorMaterialOrdersData {
  String? totalUnits;
  String? totalAmount;
  String? vendorName;
  String? materialType;
  List<VendorMaterialOrder>? orders;

  VendorMaterialOrdersData(
      {this.totalUnits,
      this.totalAmount,
      this.vendorName,
      this.materialType,
      this.orders});

  VendorMaterialOrdersData.fromJson(Map<String, dynamic> json) {
    totalUnits = json['total_units']?.toString() ?? json['totalUnits']?.toString();
    totalAmount = json['total_amount']?.toString() ?? json['totalAmount']?.toString();
    vendorName = json['vendor_name']?.toString() ?? json['vendorName']?.toString();
    materialType = json['material_type']?.toString() ?? json['materialType']?.toString();
    if (json['orders'] != null) {
      orders = <VendorMaterialOrder>[];
      json['orders'].forEach((v) {
        orders!.add(VendorMaterialOrder.fromJson(v));
      });
    } else if (json['data'] != null && json['data'] is List) { // fallback
       orders = <VendorMaterialOrder>[];
      json['data'].forEach((v) {
        orders!.add(VendorMaterialOrder.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['total_units'] = totalUnits;
    data['total_amount'] = totalAmount;
    data['vendor_name'] = vendorName;
    data['material_type'] = materialType;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VendorMaterialOrder {
  String? id;
  String? date;
  String? siteName;
  String? quantity;
  String? amount;

  VendorMaterialOrder(
      {this.id, this.date, this.siteName, this.quantity, this.amount});

  VendorMaterialOrder.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    date = json['date']?.toString();
    siteName = json['site_name']?.toString() ?? json['siteName']?.toString();
    quantity = json['quantity']?.toString();
    amount = json['amount']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['date'] = date;
    data['site_name'] = siteName;
    data['quantity'] = quantity;
    data['amount'] = amount;
    return data;
  }
}
