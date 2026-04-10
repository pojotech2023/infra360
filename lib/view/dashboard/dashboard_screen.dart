import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/utils/url_helper.dart';
import 'package:raptor_pro/model/site_management_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/images.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/dashboard/dashboard_controller.dart';
import 'package:raptor_pro/view/material_category/material_category_screen.dart';
import 'package:raptor_pro/view/site/site_add_screen.dart';

import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/view/widgets/log_out.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';


import 'bottom_sheets.dart';
import 'drawer_item.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  DashboardController controller = Get.put(DashboardController());

/*  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    // TODO: implement build
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Images.appLogo,
                width: 50,
                height: 50,
              ),
              SizedBox(
                width: 5,
              ),
              Image.asset(
                Images.appName,
                width: 130,
                height: 40,
              )
            ],
          ),
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: SvgPicture.asset(Images.menu),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: SvgPicture.asset(Images.notifications),
            ),
          ],
        ),
        drawer: DrawerWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(() => SiteAddScreen());
          },
          child: Icon(Icons.add),
        ),
        body: GetBuilder<DashboardController>(
          builder: (controller) => controller.isLoading
              ? Center(child: CommonLoader())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: controller.siteManagementList.length,
                        itemBuilder: (BuildContext context, int index) {
                          SiteManagementList siteManagementList =
                              controller.siteManagementList[index];
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Color(0xFFDCE1EF), width: 1)),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.to(() => MaterialCategoryScreen(),
                                        arguments: siteManagementList);
                                  },
                                  child: Stack(children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(14),
                                        topRight: Radius.circular(14),
                                      ),
                                      child: Image.network(
                                        Uri.encodeFull(
                                            "${imageUrl}/${siteManagementList.siteImg}"),
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.fitWidth,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                              width: double.infinity,
                                              height: 120,
                                              alignment: Alignment.center,
                                              color: Colors.grey[300],
                                              child: Text(
                                                "No Image Preview",
                                                style: AppTextStyle
                                                    .textRegularSmall,
                                              ));
                                        },
                                      ),
                                    ),
                                    Positioned(
                                        right: 10,
                                        top: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                siteManagementList.status),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            siteManagementList.status ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )),
                                  ]),
                                ),
                                VerticalSpacing.d5px(),
                                Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),
                                      Center(
                                        child: Text(
                                          "Site Name : ${siteManagementList.id}  -  ${siteManagementList.siteName}",
                                          style: AppTextStyle.textMedium,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          showCustomerDetailsBottomSheet(
                                              context,
                                              siteManagementList,
                                              controller);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 8.0),
                                          child:
                                          SvgPicture.asset(Images.info),
                                        ),
                                      )
                                    ]),
                                VerticalSpacing.d5px(),
                                Container(
                                  padding: EdgeInsets.only(left: 7, right: 7),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            subWidget("Duration",
                                                "${siteManagementList.duration}"),
                                            VerticalSpacing.d5px(),
                                            //
                                            // if ( controller.userDetails.data!.role!.toLowerCase() == 'admin') ...[
                                            //   subWidget("Settled Amount", "${siteManagementList.settledAmnt}"),
                                            //   VerticalSpacing.d5px(),
                                            //   subWidget("Expense", "${siteManagementList.expense ?? "N/A"}"),
                                            // ],
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            subWidget("Location",
                                                "${siteManagementList.location}"),
                                            VerticalSpacing.d5px(),
                                            // if ( controller.userDetails.data!.role!.toLowerCase() == 'admin') ...[
                                            //                     subWidget("Value", "${siteManagementList.value}"),
                                            //                     VerticalSpacing.d5px(),
                                            //                     subWidget("Pending Amount", "${siteManagementList.pendingAmnt}",
                                            //                         isArrowIcon: true),
                                            // ]
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                VerticalSpacing.d10px(),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Padding(padding: EdgeInsets.only(bottom: 10));
                        },
                      )
                    ],
                  ),
                ),
        ),
        );

  }*/


  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerWidget(),
      backgroundColor: Colors.grey[100],

      // ----------------- APP BAR -----------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: Row(
          children: [
            Image.asset(Images.appLogo, width: 40, height: 40),
            SizedBox(width: 8),
            Image.asset(Images.appName, width: 120),
          ],
        ),
        leading: IconButton(
          icon: SvgPicture.asset(Images.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: SvgPicture.asset(Images.notifications),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
        onPressed: () => controller.checkSiteLimitAndNavigate(),
      ),

      // ----------------- BODY -----------------
      body: GetBuilder<DashboardController>(
        builder: (controller) => controller.isLoading
            ? Center(child: CommonLoader())
            : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // ---------------- SEARCH BOX ----------------

              // --------------- SITE LIST ----------------
        ListView.builder(
          shrinkWrap: true,
          primary: false,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.siteManagementList.length,

          itemBuilder: (_, index) {
            SiteManagementList site = controller.siteManagementList[index];

            return Container(
              margin: EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: Colors.white.withOpacity(0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.08),
                    blurRadius: 22,
                    offset: Offset(0, 8),
                  )
                ],
                border: Border.all(
                  color: Colors.grey.shade300.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ---------------- Banner ----------------
                    InkWell(

                      onTap: () => Get.to(() => MaterialCategoryScreen(), arguments: site),
                      child:     Stack(
                        children: [
                          Image.network(
                            UrlHelper.getFullImageUrl(site.siteImg),
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 300,
                              color: Colors.grey.shade200,
                              child: Icon(Icons.image_not_supported, size: 40),
                            ),
                          ),

                          // Fade Overlay
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.0),
                                  Colors.black.withOpacity(0.45),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),

                          // Status Tag
                          Positioned(
                            right: 16,
                            top: 16,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: _getStatusColor(site.status).withOpacity(0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26.withOpacity(0.25),
                                    blurRadius: 8,
                                  )
                                ],
                              ),
                              child: Text(
                                site.status ?? "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  letterSpacing: .4,
                                ),
                              ),
                            ),
                          ),

                          // Title Bottom
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 32,
                              child: Text(
                                "${site.id} - ${site.siteName}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(blurRadius: 8, color: Colors.black45),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                            ),
                          )

                        ],
                      ),
                    ),

                    // ---------------- Content ----------------
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          _premiumInfo(Icons.timer_rounded,
                              site.duration ?? "N/A", Colors.blueAccent),

                          SizedBox(height: 8),

                          InkWell(
                            onTap: () => _openMap(site.location ?? ""),
                            child: _premiumInfo(
                              Icons.location_on_rounded,
                              site.location ?? "N/A",
                              Colors.redAccent,
                              isLink: true,
                            ),
                          ),

                          SizedBox(height: 8),

                          // ---------- Supervisor + Details Row ----------
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              // Left side
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _premiumInfo(
                                      Icons.person,
                                      site.supervisor?.name ?? "Supervisor N/A",
                                      Colors.deepPurpleAccent,
                                    ),
                                    SizedBox(height: 8),
                                    InkWell(
                                      onTap: () =>
                                          _callNumber(site.supervisor?.mobileNo ?? ""),
                                      child: _premiumInfo(
                                        Icons.call,
                                        site.supervisor?.mobileNo ?? "Phone N/A",
                                        Colors.green,
                                        isLink: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 12),

                              // Right side - Details button
                             InkWell(onTap: () {
                               showCustomerDetailsBottomSheet(
                                   context,
                                   site,
                                   controller);
                             },
                               child:  Container(
                                 padding:
                                 EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(14),
                                   gradient: LinearGradient(
                                     colors: [
                                       Colors.blueAccent.withOpacity(.2),
                                       Colors.blueAccent.withOpacity(.1),
                                     ],
                                   ),
                                 ),
                                 child: Row(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     Icon(Icons.info_outline,
                                         size: 18, color: Colors.blueAccent),
                                     SizedBox(width: 6),
                                     Text(
                                       "Details",
                                       style: TextStyle(
                                         color: Colors.blueAccent,
                                         fontWeight: FontWeight.w700,
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             )
                            ],
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );


          },
        )

        ],
          ),
        ),
      ),
    );
  }
  Widget _premiumInfo(IconData icon, String text, Color color,
      {bool isLink = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100.withOpacity(0.6),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: isLink ? color : Colors.black87,
              ),
            ),
          ),
          if (isLink)
            Icon(Icons.arrow_outward_rounded, color: color, size: 18),
        ],
      ),
    );
  }


  Widget subWidget(String title, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title : ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isLink ? Colors.blue : Colors.black87,
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }





  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'ongoing':
        return Colors.blue;
      case 'quoted':
        return Colors.red;
      default:
        return Colors.grey; // fallback color
    }
  }

  void openGoogleMap(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool isGoogleMapsLink(String value) {
    return value.startsWith("https") && value.contains("maps.app.goo.gl");
  }


  // Call dialer
  void _callNumber(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

// Open Google Maps Navigation
  void _openMap(String address) async {
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$address");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

}
