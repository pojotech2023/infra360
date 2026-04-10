import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/checklist_model.dart';
import '../widgets/common_app_bar.dart';
import 'check_list_controller.dart';
import 'checklist_detail_screen.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/common_app_bar.dart';
import 'check_list_controller.dart';
import 'checklist_detail_screen.dart';






import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/common_app_bar.dart';
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
      ),
      body: GetBuilder<CheckListController>(
        builder: (controller) {
          if (controller.checkListManagement.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: controller.checkListManagement.length,
            itemBuilder: (context, index) {
              var data = controller.checkListManagement[index];
              bool isExpanded = expandedIndex == index;


              return Container(
                margin: const EdgeInsets.all(8),
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
                        Expanded(child: Text(data.stage ?? '')),
                        if (data.tasks != null && data.tasks!.isNotEmpty)
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
                    if (isExpanded && data.tasks != null)
                      ...data.tasks!.map((task) {



                        Color statusColor = task.status == 1 ? Colors.green :task.status == 0 ? Colors.yellow: task.status == -1? Colors.grey: Colors.red;
print("statusColor $statusColor");
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 16,  // circle diameter
                                height: 16,
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.5), // inner color
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: statusColor, // border color
                                    width: 2, // border thickness
                                  ),
                                ),
                              ),

                              SizedBox(width: 24,),
                         Expanded(child:   Text(task.taskName ?? ''),),
                              SizedBox(width: 24,),
                              Visibility(
                                visible: task.canOpen ?? false,
                              //  visible: !(controller.userDetails.data?.role?.toLowerCase() == 'admin' && task.status == -1),
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
                          )
                        );
                      }).toList(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
