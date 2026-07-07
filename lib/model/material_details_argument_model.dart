import 'material_list_model.dart';
import 'package:raptor_pro/model/subcontractor_amount_model.dart';
import 'package:raptor_pro/model/bricks_model.dart';

class MaterialDetailsArgs {
  final int id;
  final String siteName;
  final String siteLocation;
  final String itemKey;
  final MaterialItem itemData;
  final String supervisorId;
  final String supervisorName;
  final String supervisorMob;
  final BricksList? editItem;

  MaterialDetailsArgs({
    required this.id,
    required this.siteName,
    required this.siteLocation,
    required this.itemKey,
    required this.itemData,
    required this.supervisorId,
    required this.supervisorName,
    required this.supervisorMob,
    this.editItem,
  });
}

class SubcontracorDetailsArgs {
  final int id;
  final String siteName;
  final String itemKey;
  final Subcontractors? editServiceItem;

  SubcontracorDetailsArgs({
    required this.id,
    required this.siteName,
    required this.itemKey,
    this.editServiceItem,
  });
}