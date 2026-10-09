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
    "Ongoing","Completed"
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
    "Basic Exterior Wash",
    "Doors & Windows",
    "External/Outdoor",
    "Finishing Materials",
    "Glass & Aluminium",
    "Hardware",
    "Safety & PPE",
    "Sanitary & Bath Fittings",
    "Scaffolding & Formwork",
    "Waterproofing & Insulation",
    "Wood & Carpentry",
  ];

  static final Map<String, String> materialImages = {
    "All Materials": Images.material,
    "all materials": Images.material,
    "all": Images.material,
    "Bricks": Images.brick,
    "Sand": Images.sandJpeg,
    "Cement": Images.cement,
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
    "Aggregate": Images.aggregate,
    "RMC": Images.rmc,
    "Gravel": Images.gravel,
    "Basic Exterior Wash": Images.basicExteriorWash,
    "Doors & Windows": Images.doorsAndWindows,
    "External/Outdoor": Images.externalOutdoor,
    "Finishing Materials": Images.finishingMaterials,
    "Glass & Aluminium": Images.glassAndAluminium,
    "Hardware": Images.hardware,
    "Safety & PPE": Images.safetyAndPpe,
    "Sanitary & Bath Fittings": Images.sanitaryAndBathFittings,
    "Scaffolding & Formwork": Images.scaffoldingAndFormwork,
    "Waterproofing & Insulation": Images.waterproofingAndInsulation,
    "Wood & Carpentry": Images.woodAndCarpentry,
  };

  static String getMaterialImage(String key) {
    if (materialImages.containsKey(key)) {
      return materialImages[key]!;
    }
    final cleanKey = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    for (var entry in materialImages.entries) {
      if (entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') == cleanKey) {
        return entry.value;
      }
    }
    return Images.material;
  }

  static final List<String> allSubcontractorKeys = [
    "Plumber",
    "Electrician",
    "Painter",
    "Welder",
    "Tiles Layer",
    "Granite Layer",
    "SS Welder",
    "Centering Works",
    "Mason Works",
    "Civil Works Contractor",
    "Steel & Structural Contractor",
    "Waterproofing Contractor",
    "Flooring Contractor",
    "False Ceiling Contractor",
    "Aluminium & Glass Contractor",
    "HVAC Contractor",
    "Fire & Safety Contractor",
    "Fabrication Contractor",
    "Road & Paving Contractor",
    "Landscaping Contractor",
    "Interior Works Contractor",
    "Demolition Contractor",
    "Heavy Equipment Contractor",
    "MEP Contractor",
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
    "Carpenter": Images.woodAndCarpentry,
    "Centering Works": Images.centeringWorks,
    "Mason Works": Images.masonWorks,
    "Civil Works Contractor": Images.civilWorksContractor,
    "Steel & Structural Contractor": Images.steel,
    "Waterproofing Contractor": Images.waterproofingAndInsulation,
    "Flooring Contractor": Images.granite,
    "False Ceiling Contractor": Images.finishingMaterials,
    "Aluminium & Glass Contractor": Images.glassAndAluminium,
    "HVAC Contractor": Images.hardware,
    "Fire & Safety Contractor": Images.safetyAndPpe,
    "Fabrication Contractor": Images.welder,
    "Road & Paving Contractor": Images.roadAndPavingContractor,
    "Landscaping Contractor": Images.externalOutdoor,
    "Interior Works Contractor": Images.interior,
    "Demolition Contractor": Images.rcConcrete,
    "Heavy Equipment Contractor": Images.transport,
    "MEP Contractor": Images.lift,
    "Petty Cash": Images.pettyCash,
    "Rental Management": Images.rentalManagement,
    "OTHERS": Images.othersSubcontractor,
    "Others": Images.othersSubcontractor,
  };

  static String getSubcontractorImage(String key) {
    if (allSubcontractorImages.containsKey(key)) {
      return allSubcontractorImages[key]!;
    }
    final cleanKey = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    for (var entry in allSubcontractorImages.entries) {
      if (entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') == cleanKey) {
        return entry.value;
      }
    }
    return Images.material;
  }




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