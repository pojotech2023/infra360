import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/images.dart';

class ConstantData {

  static final List<String> paymentMode = [
    "Online","Check","Net Banking","Cash"
  ];


  static final List<String> area = [
    "Sqft","Cft","Lit","Nos","Rft","Ls"
  ];


  static final List<String> siteStatus = [
    "Quoted","Ongoing","Completed"
  ];
  static final List<String> approveRequest = [
    "Approved","Rejected"
  ];

  static final List<String> deliveryNeededBy = [
    "Immediate","Later","One Week"
  ];

/*  static final List<String> allMaterialKeys = [
    "bricks",
    "sand",
    "cement",
    "electricalwire",
    "plumber",
    "tea",
    "watercan",
    "lorrywater",
    "tiles",
    "granite",
    "jally",
    "welding",
    "lift",
    "rcconcrete",
    "transport",
    "interior",
    "painting",
  ];

   static final Map<String, String> materialImages = {
    "bricks": Images.brick,
    "sand": Images.sand,
    "cement":  Images.cement,
    "electricalwire":  Images.electricalCable,
    "plumber":  Images.plumber,
    "tea": Images.tea,
    "watercan": Images.waterCan,
    "lorrywater": Images.lorryWater,
    "tiles": Images.titles,
    "granite":Images.grantie,
    "jally":Images.jally,
    "welding": Images.welding,
    "lift":Images.lift,
    "rcconcrete": Images.rcc,
    "transport": Images.transport,
    "interior": Images.interior,
    "painting": Images.painter
  };



  */


  static final List<String> allMaterialKeys = [
    "bricks",
    "sand",
    "cement",
    "rmc",
    "gravel",
  ];

  static final Map<String, String> materialImages = {
    "bricks": Images.brick,
    "sand": Images.sand,
    "cement":  Images.cement,
    "rmc":  Images.rmc,
    "gravel":  Images.jally,
  };

  static final List<String> allSubcontractorKeys = [
    "plumber",
    "electrician",
    "painter",
    "welder",
    "tiles layer",
    "granite layer",
    "ss welder",
    "carpenter",
    "centering works",
    "mason works",
  ];

  static final Map<String, String> allSubcontractorImages = {
    "plumber": Images.plumber,
    "electrician": Images.electricalCable,
    "painter": Images.painter,
    "welder": Images.welding,
    "tiles layer": Images.titles,
    "granite layer": Images.grantie,
    "ss welder": Images.material,
    "carpenter": Images.material,
    "centering works": Images.material,
    "mason works": Images.material,
  };




  static int getWeeksInMonth(int year, int month) {
    // First day of the month
    final firstDay = DateTime(year, month, 1);

    // Last day of the month (by going to next month, day 0)
    final lastDay = DateTime(year, month + 1, 0);

    // ISO week starts from Monday. Adjust based on your needs.
    int firstWeekday = firstDay.weekday; // 1 (Mon) to 7 (Sun)
    int totalDays = lastDay.day;

    // Calculate days including leading days before first Monday
    int daysOffset = firstWeekday - 1; // days before full week
    int totalCalendarDays = daysOffset + totalDays;

    // Divide by 7, round up to count weeks
    return (totalCalendarDays / 7).ceil();
  }

  static const Color attendanceTextColor = Color(0xFF252C58);

  List<Color> attendanceBorderColor =[
    AppColor.kothanarBorder,
    AppColor.sithalBorderColor,
    AppColor.masthiriBorderColor,
    AppColor.engineerBorderColor,
  ];

  List<Color> attendanceShadowColor =[
    AppColor.kothanarShadowColor,
    AppColor.sithalShadowColor,
    AppColor.masthiriShadowColor,
    AppColor.engineerShadowColor,
  ];

}
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String lowerCapitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toLowerCase() + text.substring(1);
}
   List<TextInputFormatter> tenDigitPhoneFormatter() {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(10),
    ];

}