class ExcelAttendanceDownloadModel {
  bool? status;
  String? message;
  String? downloadUrl;

  ExcelAttendanceDownloadModel({this.status, this.message, this.downloadUrl});

  ExcelAttendanceDownloadModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    // API returns pdf_url at top level: {"pdf_url":"https://..."}
    downloadUrl = json['pdf_url']?.toString()
        ?? json['download_url']?.toString();
    // Fallback: nested under data{}
    if (downloadUrl == null && json['data'] != null && json['data'] is Map<String, dynamic>) {
      final d = json['data'] as Map<String, dynamic>;
      downloadUrl = d['pdf_url']?.toString() ?? d['download_url']?.toString();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    data['message'] = this.message;
    data['download_url'] = this.downloadUrl;
    return data;
  }
}
