import 'dart:convert';

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
  String? vendorMobile;
 // Null? availableUnitCount;
  dynamic status;
  String? createdAt;
  String? updatedAt;
  String? imageUrl;
  String? orderNo;
  String? category;
  String? specification;
  String? vendorGstin;
  double? pricePerItem;
  double? totalAmount;
  dynamic rawItems;

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
        this.orderNo,
        this.category,
        this.specification,
        this.vendorGstin,
        this.pricePerItem,
        this.totalAmount,
        this.rawItems,
       // this.availableUnitCount,
        this.status,
        this.createdAt,
        this.updatedAt});

  BricksList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteId = json['site_id'] ?? json['siteId'];
    vendorId = json['vendor_id']?.toInt();
    orderNo = (json['order_no'] ?? json['orderNo'] ?? json['order_id'])?.toString();
    
    // Vendor handling: check for nested object or flat field
    if (json['vendor'] != null && json['vendor'] is Map) {
      vendorName = json['vendor']['name'];
      vendorId = json['vendor']['id']?.toInt();
      vendorMobile = json['vendor']['mobile_no']?.toString();
      vendorGstin = json['vendor']['gst']?.toString() ?? json['vendor']['gstin']?.toString();
    } else {
      vendorName = json['vendor_name'] ?? json['vendorName'] ?? json['vendor']?.toString();
      vendorGstin = json['vendor_gstin']?.toString() ?? json['vendor_gst']?.toString() ?? json['gstin']?.toString();
    }
    
    materialType = json['material_type'] ?? json['materialType'];
    category = json['category'] ?? json['category_name'] ?? json['material_category'] ?? json['item_name'] ?? json['name'];
    specification = json['specification'] ?? json['spec'] ?? json['description'] ?? json['sub_type'] ?? json['details'];
    date = json['date'];
    quantity = json['quantity']?.toString() ?? json['qty']?.toString();
    unit = json['unit'];
    price = json['price'] != null ? double.tryParse(json['price'].toString())?.toInt() : json['amount'] != null ? double.tryParse(json['amount'].toString())?.toInt() : null;
    gst = json['gst']?.toString();
    
    // Price per item
    if (json['price_per_item'] != null) {
      pricePerItem = double.tryParse(json['price_per_item'].toString());
    } else if (json['unit_price'] != null) {
      pricePerItem = double.tryParse(json['unit_price'].toString());
    } else if (json['rate'] != null) {
      pricePerItem = double.tryParse(json['rate'].toString());
    } else if (price != null && quantity != null) {
      final q = double.tryParse(quantity!) ?? 1.0;
      pricePerItem = q > 0 ? (price! / q) : price!.toDouble();
    }

    // Total Amount
    if (json['total_amount'] != null) {
      totalAmount = double.tryParse(json['total_amount'].toString());
    } else if (json['amount'] != null) {
      totalAmount = double.tryParse(json['amount'].toString());
    } else if (price != null) {
      final gstVal = double.tryParse(gst ?? '0') ?? 0.0;
      totalAmount = price! + gstVal;
    }

    rawItems = json['items'] ?? json['order_items'];

    // Deep specification extraction if null, empty, or '-'
    if (specification == null || specification.toString().trim().isEmpty || specification == '-') {
      specification = (json['size'] ?? json['size_specification'] ?? json['size_spec'])?.toString();
    }
    if ((specification == null || specification.toString().trim().isEmpty || specification == '-') && rawItems != null) {
      try {
        dynamic parsed = rawItems;
        if (parsed is String && parsed.trim().isNotEmpty) {
          try {
            parsed = jsonDecode(parsed);
          } catch (_) {}
        }
        if (parsed is List && parsed.isNotEmpty) {
          for (var itemMap in parsed) {
            if (itemMap is Map) {
              final s = itemMap['specification'] ?? itemMap['spec'] ?? itemMap['size'] ?? itemMap['size_specification'] ?? itemMap['description'] ?? itemMap['sub_type'];
              if (s != null && s.toString().trim().isNotEmpty) {
                specification = s.toString().trim();
                break;
              }
              if ((category == null || category!.isEmpty) && (itemMap['name'] != null || itemMap['item_name'] != null)) {
                category = (itemMap['name'] ?? itemMap['item_name'] ?? itemMap['category'])?.toString();
              }
            }
          }
        } else if (parsed is Map) {
          final s = parsed['specification'] ?? parsed['spec'] ?? parsed['size'] ?? parsed['size_specification'] ?? parsed['description'];
          if (s != null && s.toString().trim().isNotEmpty) {
            specification = s.toString().trim();
          }
        }
      } catch (_) {}
    }
    // Deep fallback from items_summary, items string, item_name, or category
    if (specification == null || specification.toString().trim().isEmpty || specification == '-') {
      for (var candidate in [json['items_summary'], json['items'], json['item_name'], json['category']]) {
        if (candidate is String && candidate.contains('(') && candidate.contains(')')) {
          final reg = RegExp(r'\((.*?)\)');
          final match = reg.firstMatch(candidate);
          if (match != null && match.group(1) != null && match.group(1)!.trim().isNotEmpty) {
            specification = match.group(1)!.trim();
            break;
          }
        }
      }
    }
    imageUrl = (json['image_url'] ?? json['image'] ?? json['imageUrl'] ?? json['attachment'])?.toString();
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