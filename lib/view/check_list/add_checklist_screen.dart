import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_checklist_controller.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_button.dart';
import '../../utils/app_text_style.dart';
import '../../utils/res/colors.dart';
import '../../utils/text_form_style.dart';
import '../../utils/res/spacing.dart';

class AddChecklistScreen extends StatelessWidget {
  const AddChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddChecklistController controller = Get.put(AddChecklistController());

    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: 'Add Checklist',
        onTap: () => Get.back(),
      ),
      body: GetBuilder<AddChecklistController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Checklist Form',
                        style: AppTextStyle.textFieldHeadingStyle
                            .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      VerticalSpacing.d20px(),

                      // Stage field
                      Text('Stages', style: AppTextStyle.textFieldHeadingStyle),
                      VerticalSpacing.d5px(),
                      TextFormField(
                        controller: controller.stageController,
                        decoration: textBoxDecoration(hint: 'Enter Stage Name'),
                      ),
                      VerticalSpacing.d20px(),

                      // Dynamic Task fields
                      ...List.generate(controller.taskControllers.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (i == 0)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text('Task List',
                                      style: AppTextStyle.textFieldHeadingStyle),
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: controller.taskControllers[i],
                                      decoration: textBoxDecoration(
                                          hint: 'Enter Task ${i + 1}'),
                                    ),
                                  ),
                                  if (controller.taskControllers.length > 1)
                                    IconButton(
                                      onPressed: () =>
                                          controller.removeTaskField(i),
                                      icon: const Icon(Icons.cancel,
                                          color: Colors.red, size: 24),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      // Add another task button
                      TextButton.icon(
                        onPressed: () => controller.addTaskField(),
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: const Text('+ Add another task',
                            style: TextStyle(color: Colors.white)),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ],
                  ),
                ),

                VerticalSpacing.d30px(),

                // Submit / Cancel row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.submitChecklist(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Submit',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
