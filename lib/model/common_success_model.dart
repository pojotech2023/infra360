class CommonSuccessResponseModel {
  int? responseCode;
  dynamic? status;
  String? message;

  CommonSuccessResponseModel({this.responseCode, this.status, this.message});

  CommonSuccessResponseModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response code'];
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['response code'] = responseCode;
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}