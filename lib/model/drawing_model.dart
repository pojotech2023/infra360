
class DrawingModel {
  bool? status;
  String? message;
  int? siteId;
  List<DrawingData>? data;

  DrawingModel({this.status, this.message, this.siteId, this.data});

  DrawingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    siteId = json['site_id'];
    if (json['data'] != null) {
      data = <DrawingData>[];
      json['data'].forEach((v) {
        data!.add(new DrawingData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['site_id'] = this.siteId;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DrawingData {
  int? drawingId;
  String? drawingName;
  String? drawingViewUrl;
  String? drawingDownloadUrl;

  DrawingData(
      {this.drawingId,
        this.drawingName,
        this.drawingViewUrl,
        this.drawingDownloadUrl});

  DrawingData.fromJson(Map<String, dynamic> json) {
    drawingId = json['drawing_id'];
    drawingName = json['drawing_name'];
    drawingViewUrl = json['drawing_view_url'];
    drawingDownloadUrl = json['drawing_download_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['drawing_id'] = this.drawingId;
    data['drawing_name'] = this.drawingName;
    data['drawing_view_url'] = this.drawingViewUrl;
    data['drawing_download_url'] = this.drawingDownloadUrl;
    return data;
  }
}
