import 'package:flutter/material.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';

class CommonButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color ?customColor;

  const CommonButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.customColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          customColor??AppColor.buttonBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          padding: EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          text,
          style: AppTextStyle.textMedium.copyWith(color: AppColor.white),
        ),
      ),
    );
  }
}
