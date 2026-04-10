
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
      body: GetBuilder<TicketController>(
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
                        Expanded(child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.ticket ?? ''),
                            SizedBox(height: 4,),
                            Text(formattedDate,
                                style: TextStyle(fontSize: 10,color: Colors.grey))],
                        )),
                        IconButton(
                          onPressed:  () => Get.to(() => TicketDetailScreen(), arguments: data),


                          icon: Icon(
                              Icons.chevron_right

                          ),
                        ),

                      ],
                    ),

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
