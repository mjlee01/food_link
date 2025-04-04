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
    textTheme: FLTextTheme.lightTextTheme,
    chipTheme: FLChipTheme.lightChipTheme,
    scaffoldBackgroundColor: FLColors.white,
    elevatedButtonTheme: FLElevatedButtonTheme.lightElevatedButtonTheme,
    appBarTheme: FLAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: FLBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: FLCheckboxTheme.lightCheckboxTheme,
    outlinedButtonTheme: FLOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: FLTextFormFieldTheme.lightInputDecorationTheme,
    colorScheme: ColorScheme.fromSeed(seedColor: FLColors.primary, brightness: Brightness.light),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.roboto().fontFamily,
    disabledColor: FLColors.grey,
    brightness: Brightness.dark,
    primaryColor: FLColors.primary,
    scaffoldBackgroundColor: FLColors.black,
    textTheme: FLTextTheme.darkTextTheme,
    elevatedButtonTheme: FLElevatedButtonTheme.darkElevatedButtonTheme,
    appBarTheme: FLAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: FLBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme: FLCheckboxTheme.darkCheckboxTheme,
    chipTheme: FLChipTheme.darkChipTheme,
    outlinedButtonTheme: FLOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: FLTextFormFieldTheme.darkInputDecorationTheme,
    colorScheme: ColorScheme.fromSeed(seedColor: FLColors.primary, brightness: Brightness.dark),
  );
}
