import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'theme.dart';
import 'home_screen.dart';

void main() async {
  // Guarantees native engine components link correctly before async executions
  WidgetsFlutterBinding.ensureInitialized();
  
  // Safe isolated wrapper initialization loop for AdMob
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
      
      // Forces consistent midnight layout themes globally to prevent gray canvas leaks
      theme: ThemeData(
        scaffoldBackgroundColor: CashPawsColors.backgroundMidnight,
        primaryColor: CashPawsColors.neonGreen,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      
      // Loads the master dashboard instantly with preloaded test sandbox tracking values
      home: const CashPawsHomeScreen(
        userId: 'test_sandbox_user_101',
        initialCoins: 2500, 
      ),
    );
  }
}
