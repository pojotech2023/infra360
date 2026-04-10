import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToastMessage(String message, {ToastGravity gravity = ToastGravity.CENTER}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: gravity,
    backgroundColor: Colors.black87,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}