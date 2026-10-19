import 'package:flutter/material.dart';

class CashPawsColors {
  static const Color backgroundMidnight = Color(0xFF0B0E14);
  static const Color cardNavy = Color(0xFF131924);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color goldAccent = Color(0xFFFFAA00);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF7A8A9E);
}

class CashPawsTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: CashPawsColors.backgroundMidnight,
      primaryColor: CashPawsColors.neonGreen,
      hintColor: CashPawsColors.goldAccent,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: CashPawsColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: CashPawsColors.textWhite, fontSize: 16),
        bodyMedium: TextStyle(color: CashPawsColors.textMuted, fontSize: 14),
      ),
    );
  }
}
