import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';

import 'package:http/http.dart'as http;
import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/service/shared_preference_service.dart';
class ApiService{

  Future<Response?> sendAsync(String method, String path, Object? body, bool authed,) async {
    String appBaseUrl = baseUrl;
    var url = Uri.parse(appBaseUrl).resolve(path);


    print("URL : ${url}");

    var requestMessage = Request(method, url);
    Map<String, String> headerParams = {};
    headerParams["Content-Type"] = "application/json";


    try {
      // Handle request body
      if (body != null) {
        if (body is String) {
          headerParams["Content-Type"] = "application/x-www-form-urlencoded";
          requestMessage.body = body;
        } else if (body is MultipartRequest) {
          headerParams["Content-Type"] = "multipart/form-data";
          headerParams['Accept'] = "application/json";
          print("Multipart");
        } else {
          headerParams['Accept'] = "application/json";
          headerParams["Content-Type"] = "application/json";
          requestMessage.body = serialize(body);
        }
      }

      // Handle Authorization
      if (authed) {
        headerParams['Authorization'] =  "Bearer ${PreferenceUtils().getSessionToken()}";
      }

      requestMessage.headers.addAll(headerParams);

      var client = Client();
      Response? response;

      try {
        // Send the appropriate request based on the method
        switch (method) {
          case "POST":
            response = await client.post(url, headers: requestMessage.headers, body: requestMessage.body);
            break;
          case "GET":
            response = await client.get(url, headers: requestMessage.headers);
            break;
          case "PUT":
            response = await client.put(url, headers: requestMessage.headers, body: requestMessage.body);
            break;
          case "PATCH":
            response = await client.patch(url, headers: requestMessage.headers, body: requestMessage.body);
            break;
          case "DELETE":
            response = await client.delete(url, headers: requestMessage.headers);
            break;
          case "HEAD":
            response = await client.head(url, headers: requestMessage.headers);
            break;
          default:
            throw UnsupportedError('Method $method not supported');
        }

        debugPrint("Status code: ${response?.statusCode}");

      } on HttpException catch (e) {
        print("HttpException: ${e.toString()}");
        return null;
      } on SocketException catch (e) {
        print("SocketException: ${e.toString()}");
      //  errorToast("Socket Exception. Try again later.");
        return null;
      }

      // Check if the response is valid
      if (response == null) {
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else if (response.statusCode == 401) {
        return response;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        return response;
      }

    } finally {
      // Any cleanup actions if needed
    }
    return null;
  }

}
String serialize(Object obj) {
  String serialized = '';
  if (obj == null) {
    serialized = '';
  } else {
    serialized = json.encode(obj);
  }
  return serialized;
}