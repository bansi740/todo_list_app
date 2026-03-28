import 'package:flutter/material.dart';

class Responsive {
  // Screen width
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  // Screen height
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Screen orientation
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  // Breakpoints
  static bool isMobile(BuildContext context) =>
      width(context) < 600;

  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 1024;

  static bool isDesktop(BuildContext context) =>
      width(context) >= 1024;

  // Example: relative sizing
  static double wp(BuildContext context, double percent) =>
      width(context) * percent / 100;

  static double hp(BuildContext context, double percent) =>
      height(context) * percent / 100;
}