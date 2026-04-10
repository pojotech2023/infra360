

import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';

import '../../api/api_data.dart';
import '../../model/common_success_model.dart';
import '../../model/login_response.dart';
import '../../model/ticket_detail_model.dart';
import '../../model/ticket_model.dart';
import '../../service/shared_preference_service.dart';


class TicketDetailController extends GetxController{

  List<TicketDetailData> ticketDetailList = [];
  var isLoading = false.obs;
  var isMsgLoading = false.obs;
  late final int ticketId;
  late final int siteId;
  late LoginResponse userDetails;

  TicketData args =  Get.arguments;
  @override
  void onInit() {
    // TODO: implement onInit

     ticketId = args.id!;
     siteId = args.siteId!;
    final data = jsonDecode(PreferenceUtils().getUserInfo());
    userDetails = LoginResponse.fromJson(data);
    init();
    super.onInit();
  }

  init() async {

    isLoading.value = true;
    ticketDetailList.clear();
    update();
    TicketDetailModel? model = await ApiData().ticketDetailListApi(ticketId);

    if (model != null) {
      ticketDetailList.add(TicketDetailData(

    id: args.id,
    siteId:args.siteId,
        senderType: "client",
        message: args.ticket,
        createdAt: args.createdAt.toString(),
        updatedAt: args.updatedAt.toString(),
        attachment: args.filePath

    ));
      ticketDetailList.addAll( model.data ?? []);

    }
    isLoading.value = false;
    update();
  }


  sendMessage({String? message, File? file}) async {
    isMsgLoading.value = true;
    update();

    CommonSuccessResponseModel? model = await ApiData().sendMessageApi(
      siteId: siteId.toString(),
      ticketId: ticketId.toString(),
      senderType: userDetails.data!.role!.toLowerCase(),
      message: message,
      file: file,
    );

    if (model != null) {
      DateTime now = DateTime.now().toUtc(); // convert to UTC
      String formatted = now.toIso8601String();
      print(formatted);
      ticketDetailList.add(
          TicketDetailData(
              id :0,
              ticketId:ticketId,
             siteId:siteId,
              senderType: userDetails.data!.role!.toLowerCase(),
              message :message,
             createdAt: formatted,
              updatedAt:formatted,
           attachment:""
          )

      );

      // handle response if needed
    }

    isMsgLoading.value = false;
    update();
  }

}
