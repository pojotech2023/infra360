import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'purchase_bill_history_screen.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/date_picker.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import '../../model/purchase_bill_model.dart';

import 'purchase_bill_controller.dart';

class PurchaseBillScreen extends StatelessWidget {
  const PurchaseBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PurchaseBillController());
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: 'Generate Purchase Bill',
        onTap: () => Get.back(),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to Purchase Bill History
                Get.to(() => PurchaseBillHistoryScreen(), arguments: controller.siteId);
              },
              icon: const Icon(Icons.history, size: 16, color: Colors.blue),
              label: const Text('Bill History', style: TextStyle(color: Colors.blue)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: Colors.blue)),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: GetBuilder<PurchaseBillController>(
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
                  // ─── Vendor Name ────────────────────────────────────────────────
                  _label('Vendor Name'),
                  TextFormField(
                    controller: ctrl.nameController,
                    focusNode: ctrl.vendorFocusNode,
                    decoration: textBoxDecoration(hint: 'Type Vendor Name...'),
                    onChanged: (val) => ctrl.filterVendors(val),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  if (ctrl.isVendorListVisible && ctrl.filteredVendors.isNotEmpty)
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(top: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: ctrl.filteredVendors.length,
                          itemBuilder: (context, index) {
                            final vendor = ctrl.filteredVendors[index];
                            return InkWell(
                              onTap: () => ctrl.onVendorSelected(vendor),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(vendor.name ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                                    if (vendor.mobileNo != null && vendor.mobileNo!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(vendor.mobileNo!, style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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
                      hint: 'dd-MM-yyyy',
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
                    decoration: textBoxDecoration(hint: 'Subject of Purchase Bill'),
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

                  // ─── PO Fields ───────────────────────────────────────────
                  _label('Vendor GST No'),
                  TextFormField(
                    controller: ctrl.vendorGstNoController,
                    decoration: textBoxDecoration(hint: 'Vendor GST Number'),
                  ),
                  VerticalSpacing.d15px(),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Project Ref Number'),
                            TextFormField(
                              controller: ctrl.projectRefNumberController,
                              decoration: textBoxDecoration(hint: 'e.g. 23-125'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('PO Number'),
                            TextFormField(
                              controller: ctrl.poNumberController,
                              decoration: textBoxDecoration(hint: 'e.g. 83/125'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  VerticalSpacing.d15px(),

                  _label('Description of Work'),
                  TextFormField(
                    controller: ctrl.descriptionOfWorkController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: textBoxDecoration(hint: 'Optional - leave blank to print "As per Annexure"'),
                  ),
                  VerticalSpacing.d15px(),

                  _label('Description of Materials'),
                  TextFormField(
                    controller: ctrl.descriptionOfMaterialsController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: textBoxDecoration(hint: 'Optional - leave blank to print "As per Annexure"'),
                  ),
                  VerticalSpacing.d15px(),

                  _label('Recommended Firm'),
                  TextFormField(
                    controller: ctrl.recommendedFirmController,
                    decoration: textBoxDecoration(hint: 'Defaults to Vendor Name'),
                  ),
                  VerticalSpacing.d15px(),

                  _label('Payment Terms'),
                  TextFormField(
                    controller: ctrl.paymentTermsController,
                    decoration: textBoxDecoration(hint: 'e.g. 50% advance, 50% after delivery'),
                  ),
                  VerticalSpacing.d15px(),

                  _label('Scheduled Date'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: ctrl.scheduledDateFromController,
                          readOnly: true,
                          decoration: textBoxDecoration(
                            hint: 'dd-mm-yyyy',
                            suffixIcon: const Icon(Icons.calendar_month, color: Colors.grey),
                          ),
                          onTap: () async {
                            final picked = await selectDate(context);
                            if (picked.isNotEmpty) ctrl.scheduledDateFromController.text = picked;
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('to'),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: ctrl.scheduledDateToController,
                          readOnly: true,
                          decoration: textBoxDecoration(
                            hint: 'dd-mm-yyyy',
                            suffixIcon: const Icon(Icons.calendar_month, color: Colors.grey),
                          ),
                          onTap: () async {
                            final picked = await selectDate(context);
                            if (picked.isNotEmpty) ctrl.scheduledDateToController.text = picked;
                          },
                        ),
                      ),
                    ],
                  ),
                  VerticalSpacing.d15px(),

                  _label('Delivery Address'),
                  TextFormField(
                    controller: ctrl.deliveryAddressController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: textBoxDecoration(hint: 'Delivery address (optional)'),
                  ),
                  VerticalSpacing.d15px(),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Site Contact Person'),
                            TextFormField(
                              controller: ctrl.siteContactPersonController,
                              decoration: textBoxDecoration(hint: 'Name'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Contact Mobile'),
                            TextFormField(
                              controller: ctrl.siteContactMobileController,
                              keyboardType: TextInputType.phone,
                              decoration: textBoxDecoration(hint: 'Mobile Number'),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Particular
                                Expanded(
                                  child: TextFormField(
                                    controller: item.particular,
                                    decoration: textBoxDecoration(hint: 'Particular (e.g. Bricks)'),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 6),
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
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Count
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: item.count,
                                    keyboardType: TextInputType.number,
                                    decoration: textBoxDecoration(hint: 'Count'),
                                    onChanged: (_) => ctrl.recalcTotal(),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Unit
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    value: item.selectedUnit,
                                    isExpanded: true,
                                    items: ctrl.unitMasterList.map((unit) {
                                      return DropdownMenuItem<String>(
                                        value: unit.unitName,
                                        child: Text(unit.unitName ?? ''),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      item.selectedUnit = val;
                                    },
                                    decoration: textBoxDecoration(hint: 'Unit'),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Rate (previously Amount)
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: item.amount,
                                    keyboardType: TextInputType.number,
                                    decoration: textBoxDecoration(hint: 'Rate'),
                                    onChanged: (_) => ctrl.recalcTotal(),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Total (auto-calculated)
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: item.total,
                                    readOnly: true,
                                    decoration: textBoxDecoration(hint: 'Total').copyWith(
                                      fillColor: Colors.grey.shade200,
                                      filled: true,
                                    ),
                                  ),
                                ),
                              ],
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('GST %', style: AppTextStyle.textFieldHeadingStyle.copyWith(fontSize: 12)),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                controller: ctrl.gstPercentageController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: textBoxDecoration(hint: '18'),
                                onChanged: (_) => ctrl.recalcTotal(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Obx(() => Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Sub Total: ₹ ${ctrl.subTotalAmount.value.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'GST Amount: ₹ ${ctrl.gstAmount.value.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total (with GST): ₹ ${ctrl.totalAmount.value.toStringAsFixed(2)}',
                                style: AppTextStyle.textFieldHeadingStyle.copyWith(
                                    fontSize: 18, color: const Color(0xFF5C4DB1)),
                              ),
                            ],
                          )),
                    ],
                  ),

                  // ─── Terms & Conditions ──────────────────────────────────────────
                  _label('Terms & Conditions'),
                  Autocomplete<String>(
                    key: ctrl.autocompleteKey,
                    initialValue: TextEditingValue(text: ctrl.termsTitleController.text),
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return await ctrl.getTermsSuggestions(textEditingValue.text);
                    },
                    onSelected: (String selection) {
                      ctrl.termsTitleController.text = selection;
                      ctrl.onTermsSelected(selection);
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        onChanged: (val) {
                          ctrl.termsTitleController.text = val;
                        },
                        decoration: textBoxDecoration(hint: 'Type a saved title to auto-fill (optional)'),
                      );
                    },
                  ),
                  VerticalSpacing.d10px(),
                  GetBuilder<PurchaseBillController>(
                    builder: (c) => TextFormField(
                      controller: c.termsController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: textBoxDecoration(hint: 'Enter terms & conditions to include in the PDF (optional)'),
                    ),
                  ),
                  VerticalSpacing.d20px(),

                  // ─── Action Buttons ───────────────────────────────────────
                  GetBuilder<PurchaseBillController>(
                    builder: (c) => c.isSubmitLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
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
                              VerticalSpacing.d15px(),
                              // Reset Button
                              Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 200,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('The App Says'),
                                            content: const Text('Reset the form? All entered data will be lost.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  c.resetForm();
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      side: BorderSide(color: Colors.red.shade300, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(7)),
                                    ),
                                    child: Text('Reset',
                                        style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600)),
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
