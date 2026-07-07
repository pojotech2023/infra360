class ExcelAttendanceDownloadModel {
  bool? status;
  String? message;
  String? downloadUrl;

  ExcelAttendanceDownloadModel({this.status, this.message, this.downloadUrl});

  ExcelAttendanceDownloadModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    downloadUrl = json['download_url'];
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      downloadUrl = downloadUrl ?? json['data']['pdf_url']?.toString() ?? json['data']['download_url']?.toString();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['download_url'] = this.downloadUrl;
    return data;
  }
}
