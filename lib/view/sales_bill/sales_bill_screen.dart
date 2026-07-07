import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/date_picker.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import '../../model/sales_bill_model.dart';

import 'sales_bill_controller.dart';

class SalesBillScreen extends StatelessWidget {
  const SalesBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SalesBillController());
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: 'Generate Sales Bill',
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: GetBuilder<SalesBillController>(
          builder: (ctrl) {
            if (ctrl.isFormLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // ─── Name ────────────────────────────────────────────────
                  _label('Name'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: ctrl.nameController,
                          decoration: textBoxDecoration(hint: 'Enter Customer Name'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      if (ctrl.customers.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PopupMenuButton<CustomerInfo>(
                            icon: const Icon(Icons.contacts, color: Colors.blue),
                            tooltip: 'Select Existing Customer',
                            onSelected: (CustomerInfo customer) {
                              ctrl.onCustomerSelected(customer);
                            },
                            itemBuilder: (BuildContext context) {
                              return ctrl.customers.map((CustomerInfo customer) {
                                return PopupMenuItem<CustomerInfo>(
                                  value: customer,
                                  child: Text("${customer.name} (${customer.mobileNo})"),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  VerticalSpacing.d15px(),

                  // ─── Mobile No ───────────────────────────────────────────
                  _label('Mobile No'),
                  TextFormField(
                    controller: ctrl.mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: textBoxDecoration(hint: 'Enter Mobile Number'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  VerticalSpacing.d15px(),

                  // ─── Email ───────────────────────────────────────────────
                  _label('Email'),
                  TextFormField(
                    controller: ctrl.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: textBoxDecoration(hint: 'Enter Email (for Send Mail)'),
                  ),
                  VerticalSpacing.d15px(),

                  // ─── Date ────────────────────────────────────────────────
                  _label('Date'),
                  TextFormField(
                    controller: ctrl.dateController,
                    readOnly: true,
                    decoration: textBoxDecoration(
                      hint: 'yyyy-MM-dd',
                      suffixIcon: const Icon(Icons.calendar_month, color: Colors.grey),
                    ),
                    onTap: () async {
                      final picked = await selectDate(context);
                      if (picked.isNotEmpty) {
                        ctrl.dateController.text = picked;
                      }
                    },
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  VerticalSpacing.d15px(),

                  // ─── Subject ─────────────────────────────────────────────
                  _label('Subject'),
                  TextFormField(
                    controller: ctrl.subjectController,
                    decoration: textBoxDecoration(hint: 'Subject of Sales Bill'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  VerticalSpacing.d15px(),

                  // ─── Location ────────────────────────────────────────────
                  _label('Location'),
                  TextFormField(
                    controller: ctrl.locationController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: textBoxDecoration(hint: 'Enter Location'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  VerticalSpacing.d20px(),

                  // ─── Particulars section ──────────────────────────────────
                  Text('Particulars', style: AppTextStyle.textFieldHeadingStyle.copyWith(fontSize: 16)),
                  VerticalSpacing.d10px(),

                  Obx(() => Column(
                    children: ctrl.itemList.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Particular
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: item.particular,
                                decoration: textBoxDecoration(hint: 'Particular (e.g. Bricks)'),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Count
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: item.count,
                                keyboardType: TextInputType.number,
                                decoration: textBoxDecoration(hint: 'Count'),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Amount
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: item.amount,
                                keyboardType: TextInputType.number,
                                decoration: textBoxDecoration(hint: 'Amount'),
                                onChanged: (_) => ctrl.recalcTotal(),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Delete button
                            InkWell(
                              onTap: () => ctrl.removeItem(idx),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )),

                  // ─── Add Row button ───────────────────────────────────────
                  TextButton.icon(
                    onPressed: () => ctrl.addItem(),
                    icon: const Icon(Icons.add, color: Colors.white, size: 16),
                    label: const Text('+ Add Row', style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF5C4DB1), // purple like screenshot
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),

                  VerticalSpacing.d15px(),

                  // ─── Total ────────────────────────────────────────────────
                  Obx(() => Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: ₹ ${ctrl.totalAmount.value.toStringAsFixed(2)}',
                      style: AppTextStyle.textFieldHeadingStyle.copyWith(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  )),

                  VerticalSpacing.d20px(),

                  // ─── Action Buttons ───────────────────────────────────────
                  GetBuilder<SalesBillController>(
                    builder: (c) => c.isSubmitLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              // Send WhatsApp
                              SizedBox(
                                width: 150,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      c.sendWhatsApp();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7)),
                                  ),
                                  child: const Text('Send WhatsApp',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              // Send Mail
                              SizedBox(
                                width: 140,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      c.sendMail();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7)),
                                  ),
                                  child: const Text('Send Mail',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              // Download PDF
                              SizedBox(
                                width: 160,
                                child: OutlinedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      c.downloadPdf();
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: const BorderSide(color: Colors.blue, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7)),
                                  ),
                                  child: const Text('Download PDF',
                                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: AppTextStyle.textFieldHeadingStyle),
      );
}
