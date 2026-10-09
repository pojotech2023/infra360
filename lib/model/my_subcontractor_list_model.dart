class SubcontractorResponse {
  final Map<String, SubcontractorData> data;
  final List<SubcontractorType>? subcontractorTypes;

  SubcontractorResponse({required this.data, this.subcontractorTypes});

  factory SubcontractorResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, SubcontractorData> parsedData = {};
    if (json['data'] != null) {
      (json['data'] as Map<String, dynamic>).forEach((key, value) {
        parsedData[key.toLowerCase()] = SubcontractorData.fromJson(value);
      });
    }

    List<SubcontractorType> types = [];
    if (json['subcontractor_types'] is List) {
      types = (json['subcontractor_types'] as List)
          .map((e) => SubcontractorType.fromJson(e))
          .toList();
    } else if (json['subcontractor_types'] is Map<String, dynamic>) {
      json['subcontractor_types'].forEach((key, value) {
        types.add(SubcontractorType.fromJson(value));
      });
    }

    return SubcontractorResponse(
      data: parsedData,
      subcontractorTypes: types,
    );
  }
}

class SubcontractorData {
  final num totalAmounts;
  final String? imageUrl;

  SubcontractorData({required this.totalAmounts, this.imageUrl});

  factory SubcontractorData.fromJson(Map<String, dynamic> json) {
    return SubcontractorData(
      totalAmounts: json['totalAmounts'] ?? json['total_amount'] ?? json['total_wages'] ?? 0,
      imageUrl: (json['image_url'] ?? json['image'] ?? json['imageUrl'])?.toString(),
    );
  }
}

class SubcontractorType {
  final int? id;
  final String name;
  final String slug;
  final String imageUrl;

  SubcontractorType({
    this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
  });

  factory SubcontractorType.fromJson(Map<String, dynamic> json) {
    return SubcontractorType(
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
