class ErrorResponse {
  final int? responseCode;
  final bool? status;
  final String? message;

  ErrorResponse({
    this.responseCode,
    this.status,
    this.message,
  });

  // Factory constructor to create an instance from a JSON map
  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      responseCode: json['response code'],
      status: json['status'],
      message: json['message'],
    );
  }

  // Method to convert the object to a map (if needed for other operations)
  Map<String, dynamic> toJson() {
    return {
      'response code': responseCode,
      'status': status,
      'message': message,
    };
  }
}
