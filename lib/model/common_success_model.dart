class CommonSuccessResponseModel {
  int? responseCode;
  dynamic? status;
  bool? success;
  String? message;
  Map<String, dynamic>? data;

  int? httpStatusCode;

  CommonSuccessResponseModel({this.responseCode, this.status, this.success, this.message, this.data, this.httpStatusCode});

  CommonSuccessResponseModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    status = json['status'];
    success = json['success'];
    message = json['message'];
    data = json['data'] is Map ? json['data'] : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['response code'] = responseCode;
    data['status'] = status;
    data['success'] = success;
    data['message'] = message;
    data['httpStatusCode'] = httpStatusCode;
    return data;
  }

  bool get isSuccess {
    if (success == true) return true;
    if (status == 'success' || status == 'true' || status == true || status == 200) return true;
    if (responseCode == 200 || responseCode == 201) return true;
    return false;
  }
}