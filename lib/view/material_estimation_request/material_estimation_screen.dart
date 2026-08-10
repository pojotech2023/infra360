import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';

import 'material_estimation_controller.dart';
import '../../model/material_estimation_model.dart';
import 'package:intl/intl.dart';

class MaterialEstimationScreen extends StatelessWidget {
  const MaterialEstimationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MaterialEstimationController());
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: 'Material Estimation Request',
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: GetBuilder<MaterialEstimationController>(
          builder: (ctrl) {
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
                    // Form Area
                    Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Particulars', style: AppTextStyle.textBold),
                          VerticalSpacing.d15px(),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ctrl.itemList.length,
                            separatorBuilder: (_, __) => VerticalSpacing.d15px(),
                            itemBuilder: (context, index) {
                              final item = ctrl.itemList[index];
                              return _buildRowItem(context, ctrl, item, index);
                            },
                          ),
                          VerticalSpacing.d20px(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple[400],
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                                onPressed: ctrl.addItem,
                                child: const Text('+ Add Row', style: TextStyle(color: Colors.white)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    // Check if all items have unit selected
                                    bool valid = true;
                                    for (var i in ctrl.itemList) {
                                      if (i.unitId == null) {
                                        valid = false;
                                        break;
                                      }
                                    }
                                    if (!valid) {
                                      Get.snackbar('Validation', 'Please select a unit for all items');
                                      return;
                                    }
                                    ctrl.submit();
                                  }
                                },
                                child: ctrl.isSubmitLoading.value
                                    ? const SizedBox(
                                        height: 20, width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text('Submit', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    VerticalSpacing.d40px(),

                    // Requested Materials List
                    Text('Requested Materials', style: AppTextStyle.textBold),
                    VerticalSpacing.d15px(),
                    if (ctrl.requestedMaterials.isEmpty)
                      const Text("No materials requested yet.")
                    else
                      SizedBox(
                        width: double.infinity,
                        child: _buildCardList(ctrl),
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

  Widget _buildRowItem(BuildContext context, MaterialEstimationController ctrl, MaterialEstimationItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Item ${index + 1}', style: AppTextStyle.textMedium.copyWith(fontWeight: FontWeight.bold)),
              if (ctrl.itemList.length > 1)
                InkWell(
                  onTap: () => ctrl.removeItem(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.close, color: Colors.red, size: 20),
                  ),
                ),
            ],
          ),
          VerticalSpacing.d15px(),
          TextFormField(
            controller: item.particular,
            decoration: textBoxDecoration(hint: 'Particular (e.g. Bricks)'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          VerticalSpacing.d15px(),
          TextFormField(
            controller: item.quantity,
            keyboardType: TextInputType.number,
            decoration: textBoxDecoration(hint: 'Quantity'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          VerticalSpacing.d15px(),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<UnitInfo>(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.unitName ?? 'Select Unit',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: item.unitName == null ? Colors.grey[600] : Colors.black,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
              onSelected: (unit) => ctrl.updateUnit(index, unit),
              itemBuilder: (context) {
                return ctrl.units.map((u) {
                  return PopupMenuItem(
                    value: u,
                    child: Text(u.name ?? ''),
                  );
                }).toList();
              },
            ),
          ),
          VerticalSpacing.d15px(),
          TextFormField(
            controller: item.date,
            readOnly: true,
            onTap: () => ctrl.selectDate(context, index),
            decoration: textBoxDecoration(hint: 'dd-mm-yyyy').copyWith(
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.black54, size: 20),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCardList(MaterialEstimationController ctrl) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ctrl.requestedMaterials.length,
      itemBuilder: (context, index) {
        final item = ctrl.requestedMaterials[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.particular ?? '', style: AppTextStyle.textBold.copyWith(fontSize: 16)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_square, color: Colors.blue, size: 22),
                          onPressed: () {
                            if (item.id != null) {
                              _showEditDialog(Get.context!, ctrl, item);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red, size: 24),
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
                VerticalSpacing.d5px(),
                Row(
                  children: [
                    Text('Quantity: ', style: AppTextStyle.textMedium.copyWith(color: Colors.grey[700])),
                    Text(item.quantity ?? '-', style: AppTextStyle.textMedium),
                  ],
                ),
                VerticalSpacing.d5px(),
                Row(
                  children: [
                    Text('Unit: ', style: AppTextStyle.textMedium.copyWith(color: Colors.grey[700])),
                    Text(item.unit ?? '', style: AppTextStyle.textMedium),
                  ],
                ),
                VerticalSpacing.d5px(),
                Row(
                  children: [
                    Text('Date: ', style: AppTextStyle.textMedium.copyWith(color: Colors.grey[700])),
                    Text(() {
                      if (item.date == null || item.date!.isEmpty) return '';
                      try {
                        return DateFormat('dd-MM-yyyy').format(DateTime.parse(item.date!));
                      } catch (_) {
                        return item.date!;
                      }
                    }(), style: AppTextStyle.textMedium),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, MaterialEstimationController ctrl, RequestedMaterial item) {
    final TextEditingController particularCtrl = TextEditingController(text: item.particular);
    final TextEditingController quantityCtrl = TextEditingController(text: item.quantity);
    
    DateTime parsedDate = DateTime.now();
    try {
      if (item.date != null && item.date!.isNotEmpty) {
        parsedDate = DateTime.parse(item.date!);
      }
    } catch (_) {}
    
    final TextEditingController dateCtrl = TextEditingController(text: DateFormat('dd-MM-yyyy').format(parsedDate));
    int? selectedUnitId = item.unitId;
    String? selectedUnitName = item.unit;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('Edit Material Estimation Request', style: AppTextStyle.textBold.copyWith(color: Colors.blue[900])),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(ctx).pop(),
                          )
                      ],
                    ),
                    const Divider(),
                    VerticalSpacing.d10px(),
                    Text('Particular', style: AppTextStyle.textMedium),
                    VerticalSpacing.d5px(),
                    TextFormField(
                      controller: particularCtrl,
                      decoration: textBoxDecoration(hint: 'Particular'),
                    ),
                    VerticalSpacing.d15px(),
                    Text('Quantity', style: AppTextStyle.textMedium),
                    VerticalSpacing.d5px(),
                    TextFormField(
                      controller: quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: textBoxDecoration(hint: 'Quantity'),
                    ),
                    VerticalSpacing.d15px(),
                    Text('Unit', style: AppTextStyle.textMedium),
                    VerticalSpacing.d5px(),
                    Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: PopupMenuButton<UnitInfo>(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(selectedUnitName ?? 'Select Unit',
                                style: TextStyle(color: selectedUnitName == null ? Colors.grey[600] : Colors.black),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
                        onSelected: (unit) {
                          setState(() {
                            selectedUnitId = unit.id;
                            selectedUnitName = unit.name;
                          });
                        },
                        itemBuilder: (context) => ctrl.units.map((u) {
                          return PopupMenuItem(
                            value: u,
                            child: Text(u.name ?? ''),
                          );
                        }).toList(),
                      ),
                    ),
                    VerticalSpacing.d15px(),
                    Text('Date', style: AppTextStyle.textMedium),
                    VerticalSpacing.d5px(),
                    TextFormField(
                      controller: dateCtrl,
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: parsedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            parsedDate = picked;
                            dateCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
                          });
                        }
                      },
                      decoration: textBoxDecoration(hint: 'dd-mm-yyyy').copyWith(
                        suffixIcon: const Icon(Icons.calendar_today, color: Colors.black54, size: 20),
                      ),
                    ),
                    VerticalSpacing.d20px(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple[400]),
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                        ),
                        HorizontalSpacing.d10px(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          onPressed: () {
                            if (particularCtrl.text.trim().isNotEmpty && 
                                (selectedUnitId != null || (selectedUnitName != null && selectedUnitName!.isNotEmpty)) && 
                                dateCtrl.text.trim().isNotEmpty) {
                              Navigator.of(ctx).pop();
                              String backendDate = DateFormat('yyyy-MM-dd').format(parsedDate);
                              ctrl.updateMaterial(item.id!, particularCtrl.text.trim(), quantityCtrl.text.trim(), selectedUnitId, selectedUnitName, backendDate);
                            } else {
                              Get.snackbar('Error', 'Please fill all fields');
                            }
                          },
                          child: const Text('Save', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
          }
        );
      }
    );
  }

  void _showDeleteDialog(BuildContext context, MaterialEstimationController ctrl, int id) {
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
                Text('Are you sure you want to delete this material estimation request?', style: AppTextStyle.textMedium.copyWith(fontWeight: FontWeight.normal)),
                VerticalSpacing.d30px(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple[400]),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                    HorizontalSpacing.d10px(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF75D59)), // matching red
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ctrl.deleteMaterial(id);
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
