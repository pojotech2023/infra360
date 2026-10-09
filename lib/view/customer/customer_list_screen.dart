import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/customer_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/view/customer/customer_list_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/view/widgets/log_out.dart';
import 'package:raptor_pro/view/dashboard/dashboard_controller.dart';

import 'customer_mangement_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final CustomerListController controller = Get.put(CustomerListController());
  final DashboardController dashboardController = Get.find<DashboardController>();

  bool canAdd() {
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.customerManagement?.addCustomer == 1;
  }
  
  bool canEdit() {
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.customerManagement?.editCustomer == 1;
  }

  bool canDelete() {
    if (dashboardController.profileRole.value.toLowerCase() == 'admin') return true;
    return dashboardController.supervisorPermissions.value?.customerManagement?.deleteCustomer == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Customer Management",
          onTap: () {
            Get.back();
          }),
      body: SafeArea(
        child: Obx(() {
          return controller.isLoading.value
              ? const Center(
                  child: CommonLoader(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: controller.customerData.length,
                          itemBuilder: (BuildContext context, int index) {
                            Customers customerData = controller.customerData[index];
                            String siteName = controller.getCustomerSiteName(customerData);

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              padding: EdgeInsets.zero,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment(-1.0, -0.8),
                                  end: Alignment(1.0, 0.8),
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFF5F7FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1565C0).withOpacity(0.12),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF1565C0).withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFE3E8F0),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header with avatar and actions
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF1565C0).withOpacity(0.05),
                                              const Color(0xFF42A5F5).withOpacity(0.02),
                                            ],
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Avatar
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFF1565C0),
                                                    Color(0xFF42A5F5),
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF1565C0).withOpacity(0.3),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  (customerData.name != null && customerData.name!.isNotEmpty
                                                      ? customerData.name!.substring(0, 1).toUpperCase()
                                                      : 'C'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Name, Site Name badge, & DOB badge
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    customerData.name ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w700,
                                                      color: Color(0xFF1A365D),
                                                      letterSpacing: 0.2,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 6,
                                                    children: [
                                                      if (siteName.isNotEmpty)
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF1565C0).withOpacity(0.12),
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(
                                                              color: const Color(0xFF1565C0).withOpacity(0.3),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(
                                                                Icons.apartment_rounded,
                                                                size: 13,
                                                                color: Color(0xFF1565C0),
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Flexible(
                                                                child: Text(
                                                                  siteName,
                                                                  style: const TextStyle(
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: Color(0xFF1565C0),
                                                                    letterSpacing: 0.2,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      if (customerData.dob != null && customerData.dob!.isNotEmpty)
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF42A5F5).withOpacity(0.12),
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(
                                                              color: const Color(0xFF42A5F5).withOpacity(0.3),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(
                                                                Icons.cake_rounded,
                                                                size: 13,
                                                                color: Color(0xFF1565C0),
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Flexible(
                                                                child: Text(
                                                                  customerData.dob ?? '',
                                                                  style: const TextStyle(
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: Color(0xFF1565C0),
                                                                    letterSpacing: 0.3,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Action buttons
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (canEdit())
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF42A5F5).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: InkWell(
                                                      onTap: () {
                                                        Get.to(() => CustomerMangementScreen(), arguments: customerData);
                                                      },
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(10),
                                                        child: Icon(
                                                          Icons.edit_rounded,
                                                          size: 20,
                                                          color: Color(0xFF1565C0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (canEdit() && canDelete()) const SizedBox(width: 8),
                                                if (canDelete())
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFEF5350).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: InkWell(
                                                      onTap: () {
                                                        deleteDialog(context, () {
                                                          controller.deleteCustomer(customerData.id!);
                                                        });
                                                      },
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(10),
                                                        child: Icon(
                                                          Icons.delete_rounded,
                                                          size: 20,
                                                          color: Color(0xFFD32F2F),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Details section
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Site Name row
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.apartment_rounded,
                                                  size: 18,
                                                  color: Color(0xFF1565C0),
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  "Site: ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF78909C),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    siteName.isNotEmpty ? siteName : 'N/A',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF1565C0),
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            // Contact info row
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.phone_rounded,
                                                  size: 18,
                                                  color: Color(0xFF78909C),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  customerData.mobileNo ?? 'N/A',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF455A64),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.email_rounded,
                                                  size: 18,
                                                  color: Color(0xFF78909C),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    customerData.email ?? 'N/A',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF455A64),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            // Address info row
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                  Icons.location_on_rounded,
                                                  size: 18,
                                                  color: Color(0xFF78909C),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    customerData.address != null && customerData.address!.isNotEmpty
                                                        ? customerData.address!
                                                        : 'N/A',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF455A64),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
                    ],
                  ),
                );
        }),
      ),
    );
  }

  Widget textWidget(String title, String value) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyle.textMedium.copyWith(fontSize: 15),
        ),
        Text(
          value,
          style: AppTextStyle.textRegular15,
        ),
      ],
    );
  }
}
