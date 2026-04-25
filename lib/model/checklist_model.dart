

class CheckListModel {
  String? siteId;
  List<Checklists>? checklists;

  CheckListModel({this.siteId, this.checklists});

  CheckListModel.fromJson(Map<String, dynamic> json) {
    siteId = json['site_id'];
    if (json['checklists'] != null) {
      checklists = <Checklists>[];
      json['checklists'].forEach((v) {
        checklists!.add(new Checklists.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['site_id'] = this.siteId;
    if (this.checklists != null) {
      data['checklists'] = this.checklists!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Checklists {
  int? checklistId;
  String? stage;
  List<Tasks>? tasks;

  Checklists({this.checklistId, this.stage, this.tasks});

  Checklists.fromJson(Map<String, dynamic> json) {
    checklistId = json['checklist_id'];
    stage = json['stage'];
    if (json['tasks'] != null) {
      tasks = <Tasks>[];
      json['tasks'].forEach((v) {
        tasks!.add(new Tasks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['checklist_id'] = this.checklistId;
    data['stage'] = this.stage;
    if (this.tasks != null) {
      data['tasks'] = this.tasks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tasks {


  bool? canOpen;
  int? taskId;
  String? taskName;
  int? status;
  String? statusLabel;
  String? remarks;
  String? supervisorRemarks;
  String? adminRemarks;
  String? updateBy;
  String? image;
  String? video;
  List<String>? images;
  List<String>? videos;

  Tasks(
      {this.taskId,
        this.canOpen,
        this.taskName,
        this.status,
        this.updateBy,
        this.supervisorRemarks,
        this.adminRemarks,
        this.statusLabel,
        this.remarks,
        this.image,
        this.video,
        this.images,
        this.videos});

  Tasks.fromJson(Map<String, dynamic> json) {
    canOpen = json['canOpen'];
    taskId = json['task_id'];
    taskName = json['task_name'];
    updateBy = json['updated_by'];
    status = json['status'];
    statusLabel = json['status_label'];
    remarks = json['remarks'];
    adminRemarks = json['admin_remark'];
    supervisorRemarks = json['supervisor_remarks'];

    // Parse images
    if (json['images'] is List) {
      images = (json['images'] as List).map((e) => e.toString()).toList();
    } else if (json['image'] is List) {
      images = (json['image'] as List).map((e) => e.toString()).toList();
    } else if (json['image'] is String && (json['image'] as String).isNotEmpty) {
      images = (json['image'] as String).split(',');
    } else {
      images = [];
    }
    image = images!.isNotEmpty ? images![0] : json['image'];

    // Parse videos
    if (json['videos'] is List) {
      videos = (json['videos'] as List).map((e) => e.toString()).toList();
    } else if (json['video'] is List) {
      videos = (json['video'] as List).map((e) => e.toString()).toList();
    } else if (json['video'] is String && (json['video'] as String).isNotEmpty) {
      videos = (json['video'] as String).split(',');
    } else {
      videos = [];
    }
    video = videos!.isNotEmpty ? videos![0] : json['video'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['canOpen'] = this.canOpen;
    data['task_id'] = this.taskId;
    data['task_name'] = this.taskName;
    data['status'] = this.status;
    data['status_label'] = this.statusLabel;
    data['remarks'] = this.remarks;
    data['image'] = this.image;
    data['video'] = this.video;
    return data;
  }

  setStatus(int s){
    status = s;
  }
}
