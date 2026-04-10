import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/subcontractor_list_model.dart';
import 'package:raptor_pro/utils/const_data.dart';

import '../../model/my_subcontractor_list_model.dart';
import '../../utils/res/images.dart';

class SubcontractorController extends GetxController {
  // Observable list of subcontractor items (title, image, amount)
  var subcontractors = <SubcontractorItem>[].obs;

  // Loading indicator
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> init(int siteId) async {
    try {
      isLoading(true);
      subcontractors.clear();

      // Call API
      SubcontractorResponse? response =
      await ApiData().subcontractorListApi(siteId);

      // API data map (key → SubcontractorData)
      final apiData = response?.data ?? {};

      // Loop through static list (ensures consistent order)
      for (var key in ConstantData.allSubcontractorKeys) {
        final normalizedKey = key.toLowerCase();
        final imagePath =
            ConstantData.allSubcontractorImages[normalizedKey] ?? Images.material;

        final totalAmount = apiData[normalizedKey]?.totalAmounts ?? 0;

        subcontractors.add(SubcontractorItem(
          title: key,
          image: imagePath,
          totalAmount: totalAmount,
        ));
      }
    } catch (e) {
      print("Error loading subcontractor data: $e");
    } finally {
      isLoading(false);
    }
  }
}

/// UI-ready data model
class SubcontractorItem {
  final String title;
  final String image;
  final num totalAmount;

  SubcontractorItem({
    required this.title,
    required this.image,
    required this.totalAmount,
  });
}
