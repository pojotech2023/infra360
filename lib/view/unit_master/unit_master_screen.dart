import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_text_style.dart';
import '../../utils/res/spacing.dart';
import '../../view/widgets/common_app_bar.dart';
import '../../utils/text_form_style.dart';
import 'unit_master_controller.dart';
import '../../model/unit_master_model.dart';

class UnitMasterScreen extends StatelessWidget {
  const UnitMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(UnitMasterController());

    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: 'Unit Master',
        onTap: () => Get.back(),
      ),
      backgroundColor: Colors.grey[50], // Match web background
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Unit List', style: AppTextStyle.textBold.copyWith(fontSize: 18, color: Colors.blue[900])),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: () => _showAddDialog(context, ctrl),
                      icon: const Icon(Icons.add, color: Colors.white, size: 20),
                      label: const Text('Add Unit', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                VerticalSpacing.d20px(),
                if (ctrl.units.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No units found.'),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: _buildCardList(ctrl),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCardList(UnitMasterController ctrl) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ctrl.units.length,
      itemBuilder: (context, i) {
        final item = ctrl.units[i];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold),
                  ),
                ),
                HorizontalSpacing.d10px(),
                Expanded(
                  child: Text(
                    item.unitName ?? '',
                    style: AppTextStyle.textMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_square, color: Colors.blue, size: 20),
                      onPressed: () {
                        if (item.id != null) {
                          _showEditDialog(Get.context!, ctrl, item);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: () {
                        if (item.id != null) {
                          _showDeleteDialog(Get.context!, ctrl, item.id!);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, UnitMasterController ctrl) {
    final TextEditingController nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Unit', style: AppTextStyle.textBold.copyWith(color: Colors.blue[900])),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    )
                  ],
                ),
                const Divider(),
                VerticalSpacing.d10px(),
                Text('Unit Name', style: AppTextStyle.textMedium),
                VerticalSpacing.d5px(),
                TextFormField(
                  controller: nameCtrl,
                  decoration: textBoxDecoration(hint: 'e.g. Kg, Bag, Ton'),
                ),
                VerticalSpacing.d20px(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: ctrl.isSubmitLoading.value ? null : () {
                        if (nameCtrl.text.isNotEmpty) {
                          Navigator.of(ctx).pop();
                          ctrl.addUnit(nameCtrl.text);
                        } else {
                          Get.snackbar('Error', 'Please enter unit name');
                        }
                      },
                      child: ctrl.isSubmitLoading.value 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save', style: TextStyle(color: Colors.white)),
                    )),
                    HorizontalSpacing.d10px(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple[400]),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

  void _showEditDialog(BuildContext context, UnitMasterController ctrl, UnitMasterData item) {
    final TextEditingController nameCtrl = TextEditingController(text: item.unitName);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Edit Unit', style: AppTextStyle.textBold.copyWith(color: Colors.blue[900])),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    )
                  ],
                ),
                const Divider(),
                VerticalSpacing.d10px(),
                Text('Unit Name', style: AppTextStyle.textMedium),
                VerticalSpacing.d5px(),
                TextFormField(
                  controller: nameCtrl,
                  decoration: textBoxDecoration(hint: 'Unit Name'),
                ),
                VerticalSpacing.d20px(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: ctrl.isSubmitLoading.value ? null : () {
                        if (nameCtrl.text.isNotEmpty) {
                          Navigator.of(ctx).pop();
                          ctrl.updateUnit(item.id!, nameCtrl.text);
                        } else {
                          Get.snackbar('Error', 'Please enter unit name');
                        }
                      },
                      child: ctrl.isSubmitLoading.value 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Update', style: TextStyle(color: Colors.white)),
                    )),
                    HorizontalSpacing.d10px(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple[400]),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

  void _showDeleteDialog(BuildContext context, UnitMasterController ctrl, int id) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Confirm Delete', style: AppTextStyle.textBold.copyWith(color: Colors.blue[900])),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    )
                  ],
                ),
                const Divider(),
                VerticalSpacing.d10px(),
                Text('Are you sure you want to delete this unit?', style: AppTextStyle.textMedium.copyWith(fontWeight: FontWeight.normal)),
                VerticalSpacing.d30px(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF75D59)), // matching red
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ctrl.deleteUnit(id);
                      },
                      child: const Text('Yes, Delete', style: TextStyle(color: Colors.white)),
                    ),
                    HorizontalSpacing.d10px(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }
}
