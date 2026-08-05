class BricksModel {
  String? siteId;
  String? siteName;
  List<BricksList>? bricks;
  int? totalUnits;
  int? totalAmount;
  int? settledAmount;
  int? pendingAmount;

  BricksModel(
      {this.siteId,
        this.siteName,
        this.bricks,
        this.totalUnits,
        this.totalAmount,
        this.settledAmount,
        this.pendingAmount});

  BricksModel.fromJson(Map<String, dynamic> json) {
    siteId = json['siteId']?.toString() ?? json['site_id']?.toString();
    siteName = json['siteName'] ?? json['site_name'];
    
    // Aggressively check multiple possible keys for the bricks/records list
    dynamic bricksData = json['materials'] ?? json['bricks'] ?? json['bricks_list'] ?? json['data'] ?? 
                        json['material_list'] ?? json['material_details'] ?? json['bricks_overview'];
    
    // If 'data' was a map, look inside it for the list
    if (bricksData is Map) {
      final nestedList = bricksData['materials'] ?? bricksData['bricks'] ?? bricksData['bricks_list'] ?? bricksData['data'] ?? bricksData['material_list'];
      if (nestedList != null) {
        bricksData = nestedList;
      }
    }

    if (bricksData != null) {
      bricks = <BricksList>[];
      if (bricksData is List) {
        bricksData.forEach((v) {
          bricks!.add(BricksList.fromJson(v));
        });
      } else if (bricksData is Map) {
        // Handle cases where PHP/Laravel returns an associative array instead of a list
        bricksData.forEach((key, v) {
          bricks!.add(BricksList.fromJson(v));
        });
      }
    }
    
    totalUnits = int.tryParse(json['totalUnits']?.toString() ?? json['total_units']?.toString() ?? '0');
    totalAmount = int.tryParse(json['totalAmount']?.toString() ?? json['total_amount']?.toString() ?? '0');
    settledAmount = int.tryParse(json['settledAmount']?.toString() ?? json['settled_amount']?.toString() ?? '0');
    pendingAmount = int.tryParse(json['pendingAmount']?.toString() ?? json['pending_amount']?.toString() ?? '0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['siteId'] = this.siteId;
    data['siteName'] = this.siteName;
    if (this.bricks != null) {
      data['bricks'] = this.bricks!.map((v) => v.toJson()).toList();
    }
    data['totalUnits'] = this.totalUnits;
    data['totalAmount'] = this.totalAmount;
    data['settledAmount'] = this.settledAmount;
    data['pendingAmount'] = this.pendingAmount;
    return data;
  }
}

class BricksList {
  int? id;
  int? siteId;
  int? vendorId;
  String? vendorName;
  String? materialType;
  String? date;
  String? quantity;
  String? unit;
  int? price;
  String? gst;
 // Null? availableUnitCount;
  dynamic status;
  String? createdAt;
  String? updatedAt;
  String? imageUrl;

  BricksList(
      {this.id,
        this.siteId,
        this.vendorId,
        this.vendorName,
        this.materialType,
        this.date,
        this.quantity,
        this.unit,
        this.price,
        this.gst,
        this.imageUrl,
       // this.availableUnitCount,
        this.status,
        this.createdAt,
        this.updatedAt});

  BricksList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteId = json['site_id'] ?? json['siteId'];
    vendorId = json['vendor_id']?.toInt();
    
    // Vendor handling: check for nested object or flat field
    if (json['vendor'] != null && json['vendor'] is Map) {
      vendorName = json['vendor']['name'];
      vendorId = json['vendor']['id']?.toInt();
    } else {
      vendorName = json['vendor_name'] ?? json['vendorName'] ?? json['vendor']?.toString();
    }
    
    materialType = json['material_type'] ?? json['materialType'];
    date = json['date'];
    quantity = json['quantity']?.toString() ?? json['qty']?.toString();
    unit = json['unit'];
    price = json['price'] != null ? double.tryParse(json['price'].toString())?.toInt() : json['amount'] != null ? double.tryParse(json['amount'].toString())?.toInt() : null;
    gst = json['gst']?.toString();
    imageUrl = (json['image_url'] ?? json['image'] ?? json['imageUrl'])?.toString();
    print("🧱 BRICKS JSON: $json");
    status = json['status'] ?? json['approval_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['id'] = id;
    data['site_id'] = siteId;
    data['vendor_id'] = vendorId;
    data['vendor_name'] = vendorName;
    data['material_type'] = materialType;
    data['date'] = date;
    data['quantity'] = quantity;
    data['unit'] = unit;
    data['price'] = price;
    data['gst'] = gst;
    //data['available_unit_count'] = this.availableUnitCount;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}