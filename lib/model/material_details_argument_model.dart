import 'material_list_model.dart';

class MaterialDetailsArgs {
  final int id;
  final String siteName;
  final String siteLocation;
  final String itemKey;
  final MaterialItem itemData;
  final String supervisorId;
  final String supervisorName;
  final String supervisorMob;


  MaterialDetailsArgs({
    required this.id,
    required this.siteName,
    required this.siteLocation,
    required this.itemKey,
    required this.itemData,
    required this.supervisorId,
    required this.supervisorName,
    required this.supervisorMob
  });
}




class SubcontracorDetailsArgs {
  final int id;
  final String siteName;
  final String itemKey;


  SubcontracorDetailsArgs({
    required this.id,
    required this.siteName,
    required this.itemKey,

  });
}