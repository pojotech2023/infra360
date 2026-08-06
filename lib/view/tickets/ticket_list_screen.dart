
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../widgets/common_app_bar.dart';
import 'ticket_controller.dart';
import 'ticket_detail_screen.dart';



class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {

  TicketController controller = Get.put(TicketController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: "Tickets",
        onTap: () => Get.back(),
      ),
      body: SafeArea(
        child: GetBuilder<TicketController>(
          builder: (controller) {

            if(controller.isLoading.value){
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.isLoading.value == false && controller.ticketList.isEmpty) {
              return const Center(child: Text("No Ticket Available"));
            }
            return ListView.builder(
            itemCount: controller.ticketList.length,
            itemBuilder: (context, index) {
              var data = controller.ticketList[index];

              final dateTime = DateTime.parse(data.createdAt!).toLocal();
              final formattedDate = DateFormat("dd/MM/yyyy hh:mm a").format(dateTime);
              return InkWell(
                onTap: () => Get.to(() => TicketDetailScreen(), arguments: data),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Site: ${controller.siteName}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tickets Description: ${data.ticket ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Submitted on: ${DateFormat("dd MMM yyyy, hh:mm a").format(dateTime)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      ),
    );
  }
}
