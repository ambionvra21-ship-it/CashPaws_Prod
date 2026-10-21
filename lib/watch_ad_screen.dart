import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class WatchAdScreen extends StatefulWidget {
  const WatchAdScreen({Key? key}) : super(key: key);

  @override
  State<WatchAdScreen> createState() => _WatchAdScreenState();
}

class _WatchAdScreenState extends State<WatchAdScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Economic & User States
  int _pawcoins = 0;
  int _adsWatchedToday = 0;
  final int _maxDailyAds = 25; // Capped to protect 95% profit margin
  bool _isLoading = true;
  bool _isAdLoading = false;

  // AdMob Variables
  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;
  RewardedAd? _rewardedAd;
  bool _isTopBannerLoaded = false;
  bool _isBottomBannerLoaded = false;

  // Live Test Ad Unit IDs
  final String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  final String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _initAdMobBanners();
    _loadRewardedAd();
  }

  // --- 1. Database Synchronization (Supabase) ---
  Future<void> _fetchUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = await _supabase
          .from('user_profiles')
          .select('pawcoins, ads_watched_today')
          .eq('user_id', user.id) // Corrected target key reference mapping
          .single();

      if (mounted) {
        setState(() {
          _pawcoins = data['pawcoins'] ?? 0;
          _adsWatchedToday = data['ads_watched_today'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error syncing data from Supabase: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateCoinsInDatabase(int rewardAmount) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final int newCoinTotal = _pawcoins + rewardAmount;
      final int newAdCount = _adsWatchedToday + 1;

      await _supabase.from('user_profiles').update({
        'pawcoins': newCoinTotal,
        'ads_watched_today': newAdCount,
        'last_ad_watch': DateTime.now().toIso8601String(),
      }).eq('user_id', user.id);

      setState(() {
        _pawcoins = newCoinTotal;
        _adsWatchedToday = newAdCount;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🎉 Claimed +$rewardAmount Pawcoins!')),
      );
    } catch (e) {
      debugPrint('Database update failed: $e');
    }
  }

  // --- 2. Monetization Integrations (AdMob) ---
  void _initAdMobBanners() {
    _topBannerAd = BannerAd(
      adUnitId: _testBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isTopBannerLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Top Banner missing/failed: $error');
        },
      ),
    )..load();

    _bottomBannerAd = BannerAd(
      adUnitId: _testBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBottomBannerLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Bottom Banner missing/failed: $error');
        },
      ),
    )..load();
  }

  void _loadRewardedAd() {
    if (_adsWatchedToday >= _maxDailyAds) return;

    setState(() => _isAdLoading = true);
    RewardedAd.load(
      adUnitId: _testRewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          setState(() => _isAdLoading = false);
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          setState(() => _isAdLoading = false);
        },
      ),
    );
  }

    // --- 1. Ad Presentation & Safety Callback Loops ---
  void _showRewardedAd() {
    if (_rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video ad is buffering, please tap again...')),
      );
      _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd(); // Load next ad immediately into device memory
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      // 95% Margin Security Gate Check: Enforce +15 Pawcoins per video ad
      _updateCoinsInDatabase(15);
    });
    _rewardedAd = null;
  }

  // --- 2. View Assembly Hierarchy ---
  @override
  Widget build(BuildContext context) {
    final double usdValue = _pawcoins / 1000.0;

    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        title: const Text('Watch Ads & Earn', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : Column(
              children: [
                // Top Fixed AdMob Banner Slot Container
                if (_isTopBannerLoaded && _topBannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    width: _topBannerAd!.size.width.toDouble(),
                    height: _topBannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _topBannerAd!),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Wallet Balance Header Panel
                        Card(
                          color: const Color(0xFF1A1A1E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.orangeAccent, width: 0.5),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const Text('Your Pawcoin Balance', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                const SizedBox(height: 8),
                                Text(
                                  '🐾 $_pawcoins',
                                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '≈ \$${usdValue.toStringAsFixed(2)} USD (Min. threshold: \$10)',
                                  style: const TextStyle(fontSize: 14, color: Colors.greenAccent, fontWeight: FontWeight.w600),
                                ),
                                const Divider(height: 24, color: Colors.white10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Daily Limit Progress:', style: TextStyle(fontSize: 14, color: Colors.white70)),
                                    Text('$_adsWatchedToday / $_maxDailyAds Ads', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: _adsWatchedToday / _maxDailyAds,
                                  backgroundColor: Colors.white10,
                                  color: Colors.orangeAccent,
                                  minHeight: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Main Hero Reward Interactive Trigger Button Box
                        GestureDetector(
                          onTap: (_adsWatchedToday >= _maxDailyAds || _isAdLoading) ? null : _showRewardedAd,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orangeAccent.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                            child: Column(
                              children: [
                                const Icon(Icons.play_circle_filled, size: 80, color: Colors.black),
                                const SizedBox(height: 16),
                                Text(
                                  _adsWatchedToday >= _maxDailyAds 
                                      ? 'Daily Ad Limit Reached!' 
                                      : 'Tap to Care for Pet & Watch Ad',
                                  style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _adsWatchedToday >= _maxDailyAds
                                      ? 'Resets tomorrow at 12:00 AM'
                                      : 'Earns instant +15 Pawcoins',
                                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // System Security Notice Container Panel
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.grey, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Caring for your cat or dog unlocks daily passive multipliers! Watching video ads secures platform maintenance.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Fixed AdMob Banner Slot Container
                if (_isBottomBannerLoaded && _bottomBannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    width: _bottomBannerAd!.size.width.toDouble(),
                    height: _bottomBannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bottomBannerAd!),
                  ),
              ],
            ),
    );
  }

  // --- 3. Memory Component Management Cleanup Disposals ---
  @override
  void dispose() {
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }
}
