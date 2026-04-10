import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/utils/url_helper.dart';
import 'package:raptor_pro/model/site_management_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/images.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/agents/agent_screen.dart';
import 'package:raptor_pro/view/customer/customer_list_screen.dart';
import 'package:raptor_pro/view/dashboard/dashboard_controller.dart';
import 'package:raptor_pro/view/material_category/material_category_screen.dart';
import 'package:raptor_pro/view/profile/profile_screen.dart';
import 'package:raptor_pro/view/properties_list/properties_list_screen.dart';
import 'package:raptor_pro/view/site/site_add_screen.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_dashboard/subcontractor_dashboard_controller.dart';
import 'package:raptor_pro/view/supervisor_management/supervisor_management_screen.dart';
import 'package:raptor_pro/view/vendor/vendor_main_screen.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/view/widgets/log_out.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/date_formate.dart';
import '../darwing/drawing_add_screen.dart';
import '../quotation/generate_quotation_controller.dart';
import '../quotation/generate_quotation_screen.dart';
import '../subcontractor/subcontractor_main_screen.dart';
import '../widgets/common_button.dart';

void showCustomerDetailsBottomSheet(BuildContext context,
    SiteManagementList siteManagementList, DashboardController controller) {
  final customerDetails = siteManagementList.customer?.first;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return FractionallySizedBox(
        heightFactor: 0.7, // bounded height -> no unbounded layout issues
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _sheetHandle(),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle('Site Details'),
                  Row(
                    children: [
                      SizedBox(
                          width: 100,
                          child: CommonButton(
                              onTap: () {
                                Navigator.pop(context);
                                Get.to(() => SiteAddScreen(
                                    siteData: siteManagementList));
                              },
                              customColor: Colors.blue,
                              text: "Edit")),
                      SizedBox(
                        width: 16,
                      ),
                      SizedBox(
                          width: 100,
                          child: CommonButton(
                              onTap: () {
                                Navigator.pop(context);
                                deleteDialog(context, () {
                                  controller
                                      .deleteSite(siteManagementList.id!);
                                });
                              },
                              customColor: Colors.red,
                              text: "Delete")),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),

              // Use Expanded ListView for the scrollable content
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  titleData(context, 'Site Name',
                                      siteManagementList.siteName ?? ''),
                                  titleData(context, 'Duration',
                                      siteManagementList.duration ?? ''),
                                  titleData(
                                    context,
                                    'Location',
                                    siteManagementList.location ?? '',
                                    onTap: isGoogleMapsLink(
                                        siteManagementList.location ?? '')
                                        ? () => openGoogleMap(
                                        siteManagementList.location!)
                                        : null,
                                  ),
                                ],
                              )),
                        ),
                        Image.network(
                          UrlHelper.getFullImageUrl(siteManagementList.siteImg),
                          width: 120,
                          height: 120,
                          fit: BoxFit.fitWidth,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                                width: 120,
                                height: 120,
                                alignment: Alignment.center,
                                color: Colors.grey[300],
                                child: Text(
                                  "No Image",
                                  style: AppTextStyle.textRegularSmall,
                                ));
                          },
                        ),
                      ],
                    ),
                    // Site details

                    Row(
                      children: [
                        Expanded(
                          child: titleData(context, 'Flat Area',
                              siteManagementList.flatArea ?? ''),
                        ),
                        Expanded(
                          child: titleData(context, 'Buildup Area',
                              siteManagementList.builtupArea ?? ''),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: titleData(context, 'Supervisor Name',
                              siteManagementList.supervisor?.name ?? ''),
                        ),
                        Expanded(
                          child: titleData(context, 'Supervisor Mob',
                              siteManagementList.supervisor?.mobileNo ?? ''),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    _sectionTitle('Customer Details'),
                    const SizedBox(height: 12),

                    if (customerDetails != null) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Provide a fixed-size image so layout is deterministic
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.asset(
                              Images.profile,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Flexible (not Expanded) so it can size to available width
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customerDetails.name ?? '-',
                                  style: AppTextStyle.textBold.copyWith(
                                    color: AppColor.textGreen,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  customerDetails.address ?? '-',
                                  style: AppTextStyle.customerDetailsStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Info cards row: each card has a fixed width so they get laid out properly
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width:
                            (MediaQuery.of(context).size.width - 64) / 2,
                            child: _infoCard(
                              Icons.calendar_today,
                              'DOB',
                              formatDate(customerDetails.dob),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width:
                            (MediaQuery.of(context).size.width - 64) / 2,
                            child: _infoCard(
                              Icons.phone,
                              'Mobile No',
                              customerDetails.mobileNo ?? '-',
                              onTap: () {
                                // optionally launch dialer
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Email card spans full width
                      _fullWidthInfoCard(
                        Icons.email,
                        'Email',
                        customerDetails.email ?? '-',
                      ),
                    ] else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('No customer details available'),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}




// small top handle for UX
Widget _sheetHandle() {
  return Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}

Widget _sectionTitle(String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: AppTextStyle.textBold.copyWith(color: AppColor.textGreen)),
      const SizedBox(height: 8),
      Container(
        width: 83,
        height: 5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColor.textGreen,
        ),
      ),
    ],
  );
}

// Info card used in half-width boxes (fixed width via parent SizedBox)
Widget _infoCard(IconData icon, String title, String value,
    {VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.teal),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              textAlign: TextAlign.center,
              style: AppTextStyle.customerDetailsStyle),
        ],
      ),
    ),
  );
}

// Full-width info card (used for email)
Widget _fullWidthInfoCard(IconData icon, String title, String value,
    {VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.teal),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              textAlign: TextAlign.center,
              style: AppTextStyle.customerDetailsStyle),
        ],
      ),
    ),
  );
}

Widget titleData(
    BuildContext context,
    String title,
    String value, {
      Function()? onTap,
    }) {
  return InkWell(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyle.customerDetailsStyle.copyWith(
            color: onTap != null ? Colors.blue : Colors.black,
            decoration: onTap != null ? TextDecoration.underline : null,
          ),
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}  void openGoogleMap(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

bool isGoogleMapsLink(String value) {
  return value.startsWith("https") && value.contains("maps.app.goo.gl");
}