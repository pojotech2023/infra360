import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/images.dart';

class ConstantData {

  static final List<String> paymentMode = [
    "Online","Check","Net Banking","Cash","Cash-B"
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
    "Bricks",
    "Sand",
    "Cement",
    "Electrical Wires",
    "Plumber",
    "Tea",
    "Watercan",
    "Lorry Water",
    "Tiles",
    "Granite",
    "Jally",
    "Welding",
    "Lift",
    "RC Concrete",
    "Transport",
    "Interior",
    "Painting",
    "Steel",
    "AGGREGATE",
    "RMC",
    "Gravel",
  ];

  static final Map<String, String> materialImages = {
    "Bricks": Images.brick,
    "Sand": Images.sandJpeg,
    "Cement":  Images.cement,
    "Electrical Wires": Images.electricalWires,
    "Plumber": Images.plumber,
    "Tea": Images.tea,
    "Watercan": Images.waterCan,
    "Lorry Water": Images.lorryWater,
    "Tiles": Images.tiles,
    "Granite": Images.granite,
    "Jally": Images.jally,
    "Welding": Images.welding,
    "Lift": Images.lift,
    "RC Concrete": Images.rcConcrete,
    "Transport": Images.transport,
    "Interior": Images.interior,
    "Painting": Images.painting,
    "Steel": Images.steel,
    "AGGREGATE": Images.aggregate,
    "RMC": Images.rmc,
    "Gravel": Images.gravel,
  };

  static final List<String> allSubcontractorKeys = [
    "Plumber",
    "Electrician",
    "Painter",
    "Welder",
    "Tiles Layer",
    "Granite Layer",
    "SS Welder",
    "Carpenter",
    "Centering Works",
    "Mason Works",
    "Petty Cash",
    "Rental Management",
  ];

  static final Map<String, String> allSubcontractorImages = {
    "Plumber": Images.plumber,
    "Electrician": Images.electrician,
    "Painter": Images.painter,
    "Welder": Images.welder,
    "Tiles Layer": Images.tilesLayer,
    "Granite Layer": Images.graniteLayer,
    "SS Welder": Images.ssWelder,
    "Carpenter": Images.carpenter,
    "Centering Works": Images.centeringWorks,
    "Mason Works": Images.masonWorks,
    "Petty Cash": Images.pettyCash,
    "Rental Management": Images.rentalManagement,
  };




  static int getWeeksInMonth(int year, int month) {
    // Week 1 = days  1-7,  Week 2 = days  8-14,
    // Week 3 = days 15-21, Week 4 = days 22-28,
    // Week 5 = days 29-end  (if month has >28 days)
    // This matches the web admin's week definition.
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return (daysInMonth / 7).ceil();
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