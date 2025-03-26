import 'package:flutter/material.dart';
import '../../constants/sizes.dart';
import '../../constants/colors.dart';

class flAppBarTheme{
  flAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: FLColors.black, size: FLSizes.iconMd),
    actionsIconTheme: IconThemeData(color: FLColors.black, size: FLSizes.iconMd),
    titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: FLColors.black),
  );
  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: FLColors.black, size: FLSizes.iconMd),
    actionsIconTheme: IconThemeData(color: FLColors.white, size: FLSizes.iconMd),
    titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: FLColors.white),
  );
}