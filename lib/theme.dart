import 'package:flutter/material.dart';

class CashPawsTheme {
  static const Color background = Color(0xFF0F141C);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color accentBlue = Color(0xFF3A88E9);
  static const Color accentOrange = Color(0xFFE99E3A);
  static const Color textGold = Color(0xFFFFD700);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: accentBlue,
    );
  }
}
