

import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:raptor_pro/base_url.dart';

import '../../api/api_data.dart';
import '../../model/common_success_model.dart';
import '../../model/drawing_model.dart';
import '../../model/excel_attendance_download.dart';
import '../../model/login_response.dart';
import '../../model/ticket_model.dart';
import '../../service/shared_preference_service.dart';
import '../../utils/file_download.dart';
import '../../utils/global_toast.dart';
import '../widgets/toast.dart';


class DrawingController extends GetxController{

  List<DrawingData> drawingList = [];
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
    DrawingModel? model = await ApiData().drawingListApi(siteId);

    if (model != null) {
      drawingList = model.data ?? [];

    }
    isLoading.value = false;
    update();
  }


  drawingUpload({ List<File>? files}) async {
    isLoading.value = true;
    update();
    CommonSuccessResponseModel? model = await ApiData().drawingUploadApi(
        siteId: siteId.toString(),
        files: files
    );

    if (model != null) {
      await init();
      Get.back();
      /* GlobalToast.show(
        message: model.message ?? '',
        type: ToastType.success,
      );*/


    }
    isLoading.value = false;
    update();
  }

  downloadDrawing(DrawingData data,context) async {
    isLoading.value = true;
    update();

    CommonFileDownloader.downloadAndOpen(
      urls:'${imageUrl}/${data.drawingViewUrl}' ??'',
      context: context,
    );

 /*  ExcelAttendanceDownloadModel? model =
    await ApiData().downloadFileHttp(data.drawingId.toString());



    if (model != null && model.status == true) {
      showToastMessage(model.message??"Something Went wrong");


          CommonFileDownloader.downloadAndOpen(
            urls:data.drawingViewUrl ??'',
            context: context,
          );
  }
*/
  //    Get.back();
      // GlobalToast.show(message: model.message ?? '', type: ToastType.success);


    isLoading.value = false;
    update();
  }


  deleteDrawing(String drawingId) async {
    isLoading.value = true;
    update();
    CommonSuccessResponseModel? model = await ApiData().deleteDrawingApi(
      drawingId,
    );

    if (model != null) {
      showToastMessage(model.message??"Something Went wrong");


     await init();
     Get.back();
    }
    isLoading.value = false;
    update();
  }
}
