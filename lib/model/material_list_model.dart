class MaterialResponse {
  final int ?responseCode;
  final bool ?status;
  final String ?message;
  final Map<String, MaterialItem> ?data;
  final List<MaterialType>? materialTypes;

  MaterialResponse({
     this.responseCode,
     this.status,
     this.message,
     this.data,
     this.materialTypes,
  });

  factory MaterialResponse.fromJson(Map<String, dynamic> json) {
    final materials = <String, MaterialItem>{};

    if (json['data'] is Map<String, dynamic>) {
      json['data'].forEach((key, value) {
        materials[key] = MaterialItem.fromJson(value);
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

    return MaterialResponse(
      responseCode: json['response code'],
      status: json['status'],
      message: json['message'],
      data: materials,
      materialTypes: types,
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
      units: json['units'] ?? 0,
      values: json['values'] ?? 0,
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
