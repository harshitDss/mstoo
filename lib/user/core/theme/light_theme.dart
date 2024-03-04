import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  fontFamily: 'Ubuntu',
  // primaryColor: const Color(0xFF056AB4),
  // primaryColor: const Color(0xff80097e),
  // primaryColor: const Color(0xff2abd64),
  primaryColor: const Color(0xff911d18),
  // primaryColorLight: const Color(0xFFF0F4F8),
  // primaryColorLight: const Color(0xffde54af),
  primaryColorLight: const Color(0xffe84750),
  primaryColorDark: const Color(0xFF10324A),
  secondaryHeaderColor: const Color(0xFF758493),

  disabledColor: const Color(0xFF8797AB),
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  brightness: Brightness.light,
  hintColor: const Color(0xFFC0BFBF),
  focusColor: const Color(0xFFFFF9E5),
  hoverColor: const Color(0xFFF1F7FC),
  shadowColor: Colors.grey[300],
  cardColor: Colors.white,
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFF0461A5))),
  colorScheme: const ColorScheme.light(
    // primary: Color(0xFF056AB4),
    // primary: Color(0xff80097e),
    // primary: Color(0xff2abd64),
    primary: Color(0xff911d18),
    // secondary: Color(0xFFFF9900),
    // secondary: Color(0xFFde54af),
    // secondary: Color(0xff2abd64),
    secondary: Color(0xFFe84750),
    
    tertiary: Color(0xFFd35221),
    onSecondaryContainer: Color(0xFFe84750),
    error: Color(0xffed4f55)
  ).copyWith(background: const Color(0xffFCFCFC)),
);