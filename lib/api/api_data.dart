import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/model/agent_list_model.dart';
import 'package:raptor_pro/model/attendance_list_model.dart';
import 'package:raptor_pro/model/bricks_model.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/customer_model.dart';
import 'package:raptor_pro/model/login_response.dart';
import 'package:raptor_pro/model/material_list_model.dart';
import 'package:raptor_pro/model/material_request_list_model.dart';
import 'package:raptor_pro/model/other_utilities_model.dart';
import 'package:raptor_pro/model/property_list_model.dart';
import 'package:raptor_pro/model/unit_master_model.dart';
import 'package:raptor_pro/model/site_management_model.dart';
import 'package:raptor_pro/model/subcontractor_dashboard_model.dart';
import 'package:raptor_pro/model/subcontractor_material_orders_model.dart';
import 'package:raptor_pro/model/subcontractor_payment_details_model.dart';
import 'package:raptor_pro/model/subcontractor_payment_history_model.dart';
import 'package:raptor_pro/model/supervisor_list_model.dart';
import 'package:raptor_pro/model/supervisor_permissions_model.dart';
import 'package:raptor_pro/model/user_profile_model.dart';
import 'package:raptor_pro/model/vendor_dashboard_model.dart';
import 'package:raptor_pro/model/vendor_management_model.dart';
import 'package:raptor_pro/model/vendor_model.dart';
import 'package:raptor_pro/model/vendor_material_orders_model.dart';
import 'package:raptor_pro/model/vendor_payment_details_model.dart';
import 'package:raptor_pro/model/vendor_payment_history_model.dart';
import 'package:raptor_pro/model/site_payment_summary_model.dart';
import 'package:raptor_pro/model/site_payment_history_model.dart';
import 'package:raptor_pro/model/sales_bill_model.dart';
import 'package:raptor_pro/model/purchase_bill_model.dart';
import 'package:raptor_pro/model/material_estimation_model.dart';
import 'package:raptor_pro/service/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:raptor_pro/service/shared_preference_service.dart';

import '../model/attendance_datewise_model.dart';
import '../model/checklist_model.dart';
import '../model/drawing_model.dart';
import '../model/employee_list_model.dart';
import '../model/excel_attendance_download.dart';
import '../model/material_request_success_model.dart';
import 'package:raptor_pro/view/widgets/toast.dart';
import '../model/my_subcontractor_list_model.dart';
import '../model/profile_update_success_model.dart';
import '../model/quotation_model.dart';
import '../model/quotation_stored_model.dart';
import '../model/quotation_history_model.dart';
import '../model/terms_condition_model.dart';
import '../model/subcontractor_amount_model.dart';
import '../model/subcontractor_list_model.dart';
import '../model/ticket_detail_model.dart';
import '../model/ticket_model.dart';
import '../model/units_model.dart';
import '../utils/res/date_picker.dart';
class ApiData {
  Future<LoginResponse?> loginApi(String mobileNumber, String password) async {
    Map<String, dynamic> data = {
      "mobile_no": mobileNumber,
      "password": password
    };

    final response = await ApiService().sendAsync("POST", "login", data, false);

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);

      if (response.statusCode == 200) {
        print("LOGIN SUCCESS JSON: ${response.body}");
        return LoginResponse.fromJson(body);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        throw Exception(body['message'] ?? 'Authentication failed');
      } else if (response.statusCode > 401) {
        print("LOGIN ERROR RESPONSE: ${response.statusCode} - ${response.body}");
        if (body['errors'] != null) {
          final errors = body['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final errorMessage = errors.values.first[0];
            throw Exception(errorMessage);
          }
        }
        throw Exception(body['message'] ?? 'Server error occurred: ${response.statusCode}');
      }
    }

    return null;
  }

  Future<void> saveDeviceToken(String token) async {
    try {
      final response = await ApiService().sendAsync("POST", "save-device-token", {"token": token}, true);
      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        print("✅ FCM Token saved successfully");
      } else {
        print("❌ Failed to save FCM token. Status: ${response?.statusCode}");
      }
    } catch (e) {
      print("❌ Error saving FCM token: $e");
    }
  }

  Future<SiteManagementModel?> siteListApi() async {
    final response =
        await ApiService().sendAsync("GET", "all_sites", null, true);
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return SiteManagementModel.fromJson(body);
      }
    }

    return null;
  }



  Future<SitePaymentSummaryModel?> sitePaymentSummaryApi(int siteId) async {
    final response = await ApiService().sendAsync("GET", "site-payment-summary/$siteId", null, true);
    if (response != null) {
      print("SITE SUMMARY RESPONSE: ${response.body}");
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200) {
        return SitePaymentSummaryModel.fromJson(body);
      }
    }
    return null;
  }

  Future<SitePaymentHistoryModel?> sitePaymentHistoryApi(int siteId) async {
    final response = await ApiService().sendAsync("GET", "site-payment-history/$siteId", null, true);
    if (response != null) {
      print("SITE HISTORY RESPONSE: ${response.body}");
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200) {
        return SitePaymentHistoryModel.fromJson(body);
      }
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> sitePaymentAddApi(Map<String, dynamic> postData) async {
    final response = await ApiService().sendAsync("POST", "site-payment-add", postData, true);
    if (response != null) {
      print("SITE ADD PAYMENT RESPONSE: ${response.body}");
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }
    return null;
  }

  Future<ExcelAttendanceDownloadModel?> sitePaymentExportApi(int siteId) async {
    final response = await ApiService().sendAsync("GET", "site-payment-history/$siteId/export", null, true);
    if (response != null && response.statusCode == 200) {
      print("Export API Response body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}");
      print("Export API Content-Type: ${response.headers['content-type']}");

      // Check if response is CSV (backend returns CSV directly)
      final trimmedBody = response.body.trim();
      final isCsv = trimmedBody.startsWith('S.No') ||
                     trimmedBody.startsWith('S.No,') ||
                     trimmedBody.contains('Date,"Total Payment"') ||
                     response.headers['content-type']?.contains('csv') == true ||
                     response.headers['content-type']?.contains('text/plain') == true;

      if (isCsv) {
        // Return the API URL as download URL since backend returns CSV directly
        final url = baseUrl.endsWith('/') ? "${baseUrl}site-payment-history/$siteId/export" : "$baseUrl/site-payment-history/$siteId/export";
        print("Returning download URL: $url");
        return ExcelAttendanceDownloadModel(
          downloadUrl: url,
          status: true,
          message: "Export successful",
        );
      }
      // Try to parse as JSON if not CSV
      try {
        return ExcelAttendanceDownloadModel.fromJson(json.decode(response.body));
      } catch (e) {
        print("JSON parsing failed: $e, treating as CSV download");
        final url = baseUrl.endsWith('/') ? "${baseUrl}site-payment-history/$siteId/export" : "$baseUrl/site-payment-history/$siteId/export";
        return ExcelAttendanceDownloadModel(
          downloadUrl: url,
          status: true,
          message: "Export successful",
        );
      }
    }
    return null;
  }

  Future<ExcelAttendanceDownloadModel?> downloadPaymentReceiptPdf(int paymentId) async {
    final response = await ApiService().sendAsync("GET", "site-payment-pdf/$paymentId", null, true);
    if (response != null) {
      print("API Response for site-payment-pdf: ${response.statusCode} - ${response.body}");
      if (response.statusCode == 200) {
        return ExcelAttendanceDownloadModel.fromJson(json.decode(response.body));
      }
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> sendPaymentReceiptWhatsApp(int paymentId, String phoneNumber) async {
    final response = await ApiService().sendAsync("GET", "site-payment-whatsapp/$paymentId", null, true);
    if (response != null) {
      print("API Response for site-payment-whatsapp: ${response.statusCode} - ${response.body}");
      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(json.decode(response.body));
      }
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> sendPaymentReceiptEmail(int paymentId, String email) async {
    final response = await ApiService().sendAsync("GET", "site-payment-mail/$paymentId", null, true);
    if (response != null) {
      print("API Response for site-payment-mail: ${response.statusCode} - ${response.body}");
      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(json.decode(response.body));
      }
    }
    return null;
  }



  Future<CommonSuccessResponseModel?> deleteSiteApi(int siteID) async {
    final response =
    await ApiService().sendAsync("DELETE", "sites/$siteID", null, true);
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?>
  addSiteApi({
    required String siteName,
    required String location,
    required String flatArea,
    required String builtupArea,
    required String duration,
    required String supervisorId,
    required String customerName,
    required String mobileNo,
    required String email,
    required String dob,
    required String address,
  File? files, // multiple files supported
  }) async {




    final uri = Uri.parse("${baseUrl}create_sites");
    print("📡 Uploading to: $uri");

    final request = http.MultipartRequest('POST', uri)
      ..fields['site_name'] = siteName
      ..fields['location'] = location
      ..fields['flat_area'] = flatArea
      ..fields['built_up_area'] = builtupArea
      ..fields['duration'] = duration
      ..fields['supervisor_id'] = supervisorId
      ..fields['name'] = customerName
      ..fields['mobile_no'] = mobileNo
      ..fields['email'] = email
      ..fields['dob'] = dob
      ..fields['address'] = address;

    if (files != null) {

          request.files.add(await http.MultipartFile.fromPath(
              'site_img',
              files.path,
          ));
        } else {
          print("⚠️ Skipped unsupported file type: $files");
        }



    try {
      final response = await request.send();
      print("📤 Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = await http.Response.fromStream(response);
        final Map<String, dynamic> body = json.decode(res.body);
        print("✅ Response: $body");
        return CommonSuccessResponseModel.fromJson(body);
      } else {
        print("❌ Upload failed. Status: ${response.statusCode}");
        final res = await http.Response.fromStream(response);
        print("Response: ${res.body}");
      }
    } catch (e) {
      print("🚨 Exception while uploading: $e");
    }

    return null;
  }


  Future<CommonSuccessResponseModel?>
  updateSiteApi({
    required String id,
    required String siteName,
    required String location,
    required String flatArea,
    required String builtupArea,
    required String duration,
    required String supervisorId,
required String status,
    File? files, // multiple files supported
  }) async {




    final uri = Uri.parse("${baseUrl}sites/update");
    print("📡 Uploading to: $uri");

    final request = http.MultipartRequest('POST', uri)
      ..fields['site_id'] = id
      ..fields['site_name'] = siteName
      ..fields['location'] = location
      ..fields['flat_area'] = flatArea
      ..fields['built_up_area'] = builtupArea
      ..fields['duration'] = duration
      ..fields['supervisor_id'] = supervisorId
      ..fields['status'] = status;


    if (files != null) {

      request.files.add(await http.MultipartFile.fromPath(
        'site_img',
        files.path,
      ));
    } else {
      print("⚠️ Skipped unsupported file type: $files");
    }



    try {
      final response = await request.send();
      print("📤 Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = await http.Response.fromStream(response);
        final Map<String, dynamic> body = json.decode(res.body);
        print("✅ Response: $body");
        return CommonSuccessResponseModel.fromJson(body);
      } else {
        print("❌ Upload failed. Status: ${response.statusCode}");
        final res = await http.Response.fromStream(response);
        print("Response: ${res.body}");
      }
    } catch (e) {
      print("🚨 Exception while uploading: $e");
    }

    return null;
  }


  Future<EmployeeListModel?> getEmployeeListApi() async {
    final response = await ApiService().sendAsync(
      "GET",
      "supervisor-management",
      null,
      true,
    );
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);

      if (response.statusCode == 200) {
        return EmployeeListModel.fromJson(body);
      }
    }

    return null;
  }





  Future<BricksModel?> bricksListApi(int id,String month,int ?week,String materialType) async {

    String endPoint = "material/$id/$materialType";

    Map<String, dynamic> postData = {
      "monthYear": month,
      "week": week
    };
    final response = await ApiService().sendAsync("POST", endPoint, postData, true);
    if (response != null) {
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return BricksModel.fromJson(body);
      }
    }

    return null;
  }

  Future<VendorModel?> vendorApi(String vendorName) async {
    final response =
    await ApiService().sendAsync("GET", "vendors/search?name=$vendorName", null, true);

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return VendorModel.fromJson(body);
      }
    }

    return null;
  }


  Future<MaterialRequestSuccessModel?> bricksRequestApi(String urls,
      Map<String, String> input,
      File? files,
      ) async {
    final uri = Uri.parse(urls);
    print("📡 Uploading to: $uri");

    final token = PreferenceUtils().getSessionToken();

    final request = http.MultipartRequest('POST', uri);

    // Expand items if it's a JSON array string to bracket notation for Laravel
    input.forEach((key, value) {
      if (key == 'items') {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            for (int i = 0; i < decoded.length; i++) {
              final itm = decoded[i];
              if (itm is Map) {
                itm.forEach((subKey, subVal) {
                  request.fields['items[$i][$subKey]'] = subVal?.toString() ?? '';
                });
              }
            }
            return;
          }
        } catch (_) {}
      }
      request.fields[key] = value;
    });

    // ✅ Add Authorization header
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print("Input ${request.fields}");
    print("REQUEST HEADER ${request.headers}");

    // ✅ Attach file only if it’s provided and valid
    if (files != null && files.path.isNotEmpty) {
      print("📎 Attaching file: ${files.path}");
      request.files.add(await http.MultipartFile.fromPath('attachment', files.path));
    } else {
      print("⚠️ No attachment provided — skipping file upload.");
    }

    try {
      final response = await request.send();
      print("📤 Status Code: ${response.statusCode}");

      final res = await http.Response.fromStream(response);
      print("📥 Response: ${res.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = json.decode(res.body);
        print("✅ Upload successful: $body");
        return MaterialRequestSuccessModel.fromJson(body);
      } else {
        print("❌ Upload failed. Status: ${response.statusCode}");
        try {
          final Map<String, dynamic> errJson = json.decode(res.body);
          if (errJson.containsKey('errors')) {
            final errors = errJson['errors'];
            if (errors is Map && errors.isNotEmpty) {
              final firstErr = errors.values.first;
              final errMsg = firstErr is List ? firstErr.first.toString() : firstErr.toString();
              showToastMessage(errMsg);
            }
          } else if (errJson.containsKey('message')) {
            showToastMessage(errJson['message'].toString());
          }
        } catch (_) {}
      }
    } catch (e) {
      print("🚨 Exception while uploading: $e");
    }

    return null;
  }



  Future<CommonSuccessResponseModel?> addOrderBricksApi(Map<String,dynamic>data, String itemKey) async {
    final response =
    await ApiService().sendAsync("POST", "add-order", data, true);

    print("${response?.body}");

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> deleteMaterialApi(int materialId) async {
    final response = await ApiService().sendAsync("DELETE", "material-delete/$materialId", null, true);

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> deleteOtherUtilityApi(int id) async {
    final response = await ApiService().sendAsync("DELETE", "utility-delete/$id", null, true);
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> deleteSubUtilityApi(int id) async {
    final response = await ApiService().sendAsync("DELETE", "subutility-delete/$id", null, true);
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }
    return null;
  }

  

  

  Future<CommonSuccessResponseModel?> updateOtherUtilityApi(int id, Map<String, dynamic> data) async {
    final response = await ApiService().sendAsync("POST", "update-utility/$id", data, true);
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> updateSubUtilityApi(int id, Map<String, dynamic> data) async {
    final response = await ApiService().sendAsync("POST", "update-subutility/$id", data, true);
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }
    return null;
  }
  
  Future<ExcelAttendanceDownloadModel?> materialExportApi(String siteId, String materialType, String month, {String? fromDate, String? toDate}) async {
    final queryParams = <String, String>{
      'site_id': siteId,
      'material_type': materialType,
      'month': month,
    };
    if (fromDate != null && fromDate.isNotEmpty) {
      queryParams['from_date'] = fromDate;
      queryParams['start_date'] = fromDate;
    }
    if (toDate != null && toDate.isNotEmpty) {
      queryParams['to_date'] = toDate;
      queryParams['end_date'] = toDate;
    }
    final uri = Uri(path: "material-export", queryParameters: queryParams);
    print("📤 materialExportApi REQUEST: $uri");
    final response = await ApiService().sendAsync("GET", uri.toString(), null, true);
    print("📥 materialExportApi RESPONSE: ${response?.statusCode} -> ${response?.body}");
    if (response != null && response.statusCode == 200) {
      return ExcelAttendanceDownloadModel.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<ExcelAttendanceDownloadModel?> materialPdfDownloadApi(int materialId) async {
    print("📄 materialPdfDownloadApi REQUEST: material-order/$materialId/pdf");
    final response = await ApiService().sendAsync("GET", "material-order/$materialId/pdf", null, true);
    print("📄 materialPdfDownloadApi RESPONSE: ${response?.statusCode} → ${response?.body}");
    if (response != null && response.statusCode == 200) {
      return ExcelAttendanceDownloadModel.fromJson(json.decode(response.body));
    }
    return null;
  }
  
  Future<ExcelAttendanceDownloadModel?> subcontractorExportApi(String siteId, String month) async {
    final queryParams = <String, String>{
      'site_id': siteId,
      'month': month
    };
    final uri = Uri(path: "subcontractor-export", queryParameters: queryParams);
    final response = await ApiService().sendAsync("GET", uri.toString(), null, true);
    if (response != null && response.statusCode == 200) {
      return ExcelAttendanceDownloadModel.fromJson(json.decode(response.body));
    }
    return null;
  }




  Future<SubcontractorAmountModel?> subcontractorsListApi({
    required String id,
    required String siteId,
    required String month,
    int? week,
  }) async {
    String endpoint = "subcontractor/$siteId/$id?monthYear=$month&week=$week";


    // Prepare body
    Map<String, dynamic> postData = {
      "monthYear": month,
      if (week != null) "week": week,
    };

    final response = await ApiService().sendAsync("POST", endpoint, postData, true);

    if (response != null) {
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return SubcontractorAmountModel.fromJson(body);
      } else {
        print("❌ API Error: ${response.statusCode} ${response.body}");
      }
    } else {
      print("⚠️ No response from API");
    }

    return null;
  }



  Future<MaterialResponse?> materialListApi(int siteId, {String? monthYear, int? week}) async {
    String endpoint = "material-detail/$siteId";
    if (monthYear != null) {
      endpoint += "?monthYear=$monthYear";
      if (week != null) {
        endpoint += "&week=$week";
      }
    }

    final response =
    await ApiService().sendAsync("GET", endpoint, null, true);

    print("${response?.body}");

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);

      if (response.statusCode == 200) {
        return MaterialResponse.fromJson(body);
      }
    }

    return null;
  }

  Future<UnitsModel?> materialUnitsListApi() async {
    final response =
    await ApiService().sendAsync("GET", "materials-unit", null, true);
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);




      if (response.statusCode == 200) {
        return UnitsModel.fromJson(body);
      }
    }

    return null;
  }

  Future<SubcontractorResponse?> subcontractorListApi(int siteId, {String? monthYear, int? week}) async {
    String endpoint = "subcontractor-detail/$siteId";
    if (monthYear != null) {
      endpoint += "?monthYear=$monthYear";
      if (week != null) {
        endpoint += "&week=$week";
      }
    }
    
    final response = await ApiService().sendAsync("GET", endpoint, null, true);

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);

      if (response.statusCode == 200) {
        print("response Body : ${response.body}");
        return SubcontractorResponse.fromJson(body);
      }
    }

    return null;
  }


  Future<CommonSuccessResponseModel?> addSubcontractorServicesApi(Map<String,dynamic>data,) async {
    final response =
    await ApiService().sendAsync("POST", "add-service", data, true);

    print("${response?.body}");

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> deleteSubcontractorServiceApi(int serviceId) async {
    final response = await ApiService().sendAsync("DELETE", "service-delete/$serviceId", null, true);
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> updateSubcontractorServiceApi(int id, Map<String, dynamic> data) async {
    final response = await ApiService().sendAsync("POST", "service-update/$id", data, true);
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }
    return null;
  }


  Future<CommonSuccessResponseModel?> addUtilities({
    required String siteId,
    required String amount,
    required String remarks,
    required String date,
    required File files,
  }) async {




    var uri = Uri.parse("${baseUrl}utilities-add");


print("uri ${uri}");
    var request = http.MultipartRequest('POST', uri);
    request.fields['site_id'] = siteId.toString();
    request.fields['amount'] = amount;
    request.fields['remarks'] = remarks;
    request.fields['date'] = date;


    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${PreferenceUtils().getSessionToken()}',
    });

    if (files.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        files.path,
      ));
    } else {
      print("⚠️ Skipped unsupported file type: $files");
    }


    var response = await request.send();


    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final Map<String, dynamic> body = json.decode(res.body);
      print(" json.decode(res.body) ${ json.decode(res.body)}");
      return CommonSuccessResponseModel.fromJson(body);
    }


    return null;
  }

  Future<OtherUtilitiesModel?> otherUtilitiesListApi(int sideId) async {
    final response =
    await ApiService().sendAsync("GET", "site-utilities/$sideId", null, true);



    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return OtherUtilitiesModel.fromJson(body);
      }
    }

    return null;
  }


  Future<OtherUtilitiesModel?> otherUtilitiesSubcontractorListApi(int sideId) async {
    final response =
    await ApiService().sendAsync("GET", "site-subutilities/$sideId", null, true);



    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return OtherUtilitiesModel.fromJson(body);
      }
    }

    return null;
  }

  Future<AttendanceListModel?> attendanceList(int sideId,String ?month,int ?weekId,String ?date) async {

    String basePath  ="attendance/$sideId";

    final queryParams = <String, String>{};


    if (month != null && month.isNotEmpty) queryParams['month'] = month;
    if (weekId != null ) queryParams['week'] = weekId.toString(); // 👈 not weekId — match "week"
    if (date != null && date.isNotEmpty) queryParams['date'] = date;

    print("📥 Attendance List API Call");
    print("📥 Query Params: $queryParams");

    final uri = Uri(path: basePath, queryParameters: queryParams);
    final pathWithQuery = uri.toString();

    final response =
    await ApiService().sendAsync("GET", pathWithQuery, null, true);



    if (response != null) {
      // 🔍 Debug: print raw response to verify JSON structure
      final rawBody = response.body;
      print("� ATTENDANCE RAW (first 600 chars): ${rawBody.length > 600 ? rawBody.substring(0, 600) : rawBody}");

      final Map<String, dynamic> body = json.decode(rawBody);
      
      // Log grouped_by_date vs attendances
      print("📥 Response Structure:");
      print("   - grouped_by_date exists: ${body.containsKey('grouped_by_date')}");
      print("   - attendances exists: ${body.containsKey('attendances')}");
      if (body.containsKey('grouped_by_date') && body['grouped_by_date'] != null) {
        print("   - grouped_by_date length: ${body['grouped_by_date'].length}");
        if (body['grouped_by_date'].length > 0) {
          print("   - grouped_by_date first item: ${jsonEncode(body['grouped_by_date'][0])}");
        }
      }
      if (body.containsKey('attendances') && body['attendances'] != null) {
        print("   - attendances length: ${body['attendances'].length}");
      }

      if (response.statusCode == 200) {
        return AttendanceListModel.fromJson(body);
      }
    }

    return null;
  }

  Future<AttendanceDatewiseModel?> dateWiseattendanceApi(int sideId,String date) async {
    final response =
    await ApiService().sendAsync("GET", "attendance/sites/$sideId/attendance-by-date?date=$date", null, true);

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return AttendanceDatewiseModel.fromJson(body);
      }
    }

    return null;
  }

  Future<AttendanceDatewiseModel?> weekWiseAttendanceApi(int sideId, String fromDate, String toDate) async {
    final response =
    await ApiService().sendAsync("GET", "attendance/sites/$sideId/attendance-by-date?from_date=$fromDate&to_date=$toDate", null, true);

    if (response != null) {
      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        return AttendanceDatewiseModel.fromJson(decoded);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> deleteAttendanceApi(int attendanceId) async {
    final response = await ApiService().sendAsync("DELETE", "attendance-delete/$attendanceId", null, true);

    if (response != null) {
      print("Delete Attendance API Response - Status: ${response.statusCode}");
      print("Delete Attendance API Response - Body: ${response.body}");
      
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommonSuccessResponseModel.fromJson(body);
      } else {
        print("Delete Attendance API Error - Status: ${response.statusCode}, Body: ${response.body}");
      }
    } else {
      print("Delete Attendance API Error - Response is null");
    }
    return null;
  }


  Future<ExcelAttendanceDownloadModel?> attendanceExcelDownload(int sideId,String ?month,int ?weekId,String ?date, {String? fromDate, String? toDate}) async {


   // https://ssbuildcraft.in/admin/public/api/attendance?site_id=1&month=2025-10&week=5
    String basePath  ="attendance";

    final queryParams = <String, String>{};


    var convertmonth = month != null ? convertMonthFormat(month) : null;

    if (sideId != null && sideId.toString().isNotEmpty) queryParams['site_id'] = sideId.toString();
    if (convertmonth != null && convertmonth.isNotEmpty) queryParams['month'] = convertmonth;
    if (weekId != null ) queryParams['week'] = weekId.toString(); // 👈 not weekId — match "week"
    if (date != null && date.isNotEmpty) queryParams['date'] = date;
    if (fromDate != null && fromDate.isNotEmpty) queryParams['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) queryParams['to_date'] = toDate;

    print("queryParams ${queryParams}");

    final uri = Uri(path: basePath, queryParameters: queryParams);
    final pathWithQuery = uri.toString();

    final response =
    await ApiService().sendAsync("GET", pathWithQuery, null, true);



    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return ExcelAttendanceDownloadModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> attendanceDeleteApi(int id) async {
    final response = await ApiService().sendAsync("DELETE", "attendance-delete/$id", null, true);
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }
    return null;
  }

  Future<ExcelAttendanceDownloadModel?> attendanceExportApi(String siteId, String month, String week) async {
    final queryParams = <String, String>{
      'site_id': siteId,
      'month': month,
      'week': week
    };
    final uri = Uri(path: "attendance", queryParameters: queryParams);
    final response = await ApiService().sendAsync("GET", uri.toString(), null, true);
    if (response != null && response.statusCode == 200) {
      return ExcelAttendanceDownloadModel.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> addAttendanceApi(Map<String,dynamic>data) async {
    final response =
    await ApiService().sendAsync("POST", "add-attendance", data, true);

    print("${response?.body}");

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }


  Future<CommonSuccessResponseModel?> addWagesApi(Map<String,dynamic>data,String type, {File? checkInFile, File? checkOutFile}) async {
    var url = type =="1" ?  'add-wages' : type =="2"?'attendance/update':"update-attendance-wages";

    print("📤 Attendance Update API Call");
    print("📤 URL: $url");
    print("📤 Type: $type");
    
    if (checkInFile != null || checkOutFile != null) {
      final uri = Uri.parse("${baseUrl}$url");
      final token = PreferenceUtils().getSessionToken();
      final request = http.MultipartRequest('POST', uri);
      
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      
      if (checkInFile != null && checkInFile.path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('check_in_photo', checkInFile.path));
      }
      if (checkOutFile != null && checkOutFile.path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('check_out_photo', checkOutFile.path));
      }
      
      try {
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return CommonSuccessResponseModel.fromJson(json.decode(response.body));
        }
      } catch (e) {
        print("❌ Error: $e");
      }
      return null;
    } else {
      final response = await ApiService().sendAsync("POST", url, data, true);
      if (response != null) {
        try {
          final Map<String, dynamic> body = json.decode(response.body);
          if (response.statusCode == 200 || response.statusCode == 201) {
            return CommonSuccessResponseModel.fromJson(body);
          }
        } catch (e) {
          print("❌ Error: $e");
        }
      }
      return null;
    }
  }



  Future<PropertyListModel?> propertyList() async {
    final response =
    await ApiService().sendAsync("GET", "property-management", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return PropertyListModel.fromJson(body);
      }
    }

    return null;
  }

  Future<SuperVisorModel?> superVisorList() async {
    final response =
    await ApiService().sendAsync("GET", "supervisor-management", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      print("response of Supervisor Data---------------");
      if (response.statusCode == 200) {
        print("response of ${response.body}");
        return SuperVisorModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CustomerModel?> customerList() async {
    final response =
    await ApiService().sendAsync("GET", "customer-management", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      print("response of Customer Data---------------");
      if (response.statusCode == 200) {
        print("response of ${response.body}");
        return CustomerModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> addSuperVisor(String name,String mobileNo,String emailId,String password,String confirmPassword) async {

    Map<String,dynamic> postData={
      "name":name,
      "mobile_no":mobileNo,
      "email":emailId,
      "password":password,
      "password_confirmation":confirmPassword
    };
    final response =
    await ApiService().sendAsync("POST", "supervisor-add", postData, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }
  Future<CommonSuccessResponseModel?>   updateSuperVisor(int id,String name,String mobileNo,String emailId,String password,String confirmPassword) async {

    Map<String,dynamic> postData={
      "id":id,
      "name":name,
      "mobile_no":mobileNo,
      "email":emailId,
      "password":password,
      "password_confirmation":confirmPassword
    };
    final response =
    await ApiService().sendAsync("POST", "supervisor-update", postData, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }


  Future<CommonSuccessResponseModel?> deleteSuperVisor(int id) async {


    final response =
    await ApiService().sendAsync("DELETE", "supervisor-delete/$id", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }


  Future<CommonSuccessResponseModel?> addUtilitiesSubcontractor({
    required String siteId,
    required String amount,
    required String remarks,
    required String date,
    required File files,
  }) async {
    final uri = Uri.parse("${baseUrl}subutilities-add");
    print("📡 Uploading to: $uri");

    final token = PreferenceUtils().getSessionToken(); 

    final request = http.MultipartRequest('POST', uri)
      ..fields['site_id'] = siteId
      ..fields['amount'] = amount
      ..fields['remarks'] = remarks
      ..fields['date'] = date;

    // ✅ Add Authorization header
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
print("REQUEST HEADER ${request.headers}");
    // ✅ Attach file
    if (files.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        files.path,
      ));
    } else {
      print("⚠️ Skipped unsupported file type: $files");
    }

    try {
      final response = await request.send();
      print("📤 Status Code: ${response.statusCode}");

      final res = await http.Response.fromStream(response);
      print("📥 Response: ${res.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = json.decode(res.body);
        print("✅ Upload successful: $body");
        return CommonSuccessResponseModel.fromJson(body);
      } else {
        print("❌ Upload failed. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Exception while uploading: $e");
    }

    return null;
  }



  Future<CommonSuccessResponseModel?> updateCustomer(int id,int siteId,String name,String mobileNo,String emailId,String dob,String marrageDate,String address) async {
    Map<String,dynamic> postData={
      "id":id,
      "site_id":siteId.toString(),
      "name":name,
      "mobile_no":mobileNo,
      "email":emailId,
      "dob":dob,
     // "marriage_date":marrageDate,
      "address":address
    };
    final response =
    await ApiService().sendAsync("POST", "customer-update", postData, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }


  Future<CommonSuccessResponseModel?> deleteCustomer(int id) async {


    final response =
    await ApiService().sendAsync("DELETE", "customer-delete/$id", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }



  Future<SubContractorDashboardModel?> subContractorDashboardList() async {
    final response =
    await ApiService().sendAsync("GET", "subcontractor-dashboard", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return SubContractorDashboardModel.fromJson(body);
      }
    }

    return null;
  }

  Future<SubContractorPaymentHistoryModel?> subContractorPaymentHistoryApi(String id) async {
    final response =
    await ApiService().sendAsync("GET", "subpayment-history/$id", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return SubContractorPaymentHistoryModel.fromJson(body);
      }
    }

    return null;
  }

  Future<SubcontractorModel?> subContractorManagementList() async {
    final response =
    await ApiService().sendAsync("GET", "subcontractor-management", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return SubcontractorModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> deleteSubContractor(int id) async {


    final response =
    await ApiService().sendAsync("DELETE", "subcontractor-delete/$id", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> addSubContractor({String ?name,String ?siteUtilities,String ?mobileNo,String ?email,String ?address,String ?gst}) async {

    Map<String,dynamic> postData ={
      "name":name,
      "subcontractors":siteUtilities,
      "mobile_no":mobileNo,
      "email":email,
      "address":address,
      "gst":gst,
    };


    final response =
    await ApiService().sendAsync("POST", "subcontractor-add", postData, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> updateSubContractor({int ?id,String ?name,String ?siteUtilities,String ?mobileNo,String ?email,String ?address,String ?gst}) async {

    Map<String,dynamic> postData ={
      "name":name,
      "subcontractors":siteUtilities,
      "mobile_no":mobileNo,
      "email":email,
      "address":address,
      "gst":gst,
    };


    final response =
    await ApiService().sendAsync("PATCH", "subcontractor-update/${id}", postData, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }



  Future<VendorDashboardModel?> vendorDashboardList() async {
    final response =
    await ApiService().sendAsync("GET", "vendor-dashboard", null, true);

    if (response != null && response.statusCode == 200) {
      try {
        final Map<String, dynamic> body = json.decode(response.body);
        return VendorDashboardModel.fromJson(body);
      } catch (e) {
        print("VendorDashboard API decode error: $e");
      }
    }

    return null;
  }

  Future<VendorManagementModel?> vendorManagementList() async {
    final response =
    await ApiService().sendAsync("GET", "vendor-management", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return VendorManagementModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> deleteVendor(int id) async {


    final response =
    await ApiService().sendAsync("DELETE", "vendor-delete/$id", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> addVendor({String ?name,String ?siteUtilities,String ?mobileNo,String ?email,String ?address,String ?gst}) async {

    Map<String,dynamic> postData ={
      "name":name,
      "site_utilities":siteUtilities,
      "mobile_no":mobileNo,
      "email":email,
      "address":address,
      "gst":gst,
    };


    final response =
    await ApiService().sendAsync("POST", "vendor-add", postData, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> updateVendor({int ?id,String ?name,String ?siteUtilities,String ?mobileNo,String ?email,String ?address,String ?gst}) async {

    Map<String,dynamic> postData ={
      "name":name,
      "site_utilities":siteUtilities,
      "mobile_no":mobileNo,
      "email":email,
      "address":address,
      "gst":gst,
    };


    final response =
    await ApiService().sendAsync("PATCH", "vendor-update/${id}", postData, true);


    print("erer ${response}");
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }



  Future<VendorPaymentDetailsModel?> vendorPaymentDetail(int vendorId) async {
    final response =
    await ApiService().sendAsync("GET", "paydetail/$vendorId", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return VendorPaymentDetailsModel.fromJson(body);
      }
    }

    return null;
  }
  Future<CommonSuccessResponseModel?> vendorPaymentUpdateDetail(Map<String,dynamic> postData) async {
    final response =
    await ApiService().sendAsync("POST", "paydetail-update", postData, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }

  Future<VendorPaymentHistoryModel?> vendorPaymentHistory(int id) async {
    final response =
    await ApiService().sendAsync("GET", "payment-history/$id", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return VendorPaymentHistoryModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> vendorPaymentUpdate(Map<String,dynamic> postData) async {
    final response =
    await ApiService().sendAsync("POST", "payment-add", postData, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> vendorSubContractorUpdate(Map<String,dynamic> postData) async {
    final response =
    await ApiService().sendAsync("POST", "subpayment-add", postData, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);

      print("response ${response.body}");

      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> addProperty(
    String name,
    String location,
    String type,
    String amount,
    String remarks,
    dynamic imageFile,
  ) async {
    final uri = Uri.parse("${baseUrl}property-add");
    final token = PreferenceUtils().getSessionToken();
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request.fields['name'] = name;
    request.fields['location'] = location;
    request.fields['type'] = type;
    request.fields['amount'] = amount;
    request.fields['remarks'] = remarks;

    if (imageFile != null && imageFile.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = json.decode(response.body);
        return CommonSuccessResponseModel.fromJson(body);
      } else {
        print("addProperty error: ${response.statusCode} -> ${response.body}");
        final Map<String, dynamic> body = json.decode(response.body);
        return CommonSuccessResponseModel.fromJson(body);
      }
    } catch (e) {
      print("addProperty exception: $e");
    }
    return null;
  }

  // ─── Property Management APIs ─────────────────────────────────────────────
  Future<List<String>> propertyFormApi() async {
    return ["Plot", "Land"];
  }

  Future<PropertyListData?> propertyDetailApi(int id) async {
    final response = await ApiService().sendAsync("GET", "property/$id", null, true);
    if (response != null && response.statusCode == 200) {
      try {
        final body = json.decode(response.body);
        if (body['data'] != null) {
          return PropertyListData.fromJson(body['data']);
        }
      } catch (e) {
        print("Error parsing propertyDetailApi: $e");
      }
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> updateProperty(
    int id,
    String name,
    String location,
    String type,
    String amount,
    String remarks,
    dynamic imageFile,
  ) async {
    final uri = Uri.parse("${baseUrl}property-update/$id");
    final token = PreferenceUtils().getSessionToken();
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request.fields['name'] = name;
    request.fields['location'] = location;
    request.fields['type'] = type;
    request.fields['amount'] = amount;
    request.fields['remarks'] = remarks;

    if (imageFile != null && imageFile.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = json.decode(response.body);
        return CommonSuccessResponseModel.fromJson(body);
      } else {
        print("updateProperty error: ${response.statusCode} -> ${response.body}");
        final Map<String, dynamic> body = json.decode(response.body);
        return CommonSuccessResponseModel.fromJson(body);
      }
    } catch (e) {
      print("updateProperty exception: $e");
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> deleteProperty(int id) async {
    final response = await ApiService().sendAsync("DELETE", "property-delete/$id", null, true);
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }
    return null;
  }



  Future<AgentListModel?> agentList() async {
    final response =
    await ApiService().sendAsync("GET", "agent-management", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return AgentListModel.fromJson(body);
      }
    }

    return null;
  }
  Future<CommonSuccessResponseModel?> deleteAgent(int id) async {


    final response =
    await ApiService().sendAsync("DELETE", "agent/inactivate/$id", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }


  Future<CommonSuccessResponseModel?> addAgent(String name,String mobileNo,String companyName) async {

    Map<String,dynamic> postData={
      "name":name,
      "mobile_no":mobileNo,
      "company_name":companyName,
    };
    final response =
    await ApiService().sendAsync("POST", "agent-add", postData, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }
  Future<CommonSuccessResponseModel?> updateAgent(int id,String name,String mobileNo,String company) async {

    Map<String,dynamic> postData={
      "name":name,
      "mobile_no":mobileNo,
      "company_name":company,
    };
    final response =
    await ApiService().sendAsync("PATCH", "agent-update/${id}", postData, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }


  Future<CheckListModel?> checkListApi(int siteId) async {
    final response =
    await ApiService().sendAsync("GET", "checklists/$siteId", null, true);

    if (response != null) {
      print("CHECKLIST RESPONSE: ${response.body}");
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CheckListModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> addChecklistApi({
    required int siteId,
    required String stage,
    required List<String> tasks,
  }) async {
    final Map<String, dynamic> postData = {
      "site_id": siteId,
      "stage": stage,
      "task_list": tasks,
    };

    print("📋 addChecklistApi REQUEST: $postData");

    final response = await ApiService().sendAsync("POST", "checklist-add", postData, true);

    if (response != null) {
      print("📋 addChecklistApi RESPONSE: ${response.statusCode} → ${response.body}");
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }



  Future<TicketModel?> ticketListApi(int siteId) async {
    final response =
    await ApiService().sendAsync("GET", "get-tickets-by-site/$siteId", null, true);

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return TicketModel.fromJson(body);
      }
    }

    return null;
  }

  Future<TicketDetailModel?> ticketDetailListApi(int ticketId) async {
    final response =
    await ApiService().sendAsync("GET", "ticket/${ticketId}/messages", null, true);

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return TicketDetailModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> sendMessageApi({
    required String siteId,
    required String ticketId,
    required String senderType,
    String? message,
    File? file,
  }) async {
    final uri = Uri.parse("${baseUrl}tickets/messages-store");
    print("📡 Uploading to: $uri");

    final token = PreferenceUtils().getSessionToken();
    print("🔑 Token: $token");

    final request = http.MultipartRequest('POST', uri)
      ..fields['ticket_id'] = ticketId
      ..fields['site_id'] = siteId
      ..fields['sender_type'] = senderType;

    if (message?.isNotEmpty ?? false) request.fields['message'] = message!;
    request.headers['Authorization'] = 'Bearer $token';
    // request.followRedirects = false; // Prevent hidden redirects

    if (file != null) {
      final String originalPath = file.path;
      print("🔍 Original File Path: $originalPath");
      final String fileName = originalPath.split('/').last;
      
      String ext = '';
      if (fileName.contains('.')) {
        ext = fileName.split('.').last.toLowerCase();
      }
      print("🔍 Extracted Extension: $ext");

      final isImage = ['jpg', 'jpeg', 'png', 'gif'].contains(ext);
      final isVideo = ['mp4', 'mov', 'mkv'].contains(ext);

      final fieldKey = 'attachment'; // ✅ depends on backend
      MediaType type;
      if (isImage) {
        type = MediaType('image', ext == 'jpg' ? 'jpeg' : ext);
      } else if (isVideo) {
        type = MediaType('video', ext);
      } else if (ext == 'pdf') {
        type = MediaType('application', 'pdf');
      } else if (ext == 'doc') {
        type = MediaType('application', 'msword');
      } else if (ext == 'docx') {
        type = MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document');
      } else if (ext == 'xls') {
        type = MediaType('application', 'vnd.ms-excel');
      } else if (ext == 'xlsx') {
        type = MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      } else if (ext == 'txt') {
        type = MediaType('text', 'plain');
      } else {
        // Default to a safe type for validation if we couldn't parse it
        type = MediaType('application', 'pdf');
        ext = 'pdf'; // Force pdf extension for Laravel validator if unknown
        print("⚠️ Forcing extension to PDF because it was unknown");
      }

      final uploadName = fileName.contains('.') ? fileName : '$fileName.$ext';
      print("🔍 Uploading with filename: $uploadName");

      request.files.add(await http.MultipartFile.fromPath(
        fieldKey, 
        file.path, 
        contentType: type,
        filename: uploadName
      ));
    }

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    print("📤 Status: ${res.statusCode}");
    print("📤 Redirect: ${res.isRedirect}");
    print("📤 Headers: ${res.headers}");

    if (res.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(res.body);
      print("✅ Response: $body");
      return CommonSuccessResponseModel.fromJson(body);
    } else {
      print("❌ Upload failed. Status: ${res.statusCode}");
      print("❌ Error Body: ${res.body}");
      return null;
    }
  }



  Future<CommonSuccessResponseModel?> adminApproverApi({required int siteId,required int taskId,required String status,required String remark}) async {

    Map<String,dynamic> postData={

      "site_id":siteId,
      "task_id":taskId,
      "status":status,
      "admin_remark":remark

    };

    print("POST DATA :--------------- ${postData}");
    final response =
    await ApiService().sendAsync("POST", "admin/task/update", postData, true);

    print("POST DATA :--------------- ${response}");

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> supervisorApproverApi({
    required String siteId,
    required String taskId,
    required String remarks,
    List<File>? files, // multiple files supported
  }) async {
    final uri = Uri.parse("${baseUrl}task-media/store");
    print("📡 Uploading to: $uri");

    final request = http.MultipartRequest('POST', uri)
      ..fields['site_id'] = siteId
      ..fields['task_id'] = taskId
      ..fields['remarks'] = remarks;

    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        final ext = file.path.split('.').last.toLowerCase();
        final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
        final isVideo = ['mp4', 'mov', 'mkv'].contains(ext);

        if (isImage) {
          print("🖼️ Adding image: ${file.path}");
          request.files.add(await http.MultipartFile.fromPath(
            'images[]',
            file.path,
            contentType: MediaType('image', ext),
          ));
        } else if (isVideo) {
          print("🎥 Adding video: ${file.path}");
          request.files.add(await http.MultipartFile.fromPath(
            'videos[]',
            file.path,
            contentType: MediaType('video', ext),
          ));
        } else {
          print("⚠️ Skipped unsupported file type: $ext");
        }
      }
    }

    try {
      final response = await request.send();
      print("📤 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final Map<String, dynamic> body = json.decode(res.body);
        print("✅ Response: $body");
        return CommonSuccessResponseModel.fromJson(body);
      } else {
        print("❌ Upload failed. Status: ${response.statusCode}");
        final res = await http.Response.fromStream(response);
        print("Response: ${res.body}");
      }
    } catch (e) {
      print("🚨 Exception while uploading: $e");
    }

    return null;
  }



  Future<DrawingModel?> drawingListApi(int siteId) async {
    final response =
    await ApiService().sendAsync("GET", "drawings/by-site/$siteId", null, true);

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return DrawingModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> drawingUploadApi({
    required String siteId,
    List<File>? files, // multiple files supported
  }) async {
    final uri = Uri.parse("${baseUrl}drawings");
    print("📡 Uploading to: $uri");

    final request = http.MultipartRequest('POST', uri)
      ..fields['site_id'] = siteId;

    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        request.files.add(await http.MultipartFile.fromPath(
          'attachments[]',
          file.path,
        ));
      }
    }

    try {
      final response = await request.send();
      print("📤 Status Code: ${response.statusCode}");

      if (response.statusCode == 200 ||response.statusCode == 201 ) {
        final res = await http.Response.fromStream(response);
        final Map<String, dynamic> body = json.decode(res.body);
        print("✅ Response: $body");
        return CommonSuccessResponseModel.fromJson(body);
      } else {
        print("❌ Upload failed. Status: ${response.statusCode}");
        final res = await http.Response.fromStream(response);
        print("Response: ${res.body}");
      }
    } catch (e) {
      print("🚨 Exception while uploading: $e");
    }

    return null;
  }


  Future<CommonSuccessResponseModel?> deleteDrawingApi(String drawingID) async {
    final response =
    await ApiService().sendAsync("DELETE", "drawing/$drawingID", null, true);
    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }




  Future<ExcelAttendanceDownloadModel?> downloadFileHttp(String id) async {

    var urls = '${baseUrl}/drawings/download/${id}';
    try {


      final response =
      await ApiService().sendAsync("GET", 'drawings/download/${id}', null, true);


      if (response != null) {
        if (response.statusCode == 200) {
          return ExcelAttendanceDownloadModel(
            downloadUrl: urls,
            status: true,
            message: "File downloaded successfully",
          );
        } else {
          return ExcelAttendanceDownloadModel(
            downloadUrl: urls,
            status: false,
            message: "Download failed: ${response.statusCode}",
          );
        }
      }
    }catch (e) {
      return ExcelAttendanceDownloadModel(
        downloadUrl: urls,
        status: false,
        message: "Error: $e",
      );
    }
  }



  Future<QuotationModel?> quotationListApi() async {
    final response = await ApiService().sendAsync("GET", "default-items", null, true);

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);

      if (response.statusCode == 200) {
        return QuotationModel.fromJson(body);
      }
    }

    return null;
  }

  Future<QuotationStoredModel?> quotationStoreApi(Map<String,dynamic> postData) async {
    final response = await ApiService().sendAsync("POST", "quotation/store", postData, true);

    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);

      if (response.statusCode == 200) {
        return QuotationStoredModel.fromJson(body);
      }
    }

    return null;
  }

  Future<ExcelAttendanceDownloadModel?> downloadQuotationPdf(int quotationId) async {
    final response = await ApiService().sendAsync("GET", "quotation/pdf/$quotationId", null, true);
    if (response != null) {
      if (response.statusCode == 200) {
        return ExcelAttendanceDownloadModel.fromJson(json.decode(response.body));
      }
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> sendQuotationWhatsApp(int quotationId, String phoneNumber) async {
    final response = await ApiService().sendAsync("GET", "quotation-whatsapp/$quotationId", null, true);
    if (response != null) {
      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(json.decode(response.body));
      }
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> sendQuotationMail(int quotationId, String email) async {
    final response = await ApiService().sendAsync("GET", "quotation-mail/$quotationId", null, true);
    if (response != null) {
      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(json.decode(response.body));
      }
    }
    return null;
  }




  Future<UserProfileModel?> viewProfile(String role) async {
    final response = await ApiService().sendAsync("GET", "profile", null, true);
    if (response != null) {
      print("VIEW PROFILE RESPONSE: ${response.body}");
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(body);
      }
    }
    return null;
  }






  Future<ProfileUpdateSuccessfullyModel?> updateProfile({
    required String role,
    required String userID,
    required String name,
    required String email,
    String? newPassword,
    String? confirmPassword,
    File? files,
  }) async {
    final uri = Uri.parse("${baseUrl}profile-update");
    print("📡 Updating profile: $uri");

    final request = http.MultipartRequest('POST', uri)
      ..fields['user_id'] = userID
      ..fields['id']    = userID
      ..fields['name']  = name
      ..fields['email'] = email;

    // Only include password fields when the user wants to change the password
    if (newPassword != null && newPassword.isNotEmpty) {
      request.fields['new_password']     = newPassword;
      request.fields['confirm_password'] = confirmPassword ?? '';
    }

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${PreferenceUtils().getSessionToken()}',
    });

    if (files != null) {
      print("📸 Attaching image: ${files.path}");
      request.files.add(await http.MultipartFile.fromPath('image', files.path));
    }

    try {
      final response = await request.send();
      print("📤 Profile update status: ${response.statusCode}");
      final res  = await http.Response.fromStream(response);
      print("📥 Profile update response body preview: ${res.body.length > 100 ? res.body.substring(0, 100) : res.body}");
      
      if (res.body.trim().startsWith('<')) {
        print("❌ Received HTML instead of JSON. The endpoint might be redirecting (e.g. 302).");
        return null;
      }

      final body = json.decode(res.body);
      print("📥 Profile update body: $body");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProfileUpdateSuccessfullyModel.fromJson(body);
      } else {
        print("❌ Profile update failed: ${res.body}");
      }
    } catch (e) {
      print("🚨 Exception updating profile: $e");
    }
    return null;
  }



  // ─── Supervisor Permissions ───────────────────────────────────────────────
  /// Fetches the permission config the admin has set for this supervisor.
  /// Endpoint: GET supervisor-permissions/{supervisorId}
  /// Each value: 1 = visible/enabled, 0 = hidden/disabled.
  Future<SupervisorPermissionsModel?> getSupervisorPermissions(int supervisorId) async {
    final endpoint = "supervisor-permissions/$supervisorId";
    print("🔐 [PERMISSIONS] Calling API: $endpoint");

    final response = await ApiService().sendAsync("GET", endpoint, null, true);

    if (response == null) {
      print("⚠️ [PERMISSIONS] No response received from API");
      return null;
    }

    print("🔐 [PERMISSIONS] Status Code : ${response.statusCode}");
    print("🔐 [PERMISSIONS] Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final model = SupervisorPermissionsModel.fromJson(body);
      final p = model.permissions;

      print("✅ [PERMISSIONS] Supervisor: ${model.supervisor} (id=${model.supervisorId})");

      if (p != null) {
        final s = p.siteManagement;
        print("── site_management ──────────────────────────────");
        print("   view_today_attendance = ${s?.viewTodayAttendance} → ${s?.canViewAttendance == true ? 'VISIBLE' : 'HIDDEN'}");
        print("   view_materials        = ${s?.viewMaterials}       → ${s?.canViewMaterials == true ? 'VISIBLE' : 'HIDDEN'}");
        print("   view_subcontractor    = ${s?.viewSubcontractor}   → ${s?.canViewSubcontractor == true ? 'VISIBLE' : 'HIDDEN'}");
        print("   view_checklist        = ${s?.viewChecklist}       → ${s?.canViewChecklist == true ? 'VISIBLE' : 'HIDDEN'}");
        print("   view_tickets          = ${s?.viewTickets}         → ${s?.canViewTickets == true ? 'VISIBLE' : 'HIDDEN'}");
        print("   view_drawing          = ${s?.viewDrawing}         → ${s?.canViewDrawing == true ? 'VISIBLE' : 'HIDDEN'}");
        print("   view_payment_status   = ${s?.viewPaymentStatus}   → ${s?.canViewPaymentStatus == true ? 'VISIBLE' : 'HIDDEN'}");
        print("── quotation ─────────────────────────────────────");
        print("   canAccessQuotation    = ${p.quotation?.canAccessQuotation}");
        print("── customer_management ──────────────────────────");
        print("   canAccessCustomer     = ${p.customerManagement?.canAccessCustomer}");
        print("── vendor_management ────────────────────────────");
        print("   canAccessVendor       = ${p.vendorManagement?.canAccessVendor}");
        print("── subcontractor_management ─────────────────────");
        print("   canAccessSubcontractor= ${p.subcontractorManagement?.canAccessSubcontractor}");
      } else {
        print("⚠️ [PERMISSIONS] 'permissions' field is null in API response");
      }

      return model;
    } else {
      print("❌ [PERMISSIONS] API returned error: ${response.statusCode} — ${response.body}");
      return null;
    }
  }
  Future<VendorMaterialOrdersModel?> vendorMaterialOrdersApi(int vendorId) async {
    final response = await ApiService().sendAsync("GET", "vendor-material-orders/$vendorId", null, true);
    if (response != null && response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      return VendorMaterialOrdersModel.fromJson(body);
    }
    return null;
  }

  Future<ExcelAttendanceDownloadModel?> vendorPaymentHistoryExportApi(int vendorId) async {
    final response = await ApiService().sendAsync("GET", "payment-history/$vendorId/export", null, true);
    if (response != null && response.statusCode == 200) {
      print("Export API Response body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}");
      print("Export API Content-Type: ${response.headers['content-type']}");

      // Check if response is CSV (backend returns CSV directly)
      // Check body first as it's more reliable
      final trimmedBody = response.body.trim();
      final isCsv = trimmedBody.startsWith('S.No') ||
                     trimmedBody.startsWith('S.No,') ||
                     trimmedBody.contains('Date,"Total Payment"') ||
                     response.headers['content-type']?.contains('csv') == true ||
                     response.headers['content-type']?.contains('text/plain') == true;

      print("Is CSV detected: $isCsv");

      if (isCsv) {
        // Return the API URL as download URL since backend returns CSV directly
        final url = baseUrl.endsWith('/') ? "${baseUrl}payment-history/$vendorId/export" : "$baseUrl/payment-history/$vendorId/export";
        print("Returning download URL: $url");
        return ExcelAttendanceDownloadModel(
          downloadUrl: url,
          status: true,
          message: "Export successful",
        );
      }
      // Try to parse as JSON if not CSV
      try {
        return ExcelAttendanceDownloadModel.fromJson(json.decode(response.body));
      } catch (e) {
        print("JSON parsing failed: $e, treating as CSV download");
        // If JSON parsing fails, treat as direct CSV download
        final url = baseUrl.endsWith('/') ? "${baseUrl}payment-history/$vendorId/export" : "$baseUrl/payment-history/$vendorId/export";
        return ExcelAttendanceDownloadModel(
          downloadUrl: url,
          status: true,
          message: "Export successful",
        );
      }
    }
    return null;
  }

  // Subcontractor APIs
  Future<SubcontractorMaterialOrdersModel?> subcontractorMaterialOrdersApi(int subcontractorId) async {
    final response = await ApiService().sendAsync("GET", "subcontractor-orders/$subcontractorId", null, true);
    if (response != null && response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      return SubcontractorMaterialOrdersModel.fromJson(body);
    }
    return null;
  }

  Future<SubcontractorPaymentDetailsModel?> subcontractorPaymentDetail(int subcontractorId) async {
    final response =
    await ApiService().sendAsync("GET", "subpaydetail/$subcontractorId", null, true);

    if (response != null) {
      print("API Response for subcontractorPaymentDetail: ${response.body}");
      final Map<String, dynamic> body = json.decode(response.body);

      if (response.statusCode == 200) {
        return SubcontractorPaymentDetailsModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> subcontractorPaymentUpdateDetail(Map<String,dynamic> postData) async {
    print("API Request for subcontractorPaymentUpdateDetail: $postData");
    final response =
    await ApiService().sendAsync("POST", "subpaydetail-update", postData, true);

    if (response != null) {
      print("API Response for subcontractorPaymentUpdateDetail: ${response.body}");
      final Map<String, dynamic> body = json.decode(response.body);

      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
  }

  Future<SubContractorPaymentHistoryModel?> subcontractorPaymentHistory(int id) async {
    final response =
    await ApiService().sendAsync("GET", "subpayment-history/$id", null, true);

    if (response != null) {
      print("API Response for subcontractorPaymentHistory: ${response.body}");
      final Map<String, dynamic> body = json.decode(response.body);

      if (response.statusCode == 200) {
        return SubContractorPaymentHistoryModel.fromJson(body);
      }
    }

    return null;
  }

  Future<CommonSuccessResponseModel?> subcontractorPaymentUpdate(Map<String,dynamic> postData) async {
    print("API Request for subcontractorPaymentUpdate: $postData");
    final response =
    await ApiService().sendAsync("POST", "subpayment-add", postData, true);

    if (response != null) {
      print("API Response for subcontractorPaymentUpdate (status: ${response.statusCode}): ${response.body}");
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommonSuccessResponseModel.fromJson(body);
      } else {
        print("subcontractorPaymentUpdate FAILED with status ${response.statusCode}");
      }
    }

    return null;
  }

  Future<ExcelAttendanceDownloadModel?> subcontractorPaymentHistoryExportApi(int subcontractorId) async {
    final response = await ApiService().sendAsync("GET", "subpayment-history/$subcontractorId/export", null, true);
    if (response != null && response.statusCode == 200) {
      print("Export API Response body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}");
      print("Export API Content-Type: ${response.headers['content-type']}");

      // Check if response is CSV (backend returns CSV directly)
      // Check body first as it's more reliable
      final trimmedBody = response.body.trim();
      final isCsv = trimmedBody.startsWith('S.No') ||
                     trimmedBody.startsWith('S.No,') ||
                     trimmedBody.contains('Date,"Total Payment"') ||
                     response.headers['content-type']?.contains('csv') == true ||
                     response.headers['content-type']?.contains('text/plain') == true;

      print("Is CSV detected: $isCsv");

      if (isCsv) {
        // Return the API URL as download URL since backend returns CSV directly
        final url = baseUrl.endsWith('/') ? "${baseUrl}subpayment-history/$subcontractorId/export" : "$baseUrl/subpayment-history/$subcontractorId/export";
        print("Returning download URL: $url");
        return ExcelAttendanceDownloadModel(
          downloadUrl: url,
          status: true,
          message: "Export successful",
        );
      }
      // Try to parse as JSON if not CSV
      try {
        return ExcelAttendanceDownloadModel.fromJson(json.decode(response.body));
      } catch (e) {
        print("JSON parsing failed: $e, treating as CSV download");
        // If JSON parsing fails, treat as direct CSV download
        final url = baseUrl.endsWith('/') ? "${baseUrl}subpayment-history/$subcontractorId/export" : "$baseUrl/subpayment-history/$subcontractorId/export";
        return ExcelAttendanceDownloadModel(
          downloadUrl: url,
          status: true,
          message: "Export successful",
        );
      }
    }
    return null;
  }

  Future<SubcontractorMaterialOrdersModel?> subcontractorOrdersApi(int subcontractorId) async {
    final response = await ApiService().sendAsync("GET", "subcontractor-orders/$subcontractorId", null, true);
    if (response != null) {
      print("API Response for subcontractorOrdersApi: ${response.body}");
      final Map<String, dynamic> body = json.decode(response.body);
      if (response.statusCode == 200) {
        return SubcontractorMaterialOrdersModel.fromJson(body);
      }
    }
    return null;
  }

  // ─── Sales Bill APIs ───────────────────────────────────────────────────────

  /// GET /sales-bill-form/:siteId
  /// Returns site info + the site's active customer to pre-fill the form.
  Future<SalesBillFormModel?> salesBillFormApi(int siteId) async {
    print("🧾 salesBillFormApi REQUEST: sales-bill-form/$siteId");
    final response = await ApiService().sendAsync("GET", "sales-bill-form/$siteId", null, true);
    print("🧾 salesBillFormApi RESPONSE: ${response?.statusCode} → ${response?.body}");
    if (response != null && response.statusCode == 200) {
      return SalesBillFormModel.fromJson(json.decode(response.body));
    }
    return null;
  }

  /// POST /sales-bill-add
  /// Creates the sales bill and returns pdf_url, whatsapp_url, mail_sent.
  Future<SalesBillStoredModel?> salesBillAddApi(Map<String, dynamic> data) async {
    print("🧾 salesBillAddApi REQUEST: $data");
    final response = await ApiService().sendAsync("POST", "sales-bill-add", data, true);
    print("🧾 salesBillAddApi RESPONSE: ${response?.statusCode} → ${response?.body}");
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return SalesBillStoredModel.fromJson(json.decode(response.body));
    }
    return null;
  }

  /// GET /sales-bills/:siteId
  Future<dynamic> salesBillHistoryApi(int siteId) async {
    final response = await ApiService().sendAsync("GET", "sales-bills/$siteId", null, true);
    if (response != null && response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  /// DELETE /sales-bill-delete/:id
  Future<CommonSuccessResponseModel?> deleteSalesBillApi(int id) async {
    final response = await ApiService().sendAsync("DELETE", "sales-bill-delete/$id", null, true);
    if (response != null && response.statusCode == 200) {
      return CommonSuccessResponseModel.fromJson(json.decode(response.body));
    }
    return null;
  }


  /// GET /subcontractor-petty-cash/{siteId} or /subcontractor-rental-management/{siteId}
  Future<SubContractorPaymentHistoryModel?> siteSubcontractorPaymentHistoryApi(int siteId, String type) async {
    final typeSlug = type.toLowerCase().replaceAll(' ', '-');
    final response = await ApiService().sendAsync("GET", "subcontractor-$typeSlug/$siteId", null, true);
    print("🔍 sitePaymentHistoryApi [subcontractor-$typeSlug/$siteId]: ${response?.statusCode} → ${response?.body}");
    if (response != null && response.statusCode == 200) {
      return SubContractorPaymentHistoryModel.fromJson(json.decode(response.body));
    }
    return null;
  }

  /// POST /subpayment-add — adds a payment for petty-cash or rental-management
  Future<CommonSuccessResponseModel?> siteAddPaymentApi(Map<String, dynamic> data) async {
    print("💳 siteAddPaymentApi REQUEST: $data");
    final response = await ApiService().sendAsync("POST", "subpayment-add", data, true);
    print("💳 siteAddPaymentApi RESPONSE: ${response?.statusCode} → ${response?.body}");
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(json.decode(response.body));
    }
    return null;
  }



  /// GET /subcontractor-{typeSlug}/{siteId}/export
  Future<ExcelAttendanceDownloadModel?> sitePaymentHistoryExportApi(int siteId, String type) async {
    final typeSlug = type.toLowerCase().replaceAll(' ', '-');
    final response = await ApiService().sendAsync("GET", "subcontractor-$typeSlug/$siteId/export", null, true);
    if (response != null && response.statusCode == 200) {
      final url = "${baseUrl}subcontractor-$typeSlug/$siteId/export";
      return ExcelAttendanceDownloadModel(downloadUrl: url);
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> addSubcontractorTypeApi(String name, dynamic imageFile) async {
    final uri = Uri.parse("${baseUrl}subcontractor-type-add");
    print("🔍 addSubcontractorTypeApi REQUEST: POST $uri  name=$name");

    final token = PreferenceUtils().getSessionToken();
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request.fields['name'] = name;

    if (imageFile != null && imageFile.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = json.decode(response.body);
        return CommonSuccessResponseModel.fromJson(body);
      }
    } catch (e) {
      print("❌ addSubcontractorTypeApi EXCEPTION: $e");
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> addMaterialTypeApi(String name, dynamic imageFile) async {
    final uri = Uri.parse("${baseUrl}material-type-add");
    print("≡ƒöì addMaterialTypeApi REQUEST: POST $uri  name=$name  hasImage=${imageFile != null}");

    final token = PreferenceUtils().getSessionToken();
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request.fields['name'] = name;

    if (imageFile != null && imageFile.path.isNotEmpty) {
      print("≡ƒôÄ addMaterialTypeApi: attaching image ${imageFile.path}");
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print("≡ƒôÑ addMaterialTypeApi RESPONSE: statusCode=${response.statusCode}");
      print("≡ƒôÑ addMaterialTypeApi BODY: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = json.decode(response.body);
        return CommonSuccessResponseModel.fromJson(body);
      } else {
        print("Γ¥î addMaterialTypeApi ERROR: ${response.statusCode} ΓåÆ ${response.body}");
      }
    } catch (e) {
      print("Γ¥î addMaterialTypeApi EXCEPTION: $e");
    }
    return null;
  }

  /// DELETE /api/material-type-delete/{id}
  /// Deletes a DYNAMIC (user-added) material type by numeric ID.
  Future<CommonSuccessResponseModel?> deleteDynamicMaterialTypeApi(int id) async {
    final endpoint = "material-type-delete/$id";
    print("≡ƒöì deleteDynamicMaterialTypeApi REQUEST: DELETE $endpoint  id=$id");
    final response = await ApiService().sendAsync("DELETE", endpoint, null, true);
    print("≡ƒôÑ deleteDynamicMaterialTypeApi RESPONSE: statusCode=${response?.statusCode}");
    print("≡ƒôÑ deleteDynamicMaterialTypeApi BODY: ${response?.body}");
    if (response != null) {
      try {
        final Map<String, dynamic> body = json.decode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return CommonSuccessResponseModel.fromJson(body);
        } else {
          print("Γ¥î deleteDynamicMaterialTypeApi ERROR: ${response.statusCode} ΓåÆ ${response.body}");
        }
      } catch (e) {
        print("Γ¥î deleteDynamicMaterialTypeApi PARSE ERROR: $e");
      }
    }
    return null;
  }

  /// DELETE /api/material-type-hide/{slug}
  /// Hides a BUILT-IN material card from the grid by its slug (e.g. "bricks", "cement").
  Future<CommonSuccessResponseModel?> hideBuiltInMaterialTypeApi(String slug) async {
    final endpoint = "material-type-hide/$slug";
    print("≡ƒöì hideBuiltInMaterialTypeApi REQUEST: DELETE $endpoint  slug=$slug");
    final response = await ApiService().sendAsync("DELETE", endpoint, null, true);
    print("≡ƒôÑ hideBuiltInMaterialTypeApi RESPONSE: statusCode=${response?.statusCode}");
    print("≡ƒôÑ hideBuiltInMaterialTypeApi BODY: ${response?.body}");
    if (response != null) {
      try {
        final Map<String, dynamic> body = json.decode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return CommonSuccessResponseModel.fromJson(body);
        } else {
          print("Γ¥î hideBuiltInMaterialTypeApi ERROR: ${response.statusCode} ΓåÆ ${response.body}");
        }
      } catch (e) {
        print("Γ¥î hideBuiltInMaterialTypeApi PARSE ERROR: $e");
      }
    }
    return null;
  }

  // ΓöÇΓöÇΓöÇ Unit Master APIs ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ

  Future<UnitMasterListResponse?> unitMasterListApi() async {
    print("📋 unitMasterListApi REQUEST: unit-master");
    final response = await ApiService().sendAsync("GET", "unit-master", null, true);
    print("📋 unitMasterListApi RESPONSE: ${response?.statusCode} → ${response?.body}");
    if (response != null && response.statusCode == 200) {
      return UnitMasterListResponse.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> unitMasterAddApi(Map<String, dynamic> data) async {
    print("≡ƒôï unitMasterAddApi REQUEST: $data");
    final response = await ApiService().sendAsync("POST", "unit-add", data, true);
    print("≡ƒôï unitMasterAddApi RESPONSE: ${response?.statusCode} ΓåÆ ${response?.body}");
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> unitMasterUpdateApi(int id, Map<String, dynamic> data) async {
    print("≡ƒôï unitMasterUpdateApi REQUEST: unit-update/$id with data $data");
    final response = await ApiService().sendAsync("PATCH", "unit-update/$id", data, true);
    print("≡ƒôï unitMasterUpdateApi RESPONSE: ${response?.statusCode} ΓåÆ ${response?.body}");
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> unitMasterDeleteApi(int id) async {
    print("≡ƒôï unitMasterDeleteApi REQUEST: unit-delete/$id");
    final response = await ApiService().sendAsync("DELETE", "unit-delete/$id", null, true);
    print("≡ƒôï unitMasterDeleteApi RESPONSE: ${response?.statusCode} ΓåÆ ${response?.body}");
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(json.decode(response.body));
    }
    return null;
  }


  /// PATCH /payment-update/{id} ΓÇö updates a vendor payment row
  Future<CommonSuccessResponseModel?> updatePaymentApi(int id, Map<String, dynamic> data) async {
    final endpoint = "payment-update/$id";
    print("Γ£Å∩╕Å  updatePaymentApi REQUEST  ΓåÆ PATCH $endpoint  body=$data");
    final response = await ApiService().sendAsync("PATCH", endpoint, data, true);
    print("Γ£Å∩╕Å  updatePaymentApi RESPONSE ΓåÆ statusCode=${response?.statusCode}  body=${response?.body}");
    if (response != null && response.statusCode == 200) {
      try {
        return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
      } catch (e) {
        print("Γ£Å∩╕Å  updatePaymentApi PARSE ERROR: $e");
      }
    }
    return null;
  }

  /// DELETE /payment-delete/{id} ΓÇö deletes a vendor payment row
  Future<CommonSuccessResponseModel?> deletePaymentApi(int id) async {
    final endpoint = "payment-delete/$id";
    print("≡ƒùæ∩╕Å  deletePaymentApi REQUEST  ΓåÆ DELETE $endpoint");
    final response = await ApiService().sendAsync("DELETE", endpoint, null, true);
    print("≡ƒùæ∩╕Å  deletePaymentApi RESPONSE ΓåÆ statusCode=${response?.statusCode}  body=${response?.body}");
    if (response != null && (response.statusCode == 200 || response.statusCode == 302)) {
      try {
        if (response.statusCode == 302) {
          return CommonSuccessResponseModel(status: true, message: 'Payment deleted successfully');
        }
        return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
      } catch (e) {
        print("≡ƒùæ∩╕Å  deletePaymentApi PARSE ERROR: $e");
      }
    }
    return null;
  }


  Future<CommonSuccessResponseModel?> updateSitePaymentApi(int id, Map<String, dynamic> data) async {
    final response = await ApiService().sendAsync("POST", "site-payment-update/$id", data, true);
    if (response != null) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> deleteSitePaymentApi(int id) async {
    final response = await ApiService().sendAsync("DELETE", "site-payment-delete/$id", null, true);
    if (response != null) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }
    return null;
  }


  // ΓöÇΓöÇΓöÇ RECREATED MISSING METHODS ΓöÇΓöÇΓöÇ

  Future<CommonSuccessResponseModel?> updateMaterialApi(int materialId, Map<String, dynamic> data, {dynamic attachment}) async {
    final token = PreferenceUtils().getSessionToken();
    final endpoint = "${baseUrl}material-update/$materialId";

    try {
      final uri = Uri.parse(endpoint);
      var request = http.MultipartRequest('POST', uri);

      data.forEach((key, value) {
        if (value != null) {
          if (key == 'items') {
            try {
              final decoded = value is String ? jsonDecode(value) : value;
              if (decoded is List) {
                for (int i = 0; i < decoded.length; i++) {
                  final itm = decoded[i];
                  if (itm is Map) {
                    itm.forEach((subKey, subVal) {
                      request.fields['items[$i][$subKey]'] = subVal?.toString() ?? '';
                    });
                  }
                }
                return;
              }
            } catch (_) {}
          }
          request.fields[key] = value.toString();
        }
      });

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (attachment != null && attachment is File && attachment.path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('attachment', attachment.path));
      }

      print("📤 updateMaterialApi REQUEST to $endpoint: ${request.fields}");
      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);
      print("📥 updateMaterialApi RESPONSE from $endpoint: ${res.statusCode} -> ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        return CommonSuccessResponseModel.fromJson(jsonDecode(res.body));
      } else {
        try {
          final json = jsonDecode(res.body);
          if (json['status'] == true || json['status'] == 1 || json['success'] == true) {
            return CommonSuccessResponseModel.fromJson(json);
          }
          if (json.containsKey('errors')) {
            final errors = json['errors'];
            if (errors is Map && errors.isNotEmpty) {
              final firstErr = errors.values.first;
              final errMsg = firstErr is List ? firstErr.first.toString() : firstErr.toString();
              showToastMessage(errMsg);
            }
          } else if (json.containsKey('message')) {
            showToastMessage(json['message'].toString());
          }
        } catch (_) {}
      }
    } catch (e) {
      print("Exception in updateMaterialApi ($endpoint): $e");
    }
    return null;
  }

  Future<bool> saveLocation(double lat, double lng) async {
    final response = await ApiService().sendAsync("POST", "save-location", {'latitude': lat, 'longitude': lng}, true);
    return response != null && (response.statusCode == 200 || response.statusCode == 201);
  }

  Future<dynamic> checkDateApi(int siteId, String formattedDate) async {
    final response = await ApiService().sendAsync("POST", "check-date", {'site_id': siteId, 'date': formattedDate}, true);
    return response != null ? jsonDecode(response.body) : null;
  }

  Future<CommonSuccessResponseModel?> deleteAttendanceByDateApi(int siteId, String formattedDate) async {
    final response = await ApiService().sendAsync("DELETE", "attendance-delete-date/$siteId/$formattedDate", null, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> updateWagesRowApi(Map<String, dynamic> data) async {
    final response = await ApiService().sendAsync("PATCH", "update-wages-row", data, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> deleteWagesRowApi(Map<String, dynamic> data) async {
    final response = await ApiService().sendAsync("POST", "wages/delete", data, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> editStageApi(int id, String newName) async {
    final response = await ApiService().sendAsync("POST", "checklist-stage-update/$id", {'stage': newName}, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> deleteStageApi(int id) async {
    final response = await ApiService().sendAsync("DELETE", "checklist-stage/$id", null, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> addTaskApi(int checklistId, String taskName) async {
    final response = await ApiService().sendAsync("POST", "checklist-task-add", {'checklist_id': checklistId, 'task_name': taskName}, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> editTaskApi(int id, String newName) async {
    final response = await ApiService().sendAsync("POST", "checklist-task-update/$id", {'task_name': newName}, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> deleteTaskApi(int id) async {
    final response = await ApiService().sendAsync("DELETE", "checklist-task/$id", null, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> reorderStagesApi(List<int> orderedIds) async {
    final response = await ApiService().sendAsync("POST", "checklist-stages-reorder", {'checklist_ids': orderedIds}, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> reorderTasksApi(List<int> orderedIds) async {
    final response = await ApiService().sendAsync("POST", "checklist-tasks-reorder", {'task_ids': orderedIds}, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> updateSubPaymentApi(int id, Map<String, dynamic> data) async {
    final response = await ApiService().sendAsync("PATCH", "subpayment-update/$id", data, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> deleteSubPaymentApi(int id) async {
    final response = await ApiService().sendAsync("DELETE", "subpayment-delete/$id", null, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 302)) {
      if (response.statusCode == 302) return CommonSuccessResponseModel(status: true, message: 'Deleted successfully');
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }



  Future<CommonSuccessResponseModel?> deleteSubcontractorTypeApi(int id) async {
    final response = await ApiService().sendAsync("DELETE", "subcontractor-type-delete/$id", null, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // --- Purchase Bill APIs ---
  Future<PurchaseBillFormModel?> purchaseBillFormApi(int siteId) async {
    final response = await ApiService().sendAsync("GET", "purchase-bill-form/$siteId", null, true);
    if (response != null && response.statusCode == 200) {
      return PurchaseBillFormModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<PurchaseBillListModel?> purchaseBillsListApi(int siteId) async {
    final response = await ApiService().sendAsync("GET", "purchase-bills/$siteId", null, true);
    if (response != null && response.statusCode == 200) {
      return PurchaseBillListModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<PurchaseBillStoredModel?> purchaseBillAddApi(Map<String, dynamic> payload) async {
    final response = await ApiService().sendAsync("POST", "purchase-bill-add", payload, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return PurchaseBillStoredModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<PurchaseBillDetailModel?> purchaseBillDetailApi(int id) async {
    final response = await ApiService().sendAsync("GET", "purchase-bill/$id", null, true);
    if (response != null && response.statusCode == 200) {
      return PurchaseBillDetailModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> purchaseBillUpdateApi(int id, Map<String, dynamic> payload) async {
    final response = await ApiService().sendAsync("PATCH", "purchase-bill-update/$id", payload, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> purchaseBillDeleteApi(int id) async {
    final response = await ApiService().sendAsync("DELETE", "purchase-bill-delete/$id", null, true);
    if (response != null && response.statusCode == 200) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // --- Material Estimation APIs ---
  Future<MaterialEstimationFormModel?> materialEstimationFormApi(int siteId) async {
    final response = await ApiService().sendAsync("GET", "material-estimation-form/$siteId", null, true);
    if (response != null && response.statusCode == 200) {
      return MaterialEstimationFormModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> materialEstimationAddApi(Map<String, dynamic> payload) async {
    final response = await ApiService().sendAsync("POST", "material-estimation-add", payload, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<MaterialEstimationDetailModel?> materialEstimationDetailApi(int id) async {
    final response = await ApiService().sendAsync("GET", "material-estimation/$id", null, true);
    if (response != null && response.statusCode == 200) {
      return MaterialEstimationDetailModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> materialEstimationUpdateApi(int id, Map<String, dynamic> payload) async {
    final response = await ApiService().sendAsync("PATCH", "material-estimation-update/$id", payload, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> materialEstimationDeleteApi(int id) async {
    final response = await ApiService().sendAsync("DELETE", "material-estimation-delete/$id", null, true);
    if (response != null && response.statusCode == 200) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }



  Future<dynamic> getSupervisorLocation(int id) async {
    final response = await ApiService().sendAsync("GET", "supervisor-location/$id", null, true);
    return response != null ? jsonDecode(response.body) : null;
  }

  Future<dynamic> getSupervisorLocations() async {
    final response = await ApiService().sendAsync("GET", "supervisor-locations", null, true);
    return response != null ? jsonDecode(response.body) : null;
  }

  Future<QuotationHistoryModel?> quotationHistoryApi(String mobileNo) async {
    final response = await ApiService().sendAsync("GET", "quotation-history?mobile_no=$mobileNo", null, true);
    if (response != null && response.statusCode == 200) {
      return QuotationHistoryModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<MaterialRequestListModel?> getMaterialRequestsApi(int siteId) async {
    final response = await ApiService().sendAsync("GET", "material-request-list/$siteId", null, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return MaterialRequestListModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> approveMaterialRequestApi(int id) async {
    final response = await ApiService().sendAsync("POST", "material-request-approve/$id", null, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> rejectMaterialRequestApi(int id, {String? adminRemark}) async {
    final response = await ApiService().sendAsync("POST", "material-request-reject/$id", {'admin_remark': adminRemark}, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> addCustomer({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String state,
    required String city,
    required String zipCode,
    required String gst,
    required int createdBy,
    required String status,
  }) async {
    final Map<String, dynamic> data = {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'state': state,
      'city': city,
      'zip_code': zipCode,
      'gst': gst,
      'created_by': createdBy,
      'status': status,
    };
    final response = await ApiService().sendAsync("POST", "customer-add", data, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // --- Terms and Conditions APIs ---
  Future<TermsConditionModel?> getTermsConditions() async {
    final response = await ApiService().sendAsync("GET", "terms-condition", null, true);
    if (response != null && response.statusCode == 200) {
      return TermsConditionModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> addTermsCondition(String title, String description) async {
    final data = {
      'title': title,
      'description': description,
    };
    final response = await ApiService().sendAsync("POST", "terms-condition-add", data, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> updateTermsCondition(int id, String title, String description) async {
    final data = {
      'title': title,
      'description': description,
    };
    final response = await ApiService().sendAsync("POST", "terms-condition-update/$id", data, true);
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CommonSuccessResponseModel?> deleteTermsCondition(int id) async {
    final response = await ApiService().sendAsync("DELETE", "terms-condition-delete/$id", null, true);
    if (response != null && response.statusCode == 200) {
      return CommonSuccessResponseModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<List<String>> termsConditionSearchApi(String term) async {
    final query = Uri.encodeComponent(term);
    print('--- DEBUG: termsConditionSearchApi ---');
    print('URL: terms-condition-search?term=$query');
    final response = await ApiService().sendAsync("GET", "terms-condition-search?term=$query", null, true);
    print('Status: ${response?.statusCode}');
    if (response != null && response.statusCode == 200) {
      print('Body: ${response.body}');
      final body = jsonDecode(response.body);
      if (body['data'] is List) {
        final parsed = (body['data'] as List).map((e) {
          if (e is String) return e;
          if (e is Map && e['title'] != null) return e['title'].toString();
          return e.toString();
        }).toList();
        print('Parsed list: $parsed');
        return parsed;
      }
    }
    return [];
  }

  Future<String> termsConditionDescriptionApi(String title) async {
    final query = Uri.encodeComponent(title);
    print('--- DEBUG: termsConditionDescriptionApi ---');
    print('URL: terms-condition-description?title=$query');
    final response = await ApiService().sendAsync("GET", "terms-condition-description?title=$query", null, true);
    print('Status: ${response?.statusCode}');
    if (response != null && response.statusCode == 200) {
      print('Body: ${response.body}');
      final body = jsonDecode(response.body);
      String parsedDesc = '';
      if (body['description'] != null) {
        parsedDesc = body['description'].toString();
      } else if (body['data'] != null) {
        if (body['data'] is String) parsedDesc = body['data'];
        if (body['data'] is Map && body['data']['description'] != null) parsedDesc = body['data']['description'].toString();
      }
      print('Parsed description: $parsedDesc');
      return parsedDesc;
    }
    return '';
  }

}
