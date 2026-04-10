class AttendanceListModel {
  String? siteName;
  String? siteId;
  String? month;
  String? week;
  String? date;
  int? totalWeeks;
  List<WeekDays>? weekDays;
  List<Attendances>? attendances;
  Wage? wage;
  CategoryWages? categoryWages;
  int? totalWages;


  AttendanceListModel(
      {this.siteName,
        this.siteId,
        this.month,
        this.week,
        this.date,
        this.totalWeeks,
        this.weekDays,
        this.attendances,
        this.wage,
        this.categoryWages,
        this.totalWages,
      });

  AttendanceListModel.fromJson(Map<String, dynamic> json) {
    siteName = json['site_name'];
    siteId = json['site_id'];
    month = json['month'];
    week = json['week'];
    date = json['date'];
    totalWeeks = json['total_weeks'];
    if (json['week_days'] != null) {
      weekDays = <WeekDays>[];
      json['week_days'].forEach((v) {
        weekDays!.add(new WeekDays.fromJson(v));
      });
    }
    if (json['attendances'] != null && json['attendances'].isNotEmpty) {
      attendances = <Attendances>[];
      json['attendances'].forEach((v) {
        attendances!.add(new Attendances.fromJson(v));
      });
    }
    else{
      attendances=[];
    }
    wage = json['wage'] != null ? new Wage.fromJson(json['wage']) : null;
    categoryWages = json['category_wages'] != null && json['category_wages'].isNotEmpty
        ?  CategoryWages.fromJson(json['category_wages'])
        : null;
    totalWages = json['total_wages'];


  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['site_name'] = this.siteName;
    data['site_id'] = this.siteId;
    data['month'] = this.month;
    data['week'] = this.week;
    data['date'] = this.date;
    data['total_weeks'] = this.totalWeeks;
    if (this.weekDays != null) {
      data['week_days'] = this.weekDays!.map((v) => v.toJson()).toList();
    }
    if (this.attendances != null) {
      data['attendances'] = this.attendances!.map((v) => v.toJson()).toList();
    }
    if (this.categoryWages != null) {
      data['category_wages'] = this.categoryWages!.toJson();
    }
    data['total_wages'] = this.totalWages;

    return data;
  }
}

class WeekDays {
  String? label;
  String? value;

  WeekDays({this.label, this.value});

  WeekDays.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['value'] = this.value;
    return data;
  }
}

class Attendances {
  int? id;
  int? siteId;
  String? category;
  double? amount;
  int? count;
  String? date;
  String? createdAt;
  String? updatedAt;

  Attendances(
      {this.id,
        this.siteId,
        this.category,
        this.count,
        this.amount,
        this.date,
        this.createdAt,
        this.updatedAt});

  Attendances.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteId = json['site_id'];
    category = json['category'];
    count = json['count'];
    amount = json['amount'];
    date = json['date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['site_id'] = this.siteId;
    data['category'] = this.category;
    data['amount'] = this.amount;
    data['count'] = this.count;
    data['date'] = this.date;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}



class CategoryWages {
  int? mason;
  int? helper;
  int? fitter;
  int? centringHelper;

  CategoryWages({this.mason, this.helper, this.fitter, this.centringHelper});

  CategoryWages.fromJson(Map<String, dynamic> json) {
    mason = json['mason'];
    helper = json['helper'];
    fitter = json['fitter'];
    centringHelper = json['centring_helper'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mason'] = this.mason;
    data['helper'] = this.helper;
    data['fitter'] = this.fitter;
    data['centring_helper'] = this.centringHelper;
    return data;
  }
}

class Wage {
  String? centringHelper;
  String? fitter;
  String? helper;
  String? mason;

  Wage({this.centringHelper, this.fitter, this.helper, this.mason});

  Wage.fromJson(Map<String, dynamic> json) {
    centringHelper = json['centring_helper'];
    fitter = json['fitter'];
    helper = json['helper'];
    mason = json['mason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['centring_helper'] = this.centringHelper;
    data['fitter'] = this.fitter;
    data['helper'] = this.helper;
    data['mason'] = this.mason;
    return data;
  }
}