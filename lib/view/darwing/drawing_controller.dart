

import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raptor_pro/base_url.dart';
import '../../utils/url_helper.dart';

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

  downloadDrawing(DrawingData data, context) async {
    isLoading.value = true;
    update();

    List<String> candidateUrls = [];

    // 1. Check dedicated drawingDownloadUrl from API response
    if (data.drawingDownloadUrl != null && data.drawingDownloadUrl!.trim().isNotEmpty) {
      candidateUrls.add(UrlHelper.getFullImageUrl(data.drawingDownloadUrl));
    }

    // 2. Check drawingViewUrl resolved via UrlHelper
    if (data.drawingViewUrl != null && data.drawingViewUrl!.trim().isNotEmpty) {
      final viewUrl = UrlHelper.getFullImageUrl(data.drawingViewUrl);
      if (!candidateUrls.contains(viewUrl)) {
        candidateUrls.add(viewUrl);
      }
      // Alternate public/storage vs storage path
      if (viewUrl.contains('/public/storage/')) {
        final alt = viewUrl.replaceFirst('/public/storage/', '/storage/');
        if (!candidateUrls.contains(alt)) candidateUrls.add(alt);
      } else if (viewUrl.contains('/storage/')) {
        final alt = viewUrl.replaceFirst('/storage/', '/public/storage/');
        if (!candidateUrls.contains(alt)) candidateUrls.add(alt);
      }
    }

    // 3. Backend download endpoint fallback
    if (data.drawingId != null) {
      final apiDownloadUrl = "${baseUrl}drawings/download/${data.drawingId}";
      if (!candidateUrls.contains(apiDownloadUrl)) {
        candidateUrls.add(apiDownloadUrl);
      }
    }

    print('📥 [DOWNLOAD] Trying candidates: $candidateUrls');

    bool downloaded = false;
    for (int i = 0; i < candidateUrls.length; i++) {
      final url = candidateUrls[i];
      final isLast = i == candidateUrls.length - 1;
      print('📥 [DOWNLOAD] Attempting (${i + 1}/${candidateUrls.length}): $url');
      downloaded = await CommonFileDownloader.downloadAndOpen(
        urls: url,
        fileName: data.drawingName,
        context: context,
        showToast: isLast,
      );
      if (downloaded) break;
    }

    if (!downloaded && candidateUrls.isEmpty) {
      showToastMessage("❌ No download URL found for this drawing.");
    }

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

  shareViaWhatsApp(DrawingData item) async {
    final imageUrl = UrlHelper.getFullImageUrl(item.drawingViewUrl);
    final messageText = "Check out this drawing: ${item.drawingName ?? ''}\n$imageUrl";
    final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(messageText)}');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showToastMessage("Could not launch WhatsApp. Is it installed?");
    }
  }
}
