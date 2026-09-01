import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  String baseUrl = 'http://pojoinfra360.pojotech.in/api/';
  // login
  var loginRes = await http.post(
    Uri.parse(baseUrl + 'login'),
    body: {
      "mobile_no": "7540060694", 
      "password": "password"
    }
  );
  var data = jsonDecode(loginRes.body);
  String token = data['data']['token'];
  print('Token: $token');

  var res = await http.post(
    Uri.parse(baseUrl + 'material/4/bricks'), // siteId=4, maybe it's 1? we'll try
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json'
    },
    body: {
      "monthYear": "2026-07"
    }
  );
  print('Res: ${res.body}');
}

