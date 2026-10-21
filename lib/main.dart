import 'dart:async';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:gradient_borders/box_borders/gradient_box_border';

void main() {
  runApp(const CashPawsApp());
}

// Enforces your strict rule: 90% goes to platform profit, 10% to user payout
class RevenueController {
  static Map<String, double> calculateSplit(double grossAdValueUsd) {
    return {
      'platformProfitUsd': grossAdValueUsd * 0.90,
      'userPayoutUsd': grossAdValueUsd * 0.10,
    };
  }
}

// State management configuration
class DashboardState extends ChangeNotifier {
  Duration _timeLeft = const Duration(hours: 2, minutes: 18, seconds: 39);
  bool _canCollect = false;
  Timer? _miningTimer;

  double _userCpPoints = 95240.0;
  int _stepCount = 8412;
  double _totalPlatformProfitUsd = 0.0; 

  String get formattedTime {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(_timeLeft.inHours);
    String minutes = twoDigits(_timeLeft.inMinutes.remainder(60));
    String seconds = twoDigits(_timeLeft.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds Left";
  }

  bool get canCollect => _canCollect;
  double get userCpPoints => _userCpPoints;
  int get stepCount => _stepCount;
  double get totalPlatformProfitUsd => _totalPlatformProfitUsd;

  void startMiningTimer() {
    _miningTimer?.cancel();
    _miningTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        _timeLeft -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        _canCollect = true;
        _miningTimer?.cancel();
        notifyListeners();
      }
    });
  }

  void collectMiningRewards() {
    if (_canCollect) {
      _userCpPoints += 500; 
      _timeLeft = const Duration(hours: 4, minutes: 0, seconds: 0); 
      _canCollect = false;
      startMiningTimer();
      notifyListeners();
    }
  }

  void watchAdAndEarn() {
    double sampleAdRevenueUsd = 0.05; 
    final distribution = RevenueController.calculateSplit(sampleAdRevenueUsd);

    _totalPlatformProfitUsd += distribution['platformProfitUsd']!;
    
    double userCashShare = distribution['userPayoutUsd']!;
    double conversionRateToCp = 100000; 
    _userCpPoints += (userCashShare * conversionRateToCp);

    notifyListeners();
  }

  void simulateSteps() {
    if (_stepCount < 10000) {
      _stepCount += 150;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _miningTimer?.cancel();
    super.dispose();
  }
}

class CashPawsApp extends StatelessWidget {
  const CashPawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F141C),
        primaryColor: const Color(0xFF3A88E9),
      ),
      home: const DashboardShell(),
    );
  }
}

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  final DashboardState _stateController = DashboardState();

  @override
  void initState() {
    super.initState();
    _stateController.startMiningTimer();
    _stateController.addListener(_updateUi);
  }

  void _updateUi() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _stateController.removeListener(_updateUi);
    _stateController.dispose();
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
                    _buildTopHeaderBar(_stateController.userCpPoints),
                    const SizedBox(height: 20),
                    _buildLoginWidget(),
                    const Spacer(),
                    Text(
                      "Platform Safe Profit (90% Cut): \$${_stateController.totalPlatformProfitUsd.toStringAsFixed(4)}",
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
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomBannerAd(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeaderBar(double points) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, size: 18, color: Colors.white70),
            ),
            SizedBox(width: 8),
            Text("AlexPaw", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
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
              Text(
                "${points.toStringAsFixed(0)} CP",
                style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13),
              ),
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
            children: List.generate(4, (index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(Icons.pets, color: Color(0xFF3A88E9), size: 20),
            )),
          )
        ],
      ),
    );
  }

    Widget _buildGlassHUDEngine() {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildMenuTile("Spin The Wheel", "TRY YOUR LUCK!", const Color(0xFFE99E3A), Icons.casino, () {}),
                const SizedBox(height: 12),
                _buildMenuTile("Tap Coins!", "TAP TO EARN!", const Color(0xFFFFD700), Icons.touch_app, () {}),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 300,
              borderRadius: 24,
              blur: 20,
              alignment: Alignment.center,
              border: 1.5,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.01)],
              ),
              borderGradient: const LinearGradient(colors: [Color(0xFF3A88E9), Color(0xFFE99E3A)]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Mini-Mining", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: GradientBoxBorder(
                        gradient: const LinearGradient(colors: [Colors.cyan, Color(0xFF3A88E9), Colors.transparent]),
                        width: 3,
                      ),
                    ),
                    child: const Center(child: Icon(Icons.pets, size: 54, color: Color(0xFFC0D6E4))),
                  ),
                  const SizedBox(height: 12),
                  const Text("Mining Active:", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(_stateController.formattedTime, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _stateController.canCollect ? () => _stateController.collectMiningRewards() : null,
                    child: Opacity(
                      opacity: _stateController.canCollect ? 1.0 : 0.4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, py: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(colors: [Color(0xFF2B5876), Color(0xFF4E4376)]),
                        ),
                        child: Text(
                          _stateController.canCollect ? "CLAIM NOW" : "COLLECT",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _buildMenuTile("Walking Rewards", "${_stateController.stepCount} / 10,000", const Color(0xFF3A88E9), Icons.directions_walk, () {
                  _stateController.simulateSteps();
                }),
                const SizedBox(height: 12),
                _buildMenuTile("Watch Ads", "WATCH & EARN CP", Colors.redAccent, Icons.play_circle_filled, () {
                  _stateController.watchAdAndEarn();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(String title, String subtitle, Color color, IconData icon, VoidCallback action) {
    return Expanded(
      child: GestureDetector(
        onTap: action,
        child: GlassmorphicContainer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 16,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(colors: [Colors.white.withOpacity(0.04), Colors.white.withOpacity(0.01)]),
          borderGradient: LinearGradient(colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomBannerAd extends StatelessWidget {
  const BottomBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF070A0F),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, py: 2),
                color: Colors.purple,
                child: const Text("AD", style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Text("Level Up and Earn \$!", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 28),
            ),
            onPressed: () {},
            child: const Text("INSTALL", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
