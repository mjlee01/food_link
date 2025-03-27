import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/* -- Light & Dark Outlined Button Themes -- */
class FLOutlinedButtonTheme {
  FLOutlinedButtonTheme._(); //To avoid creating instances


  /* -- Light Theme -- */
  static final lightOutlinedButtonTheme  = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: FLColors.dark,
      side: const BorderSide(color: FLColors.borderPrimary),
      textStyle: const TextStyle(fontSize: 16, color: FLColors.black, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: FLSizes.buttonHeight, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FLSizes.buttonRadius)),
    ),
  );

  /* -- Dark Theme -- */
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: FLColors.light,
      side: const BorderSide(color: FLColors.borderPrimary),
      textStyle: const TextStyle(fontSize: 16, color: FLColors.textWhite, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: FLSizes.buttonHeight, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FLSizes.buttonRadius)),
    ),
  );
}
