import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class flTextFormFieldTheme {
  flTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: FLColors.darkGrey,
    suffixIconColor: FLColors.darkGrey,
    // constraints: const BoxConstraints.expand(height: FLSizes.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(fontSize: FLSizes.fontSizeMd, color: FLColors.black),
    hintStyle: const TextStyle().copyWith(fontSize: FLSizes.fontSizeSm, color: FLColors.black),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle().copyWith(color: FLColors.black.withOpacity(0.8)),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(FLSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: FLColors.grey),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(FLSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: FLColors.grey),
    ),
    focusedBorder:const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(FLSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: FLColors.dark),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(FLSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: FLColors.warning),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(FLSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: FLColors.warning),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: FLColors.darkGrey,
    suffixIconColor: FLColors.darkGrey,
    // constraints: const BoxConstraints.expand(height: FLSizes.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(fontSize: FLSizes.fontSizeMd, color: FLColors.white),
    hintStyle: const TextStyle().copyWith(fontSize: FLSizes.fontSizeSm, color: FLColors.white),
    floatingLabelStyle: const TextStyle().copyWith(color: FLColors.white.withOpacity(0.8)),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(FLSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: FLColors.darkGrey),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(FLSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: FLColors.darkGrey),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(FLSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: FLColors.white),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(FLSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: FLColors.warning),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(FLSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: FLColors.warning),
    ),
  );
}
