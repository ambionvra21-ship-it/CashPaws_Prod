import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({Key? key}) : super(key: key);

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> with SingleTickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Animation Rotation Controllers
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _currentRotationAngle = 0.0;
  bool _isSpinning = false;

  // Earning State Limits Matrix
  int _adsWatchedToday = 0;
  final int _maxDailySpins = 5;
  int _currentCoins = 0;
  bool _isLoading = true;

  // FIXED: Explicitly initialized reward layout matrix array fractions
  final List<int> _wheelRewards =;

  // Monetization Mobile Framework Variables
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  final String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _fetchUserStats();
    _initAdMob();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.decelerate);
  }

  void _initAdMob() {
    _bannerAd = BannerAd(
      adUnitId: _testBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('AdMob configuration break on route: $error');
        },
      ),
    )..load();
  }

  Future<void> _fetchUserStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = await _supabase
          .from('user_profiles')
          .select('pawcoins, ads_watched_today')
          .eq('user_id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _currentCoins = data['pawcoins'] ?? 0;
          _adsWatchedToday = data['ads_watched_today'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('User telemetry load failure: $e');
      setState(() => _isLoading = false);
    }
  }

    // --- 1. Rotation Simulation Calculation & Validation Loops ---
  void _spinTheWheel() {
    if (_isSpinning || _adsWatchedToday >= _maxDailySpins) return;

    setState(() {
      _isSpinning = true;
    });

    final random = Random();
    final int targetWedgeIndex = random.nextInt(_wheelRewards.length);
    
    const double wedgeAngle = 360 / 8;
    final double targetAngle = (360 * 4) + (targetWedgeIndex * wedgeAngle);

    _animation = Tween<double>(
      begin: _currentRotationAngle % 360,
      end: targetAngle,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.decelerate));

    _animationController.forward(from: 0.0).then((_) {
      _currentRotationAngle = targetAngle;
      final int wonCoins = _wheelRewards[targetWedgeIndex];
      _processRewardCredit(wonCoins);
    });
  }

  Future<void> _processRewardCredit(int coinsWon) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final int updatedCoins = _currentCoins + coinsWon;
      final int updatedSpins = _adsWatchedToday + 1;

      await _supabase.from('user_profiles').update({
        'pawcoins': updatedCoins,
        'ads_watched_today': updatedSpins,
      }).eq('user_id', user.id);

      if (mounted) {
        setState(() {
          _currentCoins = updatedCoins;
          _adsWatchedToday = updatedSpins;
          _isSpinning = false;
        });

        _showRewardModal(coinsWon);
      }
    } catch (e) {
      debugPrint('Cloud server point ledger update aborted: $e');
      setState(() => _isSpinning = false);
    }
  }

  void _showRewardModal(int amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1E),
        title: const Text('Wheel Spin Outcome', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          amount > 0 ? '🎉 Amazing! You unlocked +$amount Pawcoins directly to your balance.' : '💨 Unlucky roll! Try again next time!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Collect', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- 2. Screen Visual Layout Build Tree Hierarchy ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        title: const Text('Lucky Spin Roulette', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A1E),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Wallet Balance: 🐾 $_currentCoins', style: const TextStyle(color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                            Text('Spins: $_adsWatchedToday / $_maxDailySpins', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 60),

                        Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: (_animation.value * pi) / 180,
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.orangeAccent, width: 6),
                                ),
                                child: CustomPaint(painter: WheelWedgePainter(_wheelRewards)),
                              ),
                            ),
                            const Icon(Icons.navigation_rounded, size: 48, color: Colors.orangeAccent),
                          ],
                        ),
                        const SizedBox(height: 60),

                        ElevatedButton(
                          onPressed: (_isSpinning || _adsWatchedToday >= _maxDailySpins) ? null : _spinTheWheel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            disabledBackgroundColor: Colors.grey.withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            _adsWatchedToday >= _maxDailySpins ? 'Daily Spins Exhausted' : 'TAP TO SPIN WHEEL',
                            style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (_isBannerLoaded && _bannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }
}

// --- 3. FIXED: Compilation-Safe Custom Painter Vector Layer Engine ---
class WheelWedgePainter extends CustomPainter {
  final List<int> rewards;
  WheelWedgePainter(this.rewards);

  @override
  void paint(Canvas canvas, Size size) {
    if (rewards.isEmpty) return;
    
    final double sweepAngle = (2 * pi) / rewards.length;
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < rewards.length; i++) {
      // FIXED: Removed runtime assignment error by explicitly handling color states safely
      paint.color = (i % 2 == 0) ? const Color(0xFF232329) : const Color(0xFF2D2D35);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), i * sweepAngle, sweepAngle, true, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
