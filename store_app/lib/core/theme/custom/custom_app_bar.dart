import 'package:flutter/services.dart';

import '../constant/app_colors.dart';

class CustomAppBarTheme {
  final SystemUiOverlayStyle systemUiOverlayStyle;
  final Color backgroundColor;
  final Color logoColor;
  final Color iconColor;
  final Color containerColor;
  final Color indicatorColor;
  final Color labelColor;
  final Color unselectedLabelColor;
  final Color badgeBgColor;
  final Color badgeNumColor;

  static final int animationDuration = 250;
  static const double tabBarRadius = 30;

  static final CustomAppBarTheme store = CustomAppBarTheme(
    systemUiOverlayStyle: SystemUiOverlayStyle.light,
    backgroundColor: AppColors.primary,
    logoColor: AppColors.onPrimary,
    iconColor: AppColors.onPrimary,
    containerColor: AppColors.inversePrimary,
    indicatorColor: AppColors.onPrimary,
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.onPrimary,
    badgeBgColor: AppColors.background,
    badgeNumColor: AppColors.primary,
  );

  static final CustomAppBarTheme beauty = CustomAppBarTheme(
    systemUiOverlayStyle: SystemUiOverlayStyle.dark,
    backgroundColor: AppColors.background,
    logoColor: AppColors.primary,
    iconColor: AppColors.contentPrimary,
    containerColor: AppColors.surface,
    indicatorColor: AppColors.primary,
    labelColor: AppColors.onPrimary,
    unselectedLabelColor: AppColors.contentPrimary,
    badgeBgColor: AppColors.primary,
    badgeNumColor: AppColors.background,
  );

  CustomAppBarTheme({
    required this.systemUiOverlayStyle,
    required this.backgroundColor,
    required this.logoColor,
    required this.iconColor,
    required this.containerColor,
    required this.indicatorColor,
    required this.labelColor,
    required this.unselectedLabelColor,
    required this.badgeBgColor,
    required this.badgeNumColor,
  });
}