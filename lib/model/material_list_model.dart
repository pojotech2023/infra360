class MaterialResponse {
  final int ?responseCode;
  final bool ?status;
  final String ?message;
  final Map<String, MaterialItem> ?data;
  final List<MaterialType>? materialTypes;
  final List<String>? hiddenMaterials;
  final int? totalUnits;
  final int? totalValues;

  MaterialResponse({
     this.responseCode,
     this.status,
     this.message,
     this.data,
     this.materialTypes,
     this.hiddenMaterials,
     this.totalUnits,
     this.totalValues,
  });

  factory MaterialResponse.fromJson(Map<String, dynamic> json) {
    print("Keys in MaterialResponse: ${json.keys}");
    final materials = <String, MaterialItem>{};

    if (json['data'] is Map<String, dynamic>) {
      json['data'].forEach((key, value) {
        if (value is Map<String, dynamic>) {
          materials[key] = MaterialItem.fromJson(value);
        } else if (value is Map) {
          materials[key] = MaterialItem.fromJson(Map<String, dynamic>.from(value));
        }
      });
    }

    List<MaterialType> types = [];
    if (json['material_types'] is List) {
      types = (json['material_types'] as List)
          .map((e) => MaterialType.fromJson(e))
          .toList();
    } else if (json['material_types'] is Map<String, dynamic>) {
      json['material_types'].forEach((key, value) {
        types.add(MaterialType.fromJson(value));
      });
    }

    List<String>? hiddenMaterials;
    if (json['hidden_materials'] != null && json['hidden_materials'] is List) {
      hiddenMaterials = (json['hidden_materials'] as List).map((e) => e.toString().toLowerCase()).toList();
    } else if (json['hidden_material_types'] != null && json['hidden_material_types'] is List) {
      hiddenMaterials = (json['hidden_material_types'] as List).map((e) => e.toString().toLowerCase()).toList();
    }

    int? parsedTotalUnits;
    if (json['total_units'] != null) {
      parsedTotalUnits = int.tryParse(json['total_units'].toString()) ?? (json['total_units'] is num ? (json['total_units'] as num).toInt() : null);
    } else if (json['total_quantity'] != null) {
      parsedTotalUnits = int.tryParse(json['total_quantity'].toString()) ?? (json['total_quantity'] is num ? (json['total_quantity'] as num).toInt() : null);
    } else if (json['total_qty'] != null) {
      parsedTotalUnits = int.tryParse(json['total_qty'].toString()) ?? (json['total_qty'] is num ? (json['total_qty'] as num).toInt() : null);
    }

    int? parsedTotalValues;
    if (json['total_values'] != null) {
      parsedTotalValues = int.tryParse(json['total_values'].toString()) ?? (json['total_values'] is num ? (json['total_values'] as num).toInt() : null);
    } else if (json['total_amount'] != null) {
      parsedTotalValues = int.tryParse(json['total_amount'].toString()) ?? (json['total_amount'] is num ? (json['total_amount'] as num).toInt() : null);
    } else if (json['total_price'] != null) {
      parsedTotalValues = int.tryParse(json['total_price'].toString()) ?? (json['total_price'] is num ? (json['total_price'] as num).toInt() : null);
    }

    return MaterialResponse(
      responseCode: json['response code'],
      status: json['status'],
      message: json['message'],
      data: materials,
      materialTypes: types,
      hiddenMaterials: hiddenMaterials,
      totalUnits: parsedTotalUnits,
      totalValues: parsedTotalValues,
    );
  }

  Map<String, dynamic> toJson() {
    final dataMap = <String, dynamic>{};
    data==null?{}: data!.forEach((key, value) {
      dataMap[key] = value.toJson();
    });

    return {
      'response code': responseCode,
      'status': status,
      'message': message,
      'data': dataMap,
    };
  }
}
class MaterialItem {
  final int? id;
  final String? name;
  final String? slug;
  final String? imageUrl;
  final int units;
  final int values;

  MaterialItem({
    this.id,
    this.name,
    this.slug,
    this.imageUrl,
    required this.units,
    required this.values,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'],
      name: json['name']?.toString(),
      slug: json['slug']?.toString(),
      imageUrl: (json['image_url'] ?? json['image'] ?? json['imageUrl'])?.toString(),
      units: int.tryParse(json['units']?.toString() ?? '0') ?? (json['units'] is num ? (json['units'] as num).toInt() : 0),
      values: int.tryParse(json['values']?.toString() ?? (json['amount']?.toString() ?? '0')) ?? (json['values'] is num ? (json['values'] as num).toInt() : 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'image_url': imageUrl,
      'units': units,
      'values': values,
    };
  }
}

class MaterialType {
  final int? id;
  final String name;
  final String slug;
  final String imageUrl;

  MaterialType({
    this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
  });

  factory MaterialType.fromJson(Map<String, dynamic> json) {
    return MaterialType(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      imageUrl: (json['image_url'] ?? json['image'] ?? json['imageUrl'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'image_url': imageUrl,
    };
  }
}
