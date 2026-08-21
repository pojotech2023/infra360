import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_text_style.dart';
import '../../utils/res/spacing.dart';
import '../../view/widgets/common_app_bar.dart';
import '../../utils/text_form_style.dart';
import 'terms_condition_controller.dart';
import '../../model/terms_condition_model.dart';
import '../dashboard/drawer_item.dart';

class TermsConditionScreen extends StatelessWidget {
  TermsConditionScreen({super.key});

  final ctrl = Get.put(TermsConditionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: 'Terms & Conditions',
        onTap: () => Get.back(),
      ),
      drawer: const DrawerWidget(),
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Terms & Conditions Templates',
                              style: AppTextStyle.textBold.copyWith(fontSize: 18, color: Colors.blue[900])),
                          VerticalSpacing.d10px(),
                          Text(
                            'Add a title and its description here. In Quotation, Sales Bill and Purchase Bill, typing a matching title auto-fills the description as the Terms & Conditions on the PDF.',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    HorizontalSpacing.d20px(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: () => _showAddOrEditDialog(context, null),
                      icon: const Icon(Icons.add, color: Colors.white, size: 20),
                      label: const Text('Add Template', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                VerticalSpacing.d20px(),
                const Divider(),
                if (ctrl.termsList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text("No Templates Found")),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ctrl.termsList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      TermsConditionData term = ctrl.termsList[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.blue.shade50,
                                child: Text('${index + 1}', style: TextStyle(color: Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(term.title ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    const SizedBox(height: 8),
                                    Text(term.description ?? '', style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4)),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_square, color: Colors.blue, size: 22),
                                    onPressed: () => _showAddOrEditDialog(context, term),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(height: 12),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                                    onPressed: () => _showDeleteDialog(context, term),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showAddOrEditDialog(BuildContext context, TermsConditionData? term) {
    final titleCtrl = TextEditingController(text: term?.title ?? '');
    final descCtrl = TextEditingController(text: term?.description ?? '');
    final isEdit = term != null;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(isEdit ? 'Edit Terms & Conditions Template' : 'Add Terms & Conditions Template',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          titlePadding: const EdgeInsets.only(left: 24, top: 16, right: 8, bottom: 0),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Title', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Standard Payment Terms',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'This text will appear as Terms & Conditions in the PDF',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  bool success;
                  if (isEdit) {
                    success = await ctrl.updateTerm(term.id!, titleCtrl.text.trim(), descCtrl.text.trim());
                  } else {
                    success = await ctrl.addTerm(titleCtrl.text.trim(), descCtrl.text.trim());
                  }
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text(isEdit ? 'Update' : 'Save'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, TermsConditionData term) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Confirm Delete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          titlePadding: const EdgeInsets.only(left: 24, top: 16, right: 8, bottom: 0),
          content: const Text('Are you sure you want to delete this template?'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () async {
                final success = await ctrl.deleteTerm(term.id!);
                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Yes, Delete'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
