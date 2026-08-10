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
      leading: Builder(
        builder: (context) {
          return IconButton(
            onPressed: () {
              // Use standard Flutter navigation to avoid GetX route blocking/transition bugs
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                // Fallback to the provided onTap if standard pop is unavailable
                onTap();
              }
            },
            icon: SvgPicture.asset(
              Images.arrow,
              width: 30,
              height: 30,
            ),
          );
        }
      ),
      actions: actions ?? []
    );
  }
}
