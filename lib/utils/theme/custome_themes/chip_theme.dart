import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class FLChipTheme {
  FLChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: FLColors.grey.withOpacity(0.4),
    labelStyle: const TextStyle(color: FLColors.black),
    selectedColor: FLColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: FLColors.white,
  );

  static ChipThemeData darkChipTheme = const ChipThemeData(
    disabledColor: FLColors.darkerGrey,
    labelStyle: TextStyle(color: FLColors.white),
    selectedColor: FLColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: FLColors.white,
  );
}
