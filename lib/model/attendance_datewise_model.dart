class AttendanceDatewiseModel {
  bool? status;
  String? siteId;
  String? date;
  Data? data;
  List<String>? categories;
  int? totalWages;

  AttendanceDatewiseModel(
      {this.status,
        this.siteId,
        this.date,
        this.data,
        this.categories,
        this.totalWages});

  AttendanceDatewiseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    siteId = json['site_id'];
    date = json['date'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    categories = json['categories'].cast<String>();
    totalWages = json['total_wages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['site_id'] = this.siteId;
    data['date'] = this.date;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
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
        this.masonWage});

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
    return data;
  }
}
