import 'dart:async';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:gradient_borders/box_borders/gradient_box_border';
import 'admob_service.dart';
import 'supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final admobInstance = AdMobService();
  final supabaseInstance = SupabaseService();
  
  await admobInstance.initializeAdMob();
  try { 
    await supabaseInstance.initializeSupabase(); 
  } catch (e) { 
    debugPrint("Supabase entry deferred until production keys are filled."); 
  }

  runApp(CashPawsApp(admob: admobInstance, supabase: supabaseInstance));
}

class CashPawsApp extends StatelessWidget {
  final AdMobService admob;
  final SupabaseService supabase;
  
  const CashPawsApp({
    super.key, 
    required this.admob, 
    required this.supabase,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F141C),
        primaryColor: const Color(0xFF3A88E9),
      ),
      home: DashboardShell(admob: admob, supabase: supabase),
    );
  }
}

class DashboardShell extends StatefulWidget {
  final AdMobService admob;
  final SupabaseService supabase;
  
  const DashboardShell({
    super.key, 
    required this.admob, 
    required this.supabase,
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  Duration _timeLeft = const Duration(hours: 2, minutes: 18, seconds: 39);
  bool _canCollect = false;
  Timer? _miningTimer;

  double _userCpPoints = 95240.0;
  int _stepCount = 8412;
  double _totalPlatformProfitUsd = 0.0; 
  String _statusConsoleLog = "System Online. AdMob Ready.";

  final TextEditingController _emailInput = TextEditingController();
  final TextEditingController _passwordInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startMiningTimer();
    widget.admob.loadRewardedAd(onAdLoaded: () {
      if (mounted) {
        setState(() { _statusConsoleLog = "🎁 Video Ad Loaded & Ready to Play!"; });
      }
    });
  }

  void _startMiningTimer() {
    _miningTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        if (mounted) {
          setState(() { _timeLeft -= const Duration(seconds: 1); });
        }
      } else {
        if (mounted) {
          setState(() { _canCollect = true; _miningTimer?.cancel(); });
        }
      }
    });
  }

  String _getFormattedTime() {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(_timeLeft.inHours)}:${twoDigits(_timeLeft.inMinutes.remainder(60))}:${twoDigits(_timeLeft.inSeconds.remainder(60))} Left";
  }

  void _triggerLiveVideoRewardAd() {
    if (mounted) {
      setState(() { _statusConsoleLog = "🎬 Opening AdMob Video Ad..."; });
    }
    widget.admob.showRewardedAd(
      onRewardEarned: (platformProfitCut, userPointsEarned) {
        if (mounted) {
          setState(() {
            _totalPlatformProfitUsd += platformProfitCut;
            _userCpPoints += userPointsEarned;
            _statusConsoleLog = "An ad action completed. 90% revenue cut locked.";
          });
        }
      },
      onAdClosed: () {
        if (mounted) {
          setState(() { _statusConsoleLog = "Video Ad Closed. Prefetching next element."; });
        }
      },
    );
  }

  void _openSupabaseAuthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Supabase Profile Access", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(controller: _emailInput, decoration: const InputDecoration(labelText: "Email address")),
            TextField(controller: _passwordInput, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    String? msg = await widget.supabase.loginUserEmail(email: _emailInput.text, password: _passwordInput.text);
                    if (mounted) setState(() { _statusConsoleLog = msg ?? "Login Error"; });
                  },
                  child: const Text("LOGIN"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    String? msg = await widget.supabase.registerUserEmail(email: _emailInput.text, password: _passwordInput.text);
                    if (mounted) setState(() { _statusConsoleLog = msg ?? "Registration Error"; });
                  },
                  child: const Text("REGISTER"),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _miningTimer?.cancel();
    _emailInput.dispose();
    _passwordInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTopHeaderBar(_userCpPoints),
                    const SizedBox(height: 20),
                    _buildLoginWidget(),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        _statusConsoleLog,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Platform Safe Profit (90% Cut): \$${_totalPlatformProfitUsd.toStringAsFixed(4)}",
                      style: const TextStyle(color: Colors.white30, fontSize: 11, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildGlassHUDEngine(),
              ),
            ),
            const Positioned(bottom: 0, left: 0, right: 0, child: BottomBannerAd())
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeaderBar(double points) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _openSupabaseAuthModal,
          child: Row(
            children: const [
              CircleAvatar(radius: 16, backgroundColor: Colors.blueGrey, child: Icon(Icons.person, size: 18, color: Colors.white70)),
              SizedBox(width: 8),
              Text("AlexPaw", style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
            ],
          ),
        ),
        Row(
          children: const [
            Icon(Icons.pets, color: Color(0xFFE99E3A), size: 18),
            SizedBox(width: 4),
            Text("CashPaws", style: TextStyle(fontSize: 16, fontWeight: FontWeight.black)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, py: 4),
          decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 14),
              const SizedBox(width: 4),
              Text("${points.toStringAsFixed(0)} CP", style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const Text("Daily Login Streak", style: TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // Fixed: Text string fragments removed completely
            children: List.generate(4, (index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(Icons.pets, color: Color(0xFF3A88E9), size: 20),
            )),
          )
        ],
      ),
    );
  }
