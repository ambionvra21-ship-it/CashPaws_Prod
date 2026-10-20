import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TapCoinsScreen extends StatefulWidget {
  const TapCoinsScreen({Key? key}) : super(key: key);

  @override
  State<TapCoinsScreen> createState() => _TapCoinsScreenState();
}

class _TapCoinsScreenState extends State<TapCoinsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Game Engine State Loop Variables
  int _score = 0;
  int _highScore = 0;
  int _timeLeft = 30; // 30-second reflex crunch match timer
  bool _isGameActive = false;
  bool _isLoading = true;
  Timer? _gameTimer;

  // Click Target Canvas Coordinates Matrix
  double _coinTop = 150.0;
  double _coinLeft = 100.0;

  // AdMob Performance Configuration Layers
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  final String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _loadUserHighScore();
    _initGameBanner();
  }

  void _initGameBanner() {
    _bannerAd = BannerAd(
      adUnitId: _testBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Game Layout Ad Execution Refused: $error');
        },
      ),
    )..load();
  }

  Future<void> _loadUserHighScore() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = await _supabase
          .from('user_profiles')
          .select('tap_high_score')
          .eq('user_id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _highScore = data['tap_high_score'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Profile high score lookup skipped: $e');
      setState(() => _isLoading = false);
    }
  }

    // --- 1. Game Mechanics, Timer, and Randomization Engine ---
  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isGameActive = true;
    });
    _relocateCoin();
    _startCountdown();
  }

  void _startCountdown() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _gameTimer?.cancel();
            _isGameActive = false;
            _finalizeGameSession();
          }
        });
      }
    });
  }

  void _handleCoinTap() {
    if (!_isGameActive) return;
    setState(() {
      _score++;
    });
    _relocateCoin();
  }

  void _relocateCoin() {
    final random = Random();
    // Constraints match screen dimension baselines safely to prevent text overflow layout breaks
    double nextTop = 100.0 + random.nextInt(260);
    double nextLeft = 30.0 + random.nextInt(240);

    setState(() {
      _coinTop = nextTop;
      _coinLeft = nextLeft;
    });
  }

  Future<void> _finalizeGameSession() async {
    // Conversion Formula: 1 Pawcoin per 5 taps completed
    final int pawcoinsEarned = _score ~/ 5; 
    bool isNewHighScore = _score > _highScore;

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Extract current user values safely
      final profileData = await _supabase
          .from('user_profiles')
          .select('pawcoins')
          .eq('user_id', user.id)
          .single();

      final int exactCurrentCoins = profileData['pawcoins'] ?? 0;
      final int verifiedNewCoinTotal = exactCurrentCoins + pawcoinsEarned;

      Map<String, dynamic> updatesToCommit = {
        'pawcoins': verifiedNewCoinTotal,
      };

      if (isNewHighScore) {
        updatesToCommit['tap_high_score'] = _score;
        setState(() => _highScore = _score);
      }

      await _supabase.from('user_profiles').update(updatesToCommit).eq('user_id', user.id);
      _showMatchOverDialog(pawcoinsEarned, isNewHighScore);
    } catch (e) {
      debugPrint('Error updating scores on server: $e');
    }
  }

  void _showMatchOverDialog(int coinsEarned, bool isHighScore) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isHighScore ? '🏆 New High Score!' : '⏱️ Match Concluded',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Taps Registered: $_score\n\n🎉 You earned +$coinsEarned Pawcoins credited directly to your live system balance!',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back to Dashboard', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- 2. Screen Visual Layout Engine Architecture ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        title: const Text('Quick Tap Coins', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : Column(
              children: [
                // Real-time Match Telemetry Header Panel Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: const Color(0xFF1A1A1E),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Taps: $_score', style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Time: ${_timeLeft}s', style: TextStyle(color: _timeLeft <= 5 ? Colors.redAccent : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Best: $_highScore', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),

                Expanded(
                  child: Stack(
                    children: [
                      // Active Bouncing Target Canvas (Rendered only when match is live)
                      if (_isGameActive)
                        Positioned(
                          top: _coinTop,
                          left: _coinLeft,
                          child: GestureDetector(
                            onTap: _handleCoinTap,
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber,
                                boxShadow: [
                                  BoxShadow(color: Colors.orangeAccent, blurRadius: 12, spreadRadius: 2)
                                ],
                              ),
                              child: const Center(
                                child: Text('🐾', style: TextStyle(fontSize: 32)),
                              ),
                            ),
                          ),
                        ),

                      // Inactive Pre-game Menu UI Overlay Layer
                      if (!_isGameActive)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.touch_app_rounded, size: 72, color: Colors.orangeAccent),
                                const SizedBox(height: 16),
                                const Text(
                                  'Tap Coins Challenge',
                                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap the bouncing token as fast as possible within 30 seconds. Every 5 taps generates 1 Pawcoin!',
                                  style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton(
                                  onPressed: _startGame,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent,
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  child: const Text(
                                    'START TRIAL MATCH',
                                    style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Fixed Bottom Sticky Admob Layout Slot
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
    _gameTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }
}
