import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'theme.dart';
import 'home_screen.dart';

void main() async {
  // Ensure Flutter engine bindings are completely ready before async boots
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Google Mobile Ads SDK framework loop
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('AdMob engine initialization skipped or offline: $e');
  }

  runApp(const CashPawsApp());
}

class CashPawsApp extends StatelessWidget {
  const CashPawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashPaws',
      debugShowCheckedModeBanner: false,
      
      // Enforce your Midnight Dark Theme styling rules globally
      theme: ThemeData(
        scaffoldBackgroundColor: CashPawsColors.backgroundMidnight,
        primaryColor: CashPawsColors.neonGreen,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      
      // Automatically loads the dashboard with a dummy user profile configuration for sandbox testing
      home: const CashPawsHomeScreen(
        userId: 'test_sandbox_user_101',
        initialCoins: 2500, // Pre-loads 2,500 coins so you can test withdrawal limits instantly
      ),
    );
  }
}
