import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

TextStyle myTextStyle( BuildContext? context, Color color, int size, FontWeight fontWeight) {
  return  TextStyle(
    fontSize: size.dp,
    fontWeight: fontWeight,
    color: color

  );
}
