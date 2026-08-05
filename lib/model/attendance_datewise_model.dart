class AttendanceDatewiseModel {
  bool? status;
  String? siteId;
  String? date;
  Data? data;
  List<Data>? dataList;
  List<String>? categories;
  int? totalWages;
  Map<String, dynamic>? dayPhotos;

  AttendanceDatewiseModel(
      {this.status,
        this.siteId,
        this.date,
        this.data,
        this.dataList,
        this.categories,
        this.dayPhotos,
        this.totalWages});
  AttendanceDatewiseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    siteId = json['site_id'];
    date = json['date'] ?? json['from_date'];
    
    if (json['data'] != null) {
      if (json['data'] is List) {
        dataList = (json['data'] as List).map((v) => Data.fromJson(v)).toList();
      } else if (json['data'] is Map<String, dynamic>) {
        data = Data.fromJson(json['data']);
      }
    }
    categories = json['categories']?.cast<String>();
    totalWages = json['total_wages'];
    if (json['day_photos'] != null) {
      if (json['day_photos'] is Map) {
        dayPhotos = Map<String, dynamic>.from(json['day_photos']);
      } else {
        dayPhotos = {};
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['site_id'] = this.siteId;
    data['date'] = this.date;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    } else if (this.dataList != null) {
      data['data'] = this.dataList!.map((v) => v.toJson()).toList();
    }
    data['categories'] = this.categories;
    data['total_wages'] = this.totalWages;
    return data;
  }
}

class Data {
  String? date;
  int? total;
  int? centringHelper;
  String? centringHelperWage;
  int? fitter;
  String? fitterWage;
  int? helper;
  String? helperWage;
  int? mason;
  String? masonWage;
  String? checkInTime;
  String? checkInPhoto;
  String? checkOutTime;
  String? checkOutPhoto;

  Data(
      {this.date,
        this.total,
        this.centringHelper,
        this.centringHelperWage,
        this.fitter,
        this.fitterWage,
        this.helper,
        this.helperWage,
        this.mason,
        this.masonWage,
        this.checkInTime,
        this.checkInPhoto,
        this.checkOutTime,
        this.checkOutPhoto});

  Data.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    total = json['total'];
    centringHelper = json['centring_helper'];
    centringHelperWage = json['centring_helper_wage'];
    fitter = json['fitter'];
    fitterWage = json['fitter_wage'];
    helper = json['helper'];
    helperWage = json['helper_wage'];
    mason = json['mason'];
    masonWage = json['mason_wage'];
    checkInTime = json['check_in_time'] ?? json['time'];
    checkInPhoto = json['check_in_photo'] ?? json['image_url'];
    checkOutTime = json['check_out_time'] ?? json['out_time'];
    checkOutPhoto = json['check_out_photo'] ?? json['out_image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['total'] = this.total;
    data['centring_helper'] = this.centringHelper;
    data['centring_helper_wage'] = this.centringHelperWage;
    data['fitter'] = this.fitter;
    data['fitter_wage'] = this.fitterWage;
    data['helper'] = this.helper;
    data['helper_wage'] = this.helperWage;
    data['mason'] = this.mason;
    data['mason_wage'] = this.masonWage;
    data['check_in_time'] = this.checkInTime;
    data['check_in_photo'] = this.checkInPhoto;
    data['check_out_time'] = this.checkOutTime;
    data['check_out_photo'] = this.checkOutPhoto;
    return data;
  }
}
