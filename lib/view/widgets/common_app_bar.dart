import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/images.dart';

class CommonAppBar {
  static AppBar appBar({required VoidCallback onTap,required String title,List<Widget>? actions }) {
    return AppBar(
      toolbarHeight: 80,
      centerTitle: true,
      title: Text(title,style: AppTextStyle.appBarTextStyle),
      leading: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: SvgPicture.asset(
            Images.arrow,
            width: 24,
            height: 24,
          ),
        ),
      ),actions: actions ??[]
    );
  }
}
