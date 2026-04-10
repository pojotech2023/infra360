import 'dart:convert';
import 'package:http/http.dart' as http;
void main() async {
  try {
    var body = json.encode({
      'mobile_no': '9677666100', 
      'password': 'Admin@123'
    });
    var response3 = await http.post(
      Uri.parse('https://infra360.pojotech.in/api/login'), 
      body: body,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
    );
    print("URL 3 (9677): " + response3.statusCode.toString());
    print(response3.body);
  } catch (e) {
    print("Error 3: " + e.toString());
  }
}
