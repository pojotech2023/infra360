# coding=utf-8
import os
import re

file_path = r'c:\Users\pojot\StudioProjects\Pojo Infra360\lib\api\api_data.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

pattern = re.compile(r'Future<CommonSuccessResponseModel\?> addWagesApi.*?return null;\s*\}', re.DOTALL)

replacement = '''Future<CommonSuccessResponseModel?> addWagesApi(Map<String,dynamic>data,String type, {File? checkInFile, File? checkOutFile}) async {
    var url = type =="1" ?  'add-wages' : type =="2"?'attendance/update':"update-attendance-wages";

    print("📤 Attendance Update API Call");
    print("📤 URL: \");
    print("📤 Type: \");
    
    if (checkInFile != null || checkOutFile != null) {
      final uri = Uri.parse("\\");
      final token = PreferenceUtils().getSessionToken();
      final request = http.MultipartRequest('POST', uri);
      
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer \',
      });
      
      if (checkInFile != null && checkInFile.path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('check_in_file', checkInFile.path));
      }
      if (checkOutFile != null && checkOutFile.path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('check_out_file', checkOutFile.path));
      }
      
      try {
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return CommonSuccessResponseModel.fromJson(json.decode(response.body));
        }
      } catch (e) {
        print("❌ Error: \");
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
          print("❌ Error: \");
        }
      }
      return null;
    }
  }'''

new_content = pattern.sub(replacement, content, count=1)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Patched api_data.dart")
