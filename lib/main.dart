import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Import project screens from your workspace file architecture
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/watch_ad_screen.dart';
import 'screens/spin_wheel_screen.dart';
import 'screens/walking_tracker_screen.dart';
import 'screens/tap_coins_screen.dart';
import 'payout_screen.dart';

void main() async {
  // Ensure framework engine channel bindings are fully locked and resolved
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Google Mobile Ads SDK (AdMob Layout Handlers)
  try {
    await MobileAds.instance.initialize();
    debugPrint('AdMob engine synchronized successfully.');
  } catch (e) {
    debugPrint('AdMob monetization failed to initialize: $e');
  }

  // 2. Initialize Supabase Backend Infrastructure Client Connections
  // WARNING: Replace placeholders below with exact credentials from your Supabase settings panel
  await Supabase.initialize(
    url: 'https://supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-actual-anon-key-here',
  );

  runApp(const CashPawsApp());
}

class CashPawsApp extends StatelessWidget {
  const CashPawsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine target fallback routes dynamically based on underlying active sessions
    final Session? activeSession = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'CashPaws Earning App',
      debugShowCheckedModeBanner: false, // Disables standard development banner layers
      
      // Global Dark Neon Theme Styling Configured for CashPaws Aesthetics
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121214), // Dark obsidian baseline
        primaryColor: Colors.orangeAccent,
        hintColor: Colors.grey,
        colorScheme: const ColorScheme.dark(
          primary: Colors.orangeAccent,
          secondary: Colors.deepOrangeAccent,
          surface: Color(0xFF1A1A1E), // Dark asphalt modular surfaces
        ),
      ),

      // Automatic Session Gateway routing checks
      initialRoute: activeSession == null ? '/auth' : '/dashboard',

      // Explicit route mappings linking your full code blocks
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/dashboard': (context) => const DashboardScreen(), // Make sure this contains MiningChestCard
        '/watch_ads': (context) => const WatchAdScreen(),
        '/spin_wheel': (context) => const SpinWheelScreen(),
        '/walking_tracker': (context) => const WalkingTrackerScreen(),
        '/tap_coins': (context) => const TapCoinsScreen(),
        '/payouts': (context) => const PayoutScreen(),
      },
    );
  }
}
