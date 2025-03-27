import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/* -- Light & Dark Elevated Button Themes -- */
class FLElevatedButtonTheme {
  FLElevatedButtonTheme._(); //To avoid creating instances


  /* -- Light Theme -- */
  static final lightElevatedButtonTheme  = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: FLColors.light,
      backgroundColor: FLColors.primary,
      disabledForegroundColor: FLColors.darkGrey,
      disabledBackgroundColor: FLColors.buttonDisabled,
      side: const BorderSide(color: FLColors.primary),
      padding: const EdgeInsets.symmetric(vertical: FLSizes.buttonHeight),
      textStyle: const TextStyle(fontSize: 16, color: FLColors.textWhite, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FLSizes.buttonRadius)),
    ),
  );

  /* -- Dark Theme -- */
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: FLColors.light,
      backgroundColor: FLColors.primary,
      disabledForegroundColor: FLColors.darkGrey,
      disabledBackgroundColor: FLColors.darkerGrey,
      side: const BorderSide(color: FLColors.primary),
      padding: const EdgeInsets.symmetric(vertical: FLSizes.buttonHeight),
      textStyle: const TextStyle(fontSize: 16, color: FLColors.textWhite, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FLSizes.buttonRadius)),
    ),
  );
}
