import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/material_list_model.dart';
import 'package:raptor_pro/utils/const_data.dart';

class MaterialDetailsController extends GetxController{

  var data = <String, MaterialItem>{}.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }


  /*init(int sideId)async{

    MaterialResponse? materialModel = await ApiData().materialListApi(sideId);
    final materials = <String, MaterialItem>{};
    if (materialModel != null && materialModel.data!.isNotEmpty) {
      materials.addAll(materialModel.data!);
    }
    for (var key in ConstantData.allMaterialKeys) {
      materials.putIfAbsent(key, () => MaterialItem(units: 0, values: 0));
    }

    data.value = materials;
  }*/


   init(int siteId) async {
    print("🚀 Initializing MaterialDetailsController for site: $siteId");
    /// 1) Call API
    MaterialResponse? materialModel = await ApiData().materialListApi(siteId);

    /// 2) Temporary map using LOWERCASE keys for safe merging
    final Map<String, MaterialItem> temp = {};

    // Load API data safely
    if (materialModel != null && materialModel.data != null) {
      materialModel.data!.forEach((key, value) {
        temp[key.toLowerCase()] = value;
      });
    }

    /// 3) Add missing required keys (bricks, sand, cement, RMC, gravel)
    for (var key in ConstantData.allMaterialKeys) {
      temp.putIfAbsent(key.toLowerCase(), () => MaterialItem(units: 0, values: 0));
    }

    /// 4) Rebuild final map using original casing (RMC stays uppercase)
    final Map<String, MaterialItem> finalMaterials = {};

    for (var key in ConstantData.allMaterialKeys) {
      finalMaterials[key] = temp[key.toLowerCase()]!;
    }


    data.value = finalMaterials;

  }

}

