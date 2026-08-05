import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/checklist_model.dart';
import '../widgets/common_app_bar.dart';
import 'add_checklist_screen.dart';
import 'check_list_controller.dart';
import 'checklist_detail_screen.dart';



class CheckListScreen extends StatefulWidget {
  const CheckListScreen({super.key});

  @override
  State<CheckListScreen> createState() => _CheckListScreenState();
}

class _CheckListScreenState extends State<CheckListScreen> {

  CheckListController controller = Get.put(CheckListController());
  int? expandedIndex;

  @override
  void initState() {
    // TODO: implement initState


/*  if(Get.arguments!=null){
      SuperVisorData ?superVisorData = Get.arguments;
      nameEditingController.text = superVisorData!.name??"";
      mobileNumberEditingController.text = superVisorData!.mobileNo??"";
      emailEditingController.text = superVisorData!.email??"";
    }*/


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: "Check List",
        onTap: () => Get.back(),
        actions: [
          GetBuilder<CheckListController>(
            builder: (ctrl) => Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    height: 32,
                    child: TextButton.icon(
                      onPressed: () async {
                        if (!ctrl.isManageMode) {
                          ctrl.toggleManageMode();
                        } else {
                          final result = await Get.to(
                            () => const AddChecklistScreen(),
                            arguments: ctrl.siteId,
                          );
                          if (result == true) {
                            ctrl.init();
                          }
                        }
                      },
                      icon: Icon(ctrl.isManageMode ? Icons.add : Icons.settings, color: Colors.white, size: 14),
                      label: Text(
                        ctrl.isManageMode ? 'Add Checklist' : 'Manage Checklist',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: ctrl.isManageMode ? Colors.teal : Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: GetBuilder<CheckListController>(
          builder: (controller) {
            if (controller.checkListManagement.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async => controller.init(),
              child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: controller.checkListManagement.length,
              onReorder: (oldIndex, newIndex) {
                controller.reorderStages(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                var data = controller.checkListManagement[index];
                bool isExpanded = expandedIndex == index;

                return Container(
                  key: ValueKey(data.checklistId ?? index),
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (controller.isManageMode)
                            ReorderableDragStartListener(
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.drag_indicator, color: Colors.grey),
                              ),
                            ),
                          Expanded(child: Text(data.stage ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                          if (controller.isManageMode) ...[
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                              onPressed: () => _editStageDialog(context, data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _deleteStageDialog(context, data),
                            ),
                          ],
                          IconButton(
                            onPressed: () {
                              setState(() {
                                expandedIndex = isExpanded ? null : index;
                              });
                            },
                            icon: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ),
                        ],
                      ),
                      if (isExpanded)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data.tasks != null && data.tasks!.isNotEmpty)
                              ReorderableListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                buildDefaultDragHandles: false,
                                itemCount: data.tasks!.length,
                                onReorder: (oldTaskIndex, newTaskIndex) {
                                  controller.reorderTasks(index, oldTaskIndex, newTaskIndex);
                                },
                                itemBuilder: (context, taskIndex) {
                                  var task = data.tasks![taskIndex];
                                  Color statusColor = task.status == 1 ? Colors.green : task.status == 0 ? Colors.yellow : task.status == -1 ? Colors.grey : Colors.red;

                                  return Container(
                                    key: ValueKey(task.taskId ?? taskIndex),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    child: Row(
                                      children: [
                                        if (controller.isManageMode)
                                          ReorderableDragStartListener(
                                            index: taskIndex,
                                            child: const Padding(
                                              padding: EdgeInsets.only(right: 8),
                                              child: Icon(Icons.drag_indicator, color: Colors.grey, size: 18),
                                            ),
                                          ),
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: statusColor,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(child: Text(task.taskName ?? '')),
                                        if (controller.isManageMode) ...[
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                            onPressed: () => _editTaskDialog(context, task),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                            onPressed: () => _deleteTaskDialog(context, task),
                                          ),
                                        ],
                                        Visibility(
                                          visible: task.canOpen ?? false,
                                          child: IconButton(
                                            onPressed: () {
                                              final showForm = task.status != 1;
                                              Get.to(() => ChecklistDetailScreen(
                                                    siteID: controller.siteId,
                                                    tasks: task,
                                                    isShowFrom: showForm,
                                                  ));
                                            },
                                            icon: const Icon(Icons.arrow_forward_ios_sharp, size: 16),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            if (controller.isManageMode)
                              TextButton.icon(
                                onPressed: () => _addTaskDialog(context, data),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Item'),
                              ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
            );
          },
        ),
      ),
    );
  }

  void _editStageDialog(BuildContext context, Checklists data) {
    TextEditingController tc = TextEditingController(text: data.stage);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Stage'),
        content: TextField(
          controller: tc,
          decoration: const InputDecoration(hintText: "Stage Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (tc.text.isNotEmpty) {
                Navigator.pop(context);
                await controller.editStage(data.checklistId!, tc.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteStageDialog(BuildContext context, Checklists data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this entire stage? All checklist items under it will be removed too.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteStage(data.checklistId!);
            },
            child: const Text('Yes, Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addTaskDialog(BuildContext context, Checklists data) {
    TextEditingController tc = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Checklist Item'),
        content: TextField(
          controller: tc,
          decoration: const InputDecoration(hintText: "Item Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (tc.text.isNotEmpty) {
                Navigator.pop(context);
                await controller.addTask(data.checklistId!, tc.text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editTaskDialog(BuildContext context, Tasks task) {
    TextEditingController tc = TextEditingController(text: task.taskName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Checklist Item'),
        content: TextField(
          controller: tc,
          decoration: const InputDecoration(hintText: "Item Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (tc.text.isNotEmpty) {
                Navigator.pop(context);
                await controller.editTask(task.taskId!, tc.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteTaskDialog(BuildContext context, Tasks task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteTask(task.taskId!);
            },
            child: const Text('Yes, Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
