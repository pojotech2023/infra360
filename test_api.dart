import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  String baseUrl = 'https://infra360.pojotech.in/api/';
  String token = 'YOUR_TOKEN_HERE'; // Need to login first

  // Let's perform a login to get the token
  var loginResponse = await http.post(
    Uri.parse(baseUrl + 'login'),
    body: {
      "mobile_no": "9876543210", // Just a guess or we find the token
      "password": "password123"
    }
  );
  print(loginResponse.body);
}
