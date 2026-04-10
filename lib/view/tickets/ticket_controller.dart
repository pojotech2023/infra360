

import 'dart:convert';

import 'package:get/get.dart';

import '../../api/api_data.dart';
import '../../model/login_response.dart';
import '../../model/ticket_model.dart';
import '../../service/shared_preference_service.dart';


class TicketController extends GetxController{

  List<TicketData> ticketList = [];
var isLoading = false.obs;
late final int siteId;
late LoginResponse userDetails;

@override
void onInit() {
  // TODO: implement onInit
  siteId = Get.arguments ?? 0;
  final data = jsonDecode(PreferenceUtils().getUserInfo());
  userDetails = LoginResponse.fromJson(data);
  init();
  super.onInit();
}

init() async {
  isLoading.value = true;
  update();
  TicketModel? model = await ApiData().ticketListApi(siteId);

  if (model != null) {
    ticketList = model.data ?? [];

  }
  isLoading.value = false;
  update();
}
}
