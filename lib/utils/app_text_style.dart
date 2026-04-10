
import 'package:flutter/material.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/font_weight.dart';
import 'package:raptor_pro/utils/res/fontsize.dart';

class AppTextStyle {

  static TextStyle appBarTextStyle = TextStyle(
    fontSize: AppFontSize.dp18,
    fontWeight: FontWeights.medium,
    color: AppColor.appBarTextColor,
  );
  static TextStyle textBold = TextStyle(
    fontSize: AppFontSize.dp16,
    fontWeight: FontWeights.bold,
    color: AppColor.headingBlack,
  );

  static TextStyle textMedium = TextStyle(
    fontSize: AppFontSize.dp16,
    fontWeight: FontWeights.medium,
    color: AppColor.headingBlack,
  );
  static TextStyle textRegularSmall = TextStyle(
    fontSize: AppFontSize.dp12,
    fontWeight: FontWeights.regular,
    color: AppColor.black,
  );

  static TextStyle textSubHeading = TextStyle(
    fontSize: AppFontSize.dp12,
    fontWeight: FontWeights.regular,
    color: AppColor.subHeading
  );
  static TextStyle materialTitleText = TextStyle(
      fontSize: AppFontSize.dp14,
      fontWeight: FontWeights.medium,
      color: AppColor.black
  );

  static TextStyle textRegular15 = TextStyle(
    fontSize: AppFontSize.dp15,
    fontWeight: FontWeights.regular,
    color: AppColor.black,
  );

  static TextStyle textFieldHeadingStyle = TextStyle(
    fontSize: AppFontSize.dp15,
    fontWeight: FontWeights.medium,
    color: AppColor.black,
  );

  static TextStyle textHintText = TextStyle(
    fontSize: AppFontSize.dp12,
    fontWeight: FontWeights.regular,
    color: Colors.grey[700],
  );
  static TextStyle customerDetailsStyle = TextStyle(
    fontSize: AppFontSize.dp14,
    fontWeight: FontWeights.semiBold,
    color: Color(0xFF555B6C),
  );
}