import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/model/login_response.dart';
import 'package:raptor_pro/model/material_details_argument_model.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/material_list_model.dart';
import 'package:raptor_pro/service/shared_preference_service.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/images.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/material_category/material_request/add_material_type_dialog.dart';
import 'package:raptor_pro/view/material_category/material_request/material_request_list_screen.dart';
import 'package:raptor_pro/view/material_category/other_material/others_material.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/toast.dart';

import 'package:raptor_pro/view/material_category/bricks_details_screen.dart';

import '../../../model/site_management_model.dart';
import 'material_details_controller.dart';

class MaterialDetailsScreen extends StatefulWidget {
  @override
  State<MaterialDetailsScreen> createState() => _MaterialDetailsScreenState();
}

class _MaterialDetailsScreenState extends State<MaterialDetailsScreen> {
  late final SiteManagementList siteManagementList;
  final controller = Get.put(MaterialDetailsController());

  String _role = '';

  @override
  void initState() {
    super.initState();
    siteManagementList = Get.arguments ?? 0;
    controller.init(siteManagementList.id ?? 0);

    // Determine current user role
    try {
      final data = jsonDecode(PreferenceUtils().getUserInfo());
      final userDetails = LoginResponse.fromJson(data);
      _role = userDetails.data?.role?.toLowerCase() ?? '';
      print("👤 [MaterialDetailsScreen] role=$_role");
    } catch (e) {
      print("❌ [MaterialDetailsScreen] Could not read role: $e");
    }
  }

  bool get _isAdmin => _role == 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: "Materials Details",
        onTap: () => Get.back(),
        actions: [
          // ── View Request button ──────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Get.to(
                  () => const MaterialRequestListScreen(),
                  arguments: {
                    'siteId': siteManagementList.id ?? 0,
                    'siteName': siteManagementList.siteName ?? '',
                  },
                );
              },
              icon: const Icon(Icons.list_alt, size: 12, color: Colors.white),
              label: const Text("View Request", style: TextStyle(fontSize: 10, color: Colors.white)),
            ),
          ),

          // ── Add Material button ──────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () async {
                final added = await showAddMaterialTypeDialog(context);
                if (added == true) {
                  controller.init(siteManagementList.id ?? 0);
                }
              },
              icon: const Icon(Icons.add, size: 12, color: Colors.white),
              label: const Text("Add Material", style: TextStyle(fontSize: 10, color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Obx(() {
                final materialList = controller.data.entries.toList();
                return GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: materialList.length,
                  itemBuilder: (context, index) {
                    final item = materialList[index];
                    return _buildMaterialCard(context, item.key, item.value);
                  },
                );
              }),

              InkWell(
                onTap: () {
                  Get.to(OtherMaterialScreen(), arguments: siteManagementList.id);
                },
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF084E9F), width: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SvgPicture.asset(Images.others),
                      Text("Others", style: AppTextStyle.textMedium.copyWith(fontSize: 20)),
                      Container(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single material grid card with the × delete button on top-right (admin only)
  Widget _buildMaterialCard(BuildContext context, String key, dynamic value) {
    final String? imagePath = ConstantData.materialImages[key];
    final String? networkImageUrl = (value is MaterialItem && value.imageUrl != null && value.imageUrl!.isNotEmpty) ? value.imageUrl : null;
    
    print("📸 [_buildMaterialCard] key=$key, imagePath=$imagePath, networkImageUrl=$networkImageUrl, valueImageUrl=${value is MaterialItem ? value.imageUrl : null}");

    return Stack(
      children: [
        // ── Main card (tappable) ──────────────────────────────
        InkWell(
          onTap: () async {
            await Get.to(
              () => BricksDetailsScreen(),
              arguments: MaterialDetailsArgs(
                id: siteManagementList.id ?? 0,
                siteName: siteManagementList.siteName ?? '',
                siteLocation: siteManagementList.location ?? '',
                itemKey: key,
                itemData: value,
                supervisorId: siteManagementList.supervisor?.id.toString() ?? '',
                supervisorName: siteManagementList.supervisor?.name.toString() ?? '',
                supervisorMob: siteManagementList.supervisor?.mobileNo.toString() ?? '',
              ),
            );
            controller.init(siteManagementList.id ?? 0);
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border.all(color: AppColor.materialCategoryBorderColor, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(7),
                    color: AppColor.materialCategoryBGColor,
                    child: networkImageUrl != null
                        ? Image.network(
                            networkImageUrl,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.13,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                          )
                        : imagePath != null
                            ? Image.asset(
                                imagePath,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * 0.13,
                                fit: BoxFit.fitHeight,
                              )
                            : SizedBox(
                                height: MediaQuery.of(context).size.height * 0.13,
                                child: const Icon(Icons.category, size: 48, color: Colors.grey),
                              ),
                  ),
                ),
                VerticalSpacing.d10px(),
                Center(
                  child: Text(
                    capitalize(key),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.materialTitleText,
                  ),
                ),
                Center(
                  child: Text(
                    "Qnty - ${value.units}",
                    textAlign: TextAlign.center,
                    style: AppTextStyle.textMedium.copyWith(color: const Color(0xFF0B9F08), fontSize: 13),
                  ),
                ),
                Center(
                  child: Text(
                    "Values - ${value.values}",
                    textAlign: TextAlign.center,
                    style: AppTextStyle.textMedium.copyWith(color: const Color(0xFF0B9F08), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── × button ──────────
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _showConfirmRemoveDialog(context, key),
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
                child: const Center(
                  child: Text(
                    "×",
                    style: TextStyle(color: Colors.white, fontSize: 16, height: 1.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Shows the Confirm Remove dialog matching screenshot 4
  void _showConfirmRemoveDialog(BuildContext context, String materialKey) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Confirm Remove",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: const Icon(Icons.close, size: 20, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),

              // Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Are you sure you want to remove this card from the grid? This only hides the card; existing records remain and it can be brought back by an admin later.",
                  style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await _hideMaterialCard(materialKey);
                      },
                      child: const Text("Yes, Remove", style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.buttonBlue,
                        side: BorderSide(color: AppColor.buttonBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text("Cancel", style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _hideMaterialCard(String materialKey) async {
    print("🔍 [MaterialDetailsScreen] _hideMaterialCard: key=$materialKey");

    // Fetch the material item to check if it has a dynamic ID
    final materialItem = controller.data[materialKey];
    final int? dynamicId = materialItem?.id;

    if (dynamicId != null) {
      // Dynamic material -> DELETE /api/material-type-delete/{id}
      CommonSuccessResponseModel? res = await ApiData().deleteDynamicMaterialTypeApi(dynamicId);

      print("📥 [MaterialDetailsScreen] hideMaterialCard response: status=${res?.status}  message=${res?.message}");

      if (res != null && res.status == true) {
        showToastMessage(res.message ?? "Card removed from grid");
        controller.init(siteManagementList.id ?? 0);
      } else {
        showToastMessage(res?.message ?? "Failed to remove card. Check logs.");
        print("⚠️ [MaterialDetailsScreen] hideMaterialCard failed — raw response logged above");
      }
    } else {
      // Built-in material -> Hide it locally since backend support may vary
      controller.hideDefaultMaterial(materialKey);
      showToastMessage("Card removed from grid");
      controller.init(siteManagementList.id ?? 0);

      // Attempt backend hide silently
      final String slug = materialItem?.slug?.isNotEmpty == true ? materialItem!.slug! : materialKey.toLowerCase();
      ApiData().hideBuiltInMaterialTypeApi(slug).then((apiRes) {
        print("📥 [MaterialDetailsScreen] background hideBuiltIn response: status=${apiRes?.status}");
      }).catchError((e) {
        print("⚠️ [MaterialDetailsScreen] background hideBuiltIn error: $e");
      });
    }
  }
}

// ─── Helper ────────────────────────────────────────────────
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}