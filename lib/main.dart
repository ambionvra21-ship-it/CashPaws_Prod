import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // 🌟 Add this import
import 'theme.dart';
import 'home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🌟 ADD THIS LINE: Initialize the AdMob engine on startup
  MobileAds.instance.initialize();
  
  runApp(const CashPawsApp());
}

class CashPawsApp extends StatelessWidget {
  const CashPawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashPaws',
      debugShowCheckedModeBanner: false,
      theme: CashPawsTheme.darkTheme,
      home: const CashPawsHomeScreen(),
    );
  }
}
