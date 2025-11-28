import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppTextStyles {
  static TextStyle get title => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 30.sp,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: 1.5,
  );

  static TextStyle get subtitle => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
  );

  static TextStyle get hudLabel => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
  );

  static TextStyle get hudValue => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get cardLetter => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 20.sp,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  static TextStyle get cardLabel => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 10.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get appBarTitle => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextTheme get textTheme => TextTheme(
    bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 12.sp),
    bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 11.sp),
  );
}
