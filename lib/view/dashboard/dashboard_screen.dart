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
                                        UrlHelper.getFullImageUrl(siteManagementList.siteImg),
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
                                          "${siteManagementList.siteName}",
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

      floatingActionButton: Obx(() {
        bool canAdd = false;
        if (controller.profileRole.value.toLowerCase() == 'admin') {
          canAdd = true;
        } else {
          canAdd = controller.supervisorPermissions.value?.siteManagement?.addSite == 1;
        }
        return canAdd
            ? FloatingActionButton(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.add),
                onPressed: () => controller.checkSiteLimitAndNavigate(),
              )
            : Container();
      }),

      // ----------------- BODY -----------------
      body: SafeArea(
        child: GetBuilder<DashboardController>(
          builder: (controller) => controller.isLoading
              ? Center(child: CommonLoader())
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.init();
                  },
                  child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
              // ---------------- TABS ----------------
              Container(
                margin: EdgeInsets.only(bottom: 16),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: ['All', 'Ongoing', 'Completed'].map((tab) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.selectedTab.value = tab;
                          controller.update(); // Update the view if GetBuilder is used, but selectedTab is obs.
                        },
                        child: Obx(() {
                          bool isSelected = controller.selectedTab.value == tab;
                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blueAccent : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ---------------- DASHBOARD HEADER ----------------
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 20, top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Active Projects",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Manage and track your sites",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.15)),
                      ),
                      child: Text(
                        "${controller.filteredSiteList.length} Sites",
                        style: TextStyle(
                          color: Colors.blueAccent.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --------------- SITE LIST ----------------
              Builder(builder: (context) {
                bool canViewSiteList = true;
                if (controller.profileRole.value.toLowerCase() == 'supervisor') {
                  final perms = controller.supervisorPermissions.value;
                  if (perms != null) {
                    canViewSiteList = perms.siteManagement?.viewSite == 1 || controller.siteManagementList.isNotEmpty;
                  }
                }

                if (!canViewSiteList) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Text(
                        "You do not have permission to view sites.",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.filteredSiteList.length,
                  itemBuilder: (_, index) {
                    SiteManagementList site = controller.filteredSiteList[index];
                    return PremiumSiteCard(
                      site: site,
                      index: index,
                      controller: controller,
                    );
                  },
                );
              }),
              ],
            ),
          ),
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

  Widget _compactFinancialInfo(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.85),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _financialItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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

class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const StaggeredEntrance({Key? key, required this.child, required this.delayMs}) : super(key: key);

  @override
  _StaggeredEntranceState createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: _isVisible ? 1.0 : 0.0,
      curve: Curves.easeOut,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 600),
        offset: _isVisible ? Offset.zero : const Offset(0, 0.05),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class PremiumSiteCard extends StatefulWidget {
  final SiteManagementList site;
  final int index;
  final DashboardController controller;

  const PremiumSiteCard({
    Key? key,
    required this.site,
    required this.index,
    required this.controller,
  }) : super(key: key);

  @override
  State<PremiumSiteCard> createState() => _PremiumSiteCardState();
}

class _PremiumSiteCardState extends State<PremiumSiteCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.forward();
    _navigate();
  }

  void _onTapCancel() {
    _scaleController.forward();
  }

  void _navigate() {
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.to(() => MaterialCategoryScreen(), arguments: widget.site);
    });
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'ongoing':
        return Colors.blueAccent;
      case 'completed':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
      locale: 'en_IN',
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    double budget = double.tryParse(widget.site.value?.replaceAll(RegExp(r'[^\d.]'), '') ?? "0") ?? 0;
    double expense = double.tryParse(widget.site.expense?.replaceAll(RegExp(r'[^\d.]'), '') ?? "0") ?? 0;
    double balance = budget - expense;

    return StaggeredEntrance(
      delayMs: (widget.index * 100).clamp(0, 800), // Max 800ms delay
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleController,
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                )
              ],
              border: Border.all(
                color: Colors.grey.shade100,
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- IMAGE BANNER ---
                  Stack(
                    children: [
                      Image.network(
                        UrlHelper.getFullImageUrl(widget.site.siteImg),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.grey.shade200, Colors.grey.shade300],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(Icons.apartment_rounded, size: 48, color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                      // Smooth Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.85),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Status Badge
                      Positioned(
                        right: 16,
                        top: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _getStatusColor(widget.site.status).withOpacity(0.9),
                            boxShadow: [
                              BoxShadow(
                                color: _getStatusColor(widget.site.status).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.circle, color: Colors.white, size: 8),
                              const SizedBox(width: 6),
                              Text(
                                widget.site.status ?? "Unknown",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Site Title
                      Positioned(
                        left: 20,
                        bottom: 20,
                        right: 20,
                        child: Text(
                          widget.site.siteName ?? 'Unknown Site',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  // --- CONTENT SECTION ---
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer info
                        if (widget.site.customer != null && widget.site.customer!.isNotEmpty)
                          Row(
                            children: [
                              _buildMiniInfo(Icons.person_rounded, widget.site.customer!.first.name ?? "N/A", Colors.blueGrey),
                              const SizedBox(width: 16),
                              _buildMiniInfo(Icons.phone_rounded, widget.site.customer!.first.mobileNo ?? "N/A", Colors.blueGrey),
                            ],
                          ),
                        if (widget.site.customer != null && widget.site.customer!.isNotEmpty)
                          const SizedBox(height: 20),

                        // Financial Summary grid
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.pie_chart_rounded, size: 18, color: Colors.blueGrey.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Financial Overview",
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade800,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildFinStat(Icons.account_balance_wallet_rounded, "Contract Value", budget, Colors.teal)),
                                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                                  Expanded(child: _buildFinStat(Icons.trending_down_rounded, "Expenses", expense, Colors.deepOrange)),
                                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                                  Expanded(child: _buildFinStat(Icons.account_balance_rounded, "Balance", balance, Colors.deepPurple)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Action buttons (View Details)
                        Builder(builder: (context) {
                          bool canViewDetails = false;
                          if (widget.controller.profileRole.value.toLowerCase() == 'admin') {
                            canViewDetails = true;
                          } else {
                            final p = widget.controller.supervisorPermissions.value?.siteManagement;
                            canViewDetails = (p?.viewSite == 1);
                          }

                          if (!canViewDetails) return const SizedBox();

                          return GestureDetector(
                            onTap: () {
                              showCustomerDetailsBottomSheet(context, widget.site, widget.controller);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 18, color: Colors.blueAccent.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    "View Details",
                                    style: TextStyle(
                                      color: Colors.blueAccent.shade700,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildFinStat(IconData icon, String label, double amount, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color.withOpacity(0.8)),
            const SizedBox(width: 4),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: 13, // Slightly smaller to fit 3 columns nicely
            fontWeight: FontWeight.w800,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
