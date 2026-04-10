class SubcontractorResponse {
  final Map<String, SubcontractorData> data;

  SubcontractorResponse({required this.data});

  factory SubcontractorResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, SubcontractorData> parsedData = {};
    if (json['data'] != null) {
      (json['data'] as Map<String, dynamic>).forEach((key, value) {
        parsedData[key.toLowerCase()] = SubcontractorData.fromJson(value);
      });
    }
    return SubcontractorResponse(data: parsedData);
  }
}

class SubcontractorData {
  final num totalAmounts;

  SubcontractorData({required this.totalAmounts});

  factory SubcontractorData.fromJson(Map<String, dynamic> json) {
    return SubcontractorData(
      totalAmounts: json['totalAmounts'] ?? 0,
    );
  }
}
