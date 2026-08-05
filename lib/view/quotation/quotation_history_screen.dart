import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../utils/res/colors.dart';
import '../../utils/res/spacing.dart';
import '../../utils/app_text_style.dart';
import '../widgets/common_app_bar.dart';
import 'quotation_history_controller.dart';

class QuotationHistoryScreen extends StatelessWidget {
  QuotationHistoryScreen({super.key});
  
  final QuotationHistoryController controller = Get.put(QuotationHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), // Web-like light background
      appBar: CommonAppBar.appBar(title: 'Quotation History', onTap: () => Get.back()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchCard(),
            VerticalSpacing.d20px(),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.hasSearched.value) {
                return _buildResultsSection();
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search by Customer Mobile Number', 
                style: AppTextStyle.textBold.copyWith(color: AppColor.black, fontSize: 16)),
            VerticalSpacing.d20px(),
            Form(
              key: controller.formKey,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: controller.mobileNoController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: 'Enter 10 digit mobile number',
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue[300]!),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length != 10) {
                          return 'Enter valid 10 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                  HorizontalSpacing.d10px(),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () => controller.searchHistory(),
                        icon: const Icon(Icons.search, size: 20),
                        label: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Quotations for ${controller.mobileNoController.text.trim()}',
                style: AppTextStyle.textBold.copyWith(fontSize: 18, color: Colors.blue[900])),
            HorizontalSpacing.d10px(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${controller.historyList.length}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
        VerticalSpacing.d20px(),
        if (controller.historyList.isEmpty)
          const Center(child: Text("No quotations found for this number.", style: TextStyle(color: Colors.grey)))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.historyList.length,
            separatorBuilder: (context, index) => VerticalSpacing.d15px(),
            itemBuilder: (context, index) {
              final item = controller.historyList[index];
              return _buildQuotationCard(item, index + 1);
            },
          ),
      ],
    );
  }

  Widget _buildQuotationCard(item, int sNo) {
    String formattedDate = item.date ?? '';
    if (formattedDate.isNotEmpty) {
      try {
        DateTime parsed = DateTime.parse(formattedDate);
        formattedDate = DateFormat('dd-MM-yyyy').format(parsed);
      } catch (e) {
        // Keep original if parsing fails
      }
    }
    
    // Format currency
    String displayAmount = item.totalAmount ?? '0';
    try {
      double amount = double.parse(displayAmount);
      displayAmount = '₹${NumberFormat("#,##0.00", "en_IN").format(amount)}';
    } catch (e) {
      displayAmount = '₹$displayAmount';
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(item.name ?? 'Unknown', 
                      style: AppTextStyle.textBold.copyWith(fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('#$sNo', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Mobile Number', item.mobileNo ?? ''),
            VerticalSpacing.d10px(),
            _buildDetailRow('Subject', item.subject ?? ''),
            VerticalSpacing.d10px(),
            _buildDetailRow('Date', formattedDate),
            VerticalSpacing.d10px(),
            _buildDetailRow('Total Amount', displayAmount, isBold: true),
            VerticalSpacing.d20px(),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  foregroundColor: Colors.blue,
                ),
                onPressed: controller.isPdfLoading.value
                    ? null
                    : () => controller.viewPdf(item.id!),
                icon: controller.isPdfLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                      )
                    : const Icon(Icons.picture_as_pdf, size: 18),
                label: Text(
                  controller.isPdfLoading.value ? 'Loading PDF...' : 'View PDF',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        const Text(': ', style: TextStyle(color: Colors.grey)),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
