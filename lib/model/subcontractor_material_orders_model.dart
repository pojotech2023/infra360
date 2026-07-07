class SubcontractorMaterialOrdersModel {
  bool? status;
  SubcontractorMaterialOrdersData? data;

  SubcontractorMaterialOrdersModel({this.status, this.data});

  SubcontractorMaterialOrdersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? SubcontractorMaterialOrdersData.fromJson(json['data']) : null;
  }
}

class SubcontractorMaterialOrdersData {
  String? totalUnits;
  String? totalAmount;
  String? subcontractorName;
  String? materialType;
  List<SubcontractorMaterialOrder>? orders;

  SubcontractorMaterialOrdersData(
      {this.totalUnits,
      this.totalAmount,
      this.subcontractorName,
      this.materialType,
      this.orders});

  SubcontractorMaterialOrdersData.fromJson(Map<String, dynamic> json) {
    print("SubcontractorMaterialOrdersData.fromJson keys: ${json.keys.toList()}");
    print("SubcontractorMaterialOrdersData.fromJson raw: $json");
    totalUnits = json['total_units']?.toString() ?? json['total_counts']?.toString() ?? json['totalUnits']?.toString() ?? json['totalCounts']?.toString();
    totalAmount = json['total_amount']?.toString() ?? json['totalAmount']?.toString();
    subcontractorName = json['subcontractor_name']?.toString() ?? json['subcontractorName']?.toString();
    materialType = json['material_type']?.toString() ?? json['materialType']?.toString();
    if (json['orders'] != null) {
      orders = <SubcontractorMaterialOrder>[];
      json['orders'].forEach((v) {
        orders!.add(SubcontractorMaterialOrder.fromJson(v));
      });
    } else if (json['data'] != null && json['data'] is List) {
      orders = <SubcontractorMaterialOrder>[];
      json['data'].forEach((v) {
        orders!.add(SubcontractorMaterialOrder.fromJson(v));
      });
    }
    print("Parsed totalUnits=$totalUnits, totalAmount=$totalAmount, ordersCount=${orders?.length}");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['total_units'] = totalUnits;
    data['total_amount'] = totalAmount;
    data['subcontractor_name'] = subcontractorName;
    data['material_type'] = materialType;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubcontractorMaterialOrder {
  String? id;
  String? date;
  String? siteName;
  String? quantity;
  String? amount;
  String? gst;

  SubcontractorMaterialOrder(
      {this.id, this.date, this.siteName, this.quantity, this.amount, this.gst});

  SubcontractorMaterialOrder.fromJson(Map<String, dynamic> json) {
    print("SubcontractorMaterialOrder.fromJson keys: ${json.keys.toList()}, raw: $json");
    id = json['id']?.toString();
    date = json['date']?.toString();
    siteName = json['site_name']?.toString() ?? json['siteName']?.toString();
    // Try all possible field names the backend might use for quantity/count
    quantity = json['no_counts']?.toString()
        ?? json['count']?.toString() 
        ?? json['counts']?.toString()
        ?? json['quantity']?.toString()
        ?? json['units']?.toString()
        ?? '0';
    amount = json['amount']?.toString();
    gst = json['gst']?.toString() ?? '0';
    print("Parsed order: siteName=$siteName, quantity=$quantity, amount=$amount, gst=$gst");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['date'] = date;
    data['site_name'] = siteName;
    data['quantity'] = quantity;
    data['amount'] = amount;
    data['gst'] = gst;
    return data;
  }
}
