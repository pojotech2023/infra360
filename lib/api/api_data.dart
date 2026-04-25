import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/model/agent_list_model.dart';
import 'package:raptor_pro/model/attendance_list_model.dart';
import 'package:raptor_pro/model/bricks_model.dart';
import 'package:raptor_pro/model/common_success_model.dart';
import 'package:raptor_pro/model/customer_model.dart';
import 'package:raptor_pro/model/login_response.dart';
import 'package:raptor_pro/model/material_list_model.dart';
import 'package:raptor_pro/model/other_utilities_model.dart';
import 'package:raptor_pro/model/property_list_model.dart';
import 'package:raptor_pro/model/site_management_model.dart';
import 'package:raptor_pro/model/subcontractor_dashboard_model.dart';
import 'package:raptor_pro/model/subcontractor_payment_history_model.dart';
import 'package:raptor_pro/model/supervisor_list_model.dart';
import 'package:raptor_pro/model/user_profile_model.dart';
import 'package:raptor_pro/model/vendor_dashboard_model.dart';
import 'package:raptor_pro/model/vendor_management_model.dart';
import 'package:raptor_pro/model/vendor_model.dart';
import 'package:raptor_pro/model/vendor_payment_details_model.dart';
import 'package:raptor_pro/model/vendor_payment_history_model.dart';
import 'package:raptor_pro/model/site_payment_summary_model.dart';
import 'package:raptor_pro/model/site_payment_history_model.dart';
import 'package:raptor_pro/service/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:raptor_pro/service/shared_preference_service.dart';

import '../model/attendance_datewise_model.dart';
import '../model/checklist_model.dart';
import '../model/drawing_model.dart';
import '../model/employee_list_model.dart';
import '../model/excel_attendance_download.dart';
import '../model/material_request_success_model.dart';
import '../model/my_subcontractor_list_model.dart';
import '../model/profile_update_success_model.dart';
import '../model/quotation_model.dart';
import '../model/quotation_stored_model.dart';
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

    final request = http.MultipartRequest('POST', uri)
      ..fields.addAll(input);

    // ✅ Add Authorization header
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print("Input ${input}");
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



  Future<MaterialResponse?> materialListApi(int sideId) async {
    final response =
    await ApiService().sendAsync("GET", "material-detail/$sideId", null, true);

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

  Future<SubcontractorResponse?> subcontractorListApi(int sideId) async {
    final response = await ApiService().sendAsync("GET", "subcontractor-detail/$sideId", null, true);

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


  Future<CommonSuccessResponseModel?> addUtilities({
    required String siteId,
    required String amount,
    required String remarks,
    required File files,
  }) async {




    var uri = Uri.parse("${baseUrl}utilities-add");


print("uri ${uri}");
    var request = http.MultipartRequest('POST', uri);
    request.fields['site_id'] = siteId.toString();
    request.fields['amount'] = amount;
    request.fields['remarks'] = remarks;


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

    print("queryParams ${queryParams}");

    final uri = Uri(path: basePath, queryParameters: queryParams);
    final pathWithQuery = uri.toString();

    final response =
    await ApiService().sendAsync("GET", pathWithQuery, null, true);



    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


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


  Future<ExcelAttendanceDownloadModel?> attendanceExcelDownload(int sideId,String ?month,int ?weekId,String ?date) async {


   // https://ssbuildcraft.in/admin/public/api/attendance?site_id=1&month=2025-10&week=5
    String basePath  ="attendance";

    final queryParams = <String, String>{};


    var convertmonth = convertMonthFormat(month!);

    if (sideId != null && sideId.toString().isNotEmpty) queryParams['site_id'] = sideId.toString();
    if (month != null && month.isNotEmpty) queryParams['month'] = convertmonth;
    if (weekId != null ) queryParams['week'] = weekId.toString(); // 👈 not weekId — match "week"
    if (date != null && date.isNotEmpty) queryParams['date'] = date;

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


  Future<CommonSuccessResponseModel?> addWagesApi(Map<String,dynamic>data,String type) async {


   var url = type =="1" ?  'add-wages' : type =="2"?'add-attendance':"update-attendance-wages";

   print("url ${url}");
   print("DAta ${data}");

    final response =
    await ApiService().sendAsync("POST", url, data, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);
print("RESPONSE : ${response}");

      if (response.statusCode == 200) {
        return CommonSuccessResponseModel.fromJson(body);
      }
    }

    return null;
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
    required File files,
  }) async {
    final uri = Uri.parse("${baseUrl}subutilities-add");
    print("📡 Uploading to: $uri");

    final token = PreferenceUtils().getSessionToken(); 

    final request = http.MultipartRequest('POST', uri)
      ..fields['site_id'] = siteId
      ..fields['amount'] = amount
      ..fields['remarks'] = remarks;

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


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return VendorDashboardModel.fromJson(body);
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

  Future<CommonSuccessResponseModel?> addProperty(String name,String location,String type,
      String amount,String reMarks,File ?file) async {
    var uri = Uri.parse("${baseUrl}property-add");


    print("uri ${uri}");
    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] = name;
    request.fields['location'] = location;
    request.fields['type'] = type;
    request.fields['amount'] = amount;
    request.fields['remarks'] = reMarks;
    request.headers['Authorization'] = 'Bearer ${PreferenceUtils().getSessionToken()}';

    if(file!=null){
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        file!.path,
      ),
    );
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

    //final token = PreferenceUtils().getSessionToken();
   // print("🔑 Token: $token");

    final request = http.MultipartRequest('POST', uri)
      ..fields['ticket_id'] = ticketId
      ..fields['site_id'] = siteId
      ..fields['sender_type'] = senderType;

    if (message?.isNotEmpty ?? false) request.fields['message'] = message!;
   // request.headers['Authorization'] = 'Bearer $token';
  //  request.followRedirects = false; // Prevent hidden redirects

    if (file != null) {
      final ext = file.path.split('.').last.toLowerCase();
      final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
      final isVideo = ['mp4', 'mov', 'mkv'].contains(ext);

      final fieldKey = 'attachment'; // ✅ depends on backend
      final type = isImage
          ? MediaType('image', ext)
          : isVideo
          ? MediaType('video', ext)
          : null;

      if (type != null) {
        request.files.add(await http.MultipartFile.fromPath(fieldKey, file.path, contentType: type));
      } else {
        print("⚠️ Unsupported file type: $ext");
        return null;
      }
    }

    final response = await request.send();

    print("📤 Status: ${response.statusCode}");
    print("📤 Redirect: ${response.isRedirect}");
    print("📤 Headers: ${response.headers}");

    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final Map<String, dynamic> body = json.decode(res.body);
      print("✅ Response: $body");
      return CommonSuccessResponseModel.fromJson(body);
    } else {
      print("❌ Upload failed. Redirected to: ${response.headers['location']}");
    }

    return null;
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



  Future<UserProfileModel?> viewProfile() async {


    final response =
    await ApiService().sendAsync("GET", "profile", null, true);


    if (response != null) {
      final Map<String, dynamic> body = json.decode(response.body);


      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(body);
      }
    }

    return null;
  }






  Future<ProfileUpdateSuccessfullyModel?> updateProfile({
    required String userID,
    required String name,
    required String email,
    File? files,
  }) async {
    final uri = Uri.parse("${baseUrl}profile-update");
    print("📡 Uploading to: $uri");

    final request = http.MultipartRequest('POST', uri)
      ..fields['user_id'] = userID
      ..fields['name'] = name
      ..fields['email'] = email;

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${PreferenceUtils().getSessionToken()}',
    });

    print("REQUEST HEADER ${request.headers}");

    // ✅ SAFE check — no crash if null
    if (files != null) {
      print("📸 Attaching image: ${files.path}");

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        files.path,
      ));
    } else {
      print("ℹ️ No image selected → Do NOT upload file");
    }

    try {
      final response = await request.send();
      print("📤 Status Code: ${response.statusCode}");

      final res = await http.Response.fromStream(response);
      print("📥 Response: ${res.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = json.decode(res.body);
        return ProfileUpdateSuccessfullyModel.fromJson(body);
      } else {
        print("❌ Upload failed. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("iiiiiiiii");
      print("🚨 Exception: $e");
    }

    return null;
  }



}

