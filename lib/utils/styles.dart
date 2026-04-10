import 'package:flutter/material.dart';
import 'package:raptor_pro/utils/res/colors.dart';

class AppTheme{
  static final ThemeData appTheme =  ThemeData(
    fontFamily: "Poppins",
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColor.buttonBlue
    ),
    scaffoldBackgroundColor: Colors.white, // Set background to white
    primaryColor: Colors.white, // Set primary color to white
    colorScheme: ColorScheme.light(
      primary: AppColor.buttonBlue, // Main color
      secondary: Colors.black, // Accent color (you can choose)
      surface: Colors.white,
      onPrimary: Colors.white, // Text/Icon color on white buttons
      onSecondary: Colors.white, // Text color on secondary buttons
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,

      shape: Border(
        bottom: BorderSide(
          color: AppColor.appBarBottomColor, // Your desired line color
          width: 1.5,
        ),
      ),

      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );
}