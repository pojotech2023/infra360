class CommonSuccessResponseModel {
  int? responseCode;
  dynamic? status;
  String? message;
  Map<String, dynamic>? data;

  CommonSuccessResponseModel({this.responseCode, this.status, this.message, this.data});

  CommonSuccessResponseModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    status = json['status'];
    message = json['message'];
    data = json['data'] is Map ? json['data'] : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['response code'] = responseCode;
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}