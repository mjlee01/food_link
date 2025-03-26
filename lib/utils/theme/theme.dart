import 'package:flutter/material.dart';
import 'package:food_link/utils/constants/colors.dart';
import 'package:food_link/utils/theme/custome_themes/bottom_sheet_theme.dart';
import 'package:food_link/utils/theme/custome_themes/checkbox_theme.dart';
import 'package:food_link/utils/theme/custome_themes/chip_theme.dart';
import 'package:food_link/utils/theme/custome_themes/elevated_button_theme.dart';
import 'package:food_link/utils/theme/custome_themes/outlined_button_theme.dart';
import 'package:food_link/utils/theme/custome_themes/text_field_theme.dart';
import 'package:food_link/utils/theme/custome_themes/text_theme.dart';
import 'package:food_link/utils/theme/custome_themes/appbar_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class FLAppTheme {
  FLAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.roboto().fontFamily,
    disabledColor: FLColors.grey,
    brightness: Brightness.light,
    primaryColor: FLColors.primary,
    textTheme: flTextTheme.lightTextTheme,
    chipTheme: flChipTheme.lightChipTheme,
    scaffoldBackgroundColor: FLColors.white,
    elevatedButtonTheme: flElevatedButtonTheme.lightElevatedButtonTheme,
    appBarTheme: flAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: flBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: flCheckboxTheme.lightCheckboxTheme,
    outlinedButtonTheme: flOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: flTextFormFieldTheme.lightInputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.roboto().fontFamily,
    disabledColor: FLColors.grey,
    brightness: Brightness.dark,
    primaryColor: FLColors.primary,
    scaffoldBackgroundColor: FLColors.black,
    textTheme: flTextTheme.darkTextTheme,
    elevatedButtonTheme: flElevatedButtonTheme.darkElevatedButtonTheme,
    appBarTheme: flAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: flBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme: flCheckboxTheme.darkCheckboxTheme,
    chipTheme: flChipTheme.darkChipTheme,
    outlinedButtonTheme: flOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: flTextFormFieldTheme.darkInputDecorationTheme,
  );
}
