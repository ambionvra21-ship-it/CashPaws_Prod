import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// FIXED: Imports updated to perfectly match your flat directory tree layout
import 'auth_screen.dart';
import 'dashboard_screen.dart';
import 'watch_ad_screen.dart';
import 'spin_wheel_screen.dart';
import 'walking_tracker_screen.dart';
import 'tap_coins_screen.dart';
import 'payout_screen.dart';

void main() async {
  // Ensure framework engine channel bindings are fully resolved
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Google Mobile Ads SDK (AdMob Layout Handlers)
  try {
    await MobileAds.instance.initialize();
    
    // Configure safe global test device parameters
    RequestConfiguration configuration = RequestConfiguration(
      testDeviceIds: [
        '33333333333333333333333333333333', // Placeholder Android test phone hash
      ],
    );
    await MobileAds.instance.updateRequestConfiguration(configuration);
    debugPrint('AdMob engine synchronized successfully.');
  } catch (e) {
    debugPrint('AdMob monetization failed to initialize: $e');
  }

  // 2. Initialize Supabase Backend Infrastructure Client Connections
  // WARNING: Ensure placeholders match your exact project settings dashboard keys
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
    // Determine the root screen dynamically based on active sign-in sessions
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

      // Automatic Session Gateway routing check constraints
      initialRoute: activeSession == null ? '/auth' : '/dashboard',

      // Explicit route mappings linking your flat folder code files
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/watch_ads': (context) => const WatchAdScreen(),
        '/spin_wheel': (context) => const SpinWheelScreen(),
        '/walking_tracker': (context) => const WalkingTrackerScreen(),
        '/tap_coins': (context) => const TapCoinsScreen(),
        '/payouts': (context) => const PayoutScreen(),
      },
    );
  }
}
