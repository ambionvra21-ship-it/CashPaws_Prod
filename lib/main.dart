import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'theme.dart';
import 'home_screen.dart'; // Safely targets your unified dashboard script file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Safe initialization framework loop
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
      theme: ThemeData(
        scaffoldBackgroundColor: CashPawsColors.backgroundMidnight,
        primaryColor: CashPawsColors.neonGreen,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const CashPawsHomeScreen(
        userId: 'test_sandbox_user_101',
        initialCoins: 2650, // Pre-loads initial sandbox currency balance tracker
      ),
    );
  }
}
