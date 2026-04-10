import 'package:flutter/material.dart';
import 'package:raptor_pro/utils/res/colors.dart';

class CommonLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const CommonLoader({this.size = 30.0, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColor.buttonBlue
        ),
      ),
    );
  }
}
