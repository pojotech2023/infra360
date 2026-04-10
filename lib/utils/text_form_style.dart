import 'package:flutter/material.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';

InputDecoration textBoxDecoration({ String ?hint,Widget ?suffixIcon,Widget ?prefixIcon,Color ?myColor,Color ?fillColor}) {
  return InputDecoration(
    hintText: hint,
    suffixIcon: suffixIcon,
    prefixIcon: prefixIcon,
    hintStyle: AppTextStyle.textHintText,
    counterText: "",
    fillColor:fillColor,
    filled:fillColor==null?false: true,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color:myColor?? AppColor.textFieldBorder,width: 1.5),
      borderRadius: BorderRadius.circular(5),
    ),
    border:  OutlineInputBorder(
      borderSide: BorderSide(color: myColor??AppColor.textFieldBorder,width: 1.5),
      borderRadius: BorderRadius.circular(5),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color:myColor?? AppColor.textFieldBorder,width: 1.5),
      borderRadius: BorderRadius.circular(5),

    ),
    errorBorder:  OutlineInputBorder(
      borderSide: BorderSide(color: AppColor.red),
    ),
  );
}


InputDecoration dropDownBoxDecoration({ String ?hint}) {
  return InputDecoration(
    hintText: hint,
    contentPadding: EdgeInsets.only(top: 10,bottom: 10,right: 10),
    hintStyle: AppTextStyle.textHintText,
    counterText: "",
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColor.textFieldBorder,width: 1.5),
      borderRadius: BorderRadius.circular(5),
    ),
    border:  OutlineInputBorder(
      borderSide: BorderSide(color: AppColor.textFieldBorder,width: 1.5),
      borderRadius: BorderRadius.circular(5),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColor.textFieldBorder,width: 1.5),
      borderRadius: BorderRadius.circular(5),

    ),
    errorBorder:  OutlineInputBorder(
      borderSide: BorderSide(color: AppColor.red),
    ),
  );
}